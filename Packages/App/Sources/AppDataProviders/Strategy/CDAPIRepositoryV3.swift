//
//  CDAPIRepositoryV3.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/26/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Passepartout.
//
//  Passepartout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Passepartout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Passepartout.  If not, see <http://www.gnu.org/licenses/>.
//

import AppData
import CommonLibrary
import CommonUtils
import CoreData
import Foundation
import Partout

extension AppData {
    public static func cdAPIRepositoryV3(context: NSManagedObjectContext) -> APIRepository {
        CDAPIRepositoryV3(context: context)
    }
}

private final class CDAPIRepositoryV3: NSObject, APIRepository {
    private nonisolated let context: NSManagedObjectContext

    private nonisolated let providersSubject: CurrentValueStream<[Provider]>

    private nonisolated let cacheSubject: CurrentValueStream<[ProviderID: ProviderCache]>

    private nonisolated let providersController: NSFetchedResultsController<CDProviderV3>

    init(context: NSManagedObjectContext) {
        self.context = context
        providersSubject = CurrentValueStream([])
        cacheSubject = CurrentValueStream([:])

        let request = CDProviderV3.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "providerId", ascending: true)
        ]
        providersController = .init(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()

        Task {
            try await context.perform { [weak self] in
                self?.providersController.delegate = self
                try self?.providersController.performFetch()
            }
        }
    }

    nonisolated var indexStream: AsyncStream<[Provider]> {
        providersSubject
            .subscribe()
            .removeDuplicates()
    }

    nonisolated var cacheStream: AsyncStream<[ProviderID: ProviderCache]> {
        cacheSubject
            .subscribe()
            .removeDuplicates()
    }

    func store(_ index: [Provider]) async throws {
        try await context.perform { [weak self] in
            guard let self else {
                return
            }
            do {
                // fetch existing for cache then deletion
                let request = CDProviderV3.fetchRequest()
                let results = try request.execute()
                let cacheByProvider = results.reduce(into: [:]) {
                    $0[$1.providerId] = $1.cache
                }
                results.forEach(context.delete)

                // replace but retain cache
                let mapper = CoreDataMapper(context: context)
                try index.forEach {
                    let cache = cacheByProvider[$0.id.rawValue]
                    try mapper.cdProvider(from: $0, cache: cache)
                }

                try context.save()
            } catch {
                context.rollback()
                throw error
            }
        }
    }

    func store(_ infrastructure: ProviderInfrastructure, for providerId: ProviderID) async throws {
        try await context.perform { [weak self] in
            guard let self else {
                return
            }
            do {
                let predicate = providerId.predicate

                // signal update of related provider
                let providerRequest = CDProviderV3.fetchRequest()
                providerRequest.predicate = predicate
                let providers = try providerRequest.execute()
                if let provider = providers.first {
                    provider.cache = try JSONEncoder().encode(infrastructure.cache)
                }

                // delete all provider entities
                let serverRequest = CDProviderServerV3.fetchRequest()
                serverRequest.predicate = predicate
                let servers = try serverRequest.execute()
                servers.forEach(context.delete)

                let presetRequest = CDProviderPresetV3.fetchRequest()
                presetRequest.predicate = predicate
                let presets = try presetRequest.execute()
                presets.forEach(context.delete)

                // create new entities
                let mapper = CoreDataMapper(context: context)
                try infrastructure.servers.forEach {
                    try mapper.cdServer(from: $0)
                }
                try infrastructure.presets.forEach {
                    try mapper.cdPreset(from: $0)
                }

                try context.save()
            } catch {
                context.rollback()
                throw error
            }
        }
    }

    func resetCache(for providerIds: [ProviderID]?) async {
        try? await context.perform { [weak self] in
            guard let self else {
                return
            }
            let providerRequest = CDProviderV3.fetchRequest()
            if let providerIds {
                providerRequest.predicate = NSPredicate(
                    format: "providerId in %@",
                    providerIds.map(\.rawValue)
                )
            }
            let providers = try providerRequest.execute()
            providers.forEach {
                $0.lastUpdate = nil
            }
            try context.save()
        }
    }

    nonisolated func presets(for server: ProviderServer, moduleType: ModuleType) async throws -> [ProviderPreset] {
        try await context.perform {
            let request = CDProviderPresetV3.fetchRequest()
            if let supported = server.supportedPresetIds {
                request.predicate = NSPredicate(
                    format: "providerId == %@ AND moduleType == %@ AND (presetId IN %@)",
                    server.metadata.providerId.rawValue,
                    moduleType.rawValue,
                    supported
                )
            } else {
                request.predicate = NSPredicate(
                    format: "providerId == %@ AND moduleType == %@",
                    server.metadata.providerId.rawValue,
                    moduleType.rawValue
                )
            }
            let results = try request.execute()
            let mapper = DomainMapper()
            return try results.compactMap(mapper.preset(from:))
        }
    }

    nonisolated func providerRepository(for providerId: ProviderID) -> ProviderRepository {
        CDProviderRepositoryV3(context: context, providerId: providerId)
    }
}

extension CDAPIRepositoryV3: NSFetchedResultsControllerDelegate {
    nonisolated func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let entities = controller.fetchedObjects as? [CDProviderV3] else {
            return
        }
        let mapper = DomainMapper()
        providersSubject.send(entities.compactMap(mapper.provider(from:)))
        cacheSubject.send(mapper.cache(from: entities))
    }
}
