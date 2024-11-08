//
//  CoreDataRepository.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/10/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

import Combine
import CoreData
import Foundation

public protocol CoreDataUniqueEntity: NSManagedObject, UniqueEntity {
    // Core Data entity must have a unique "uuid" field
}

public enum CoreDataResultAction {
    case ignore

    case discard

    case halt
}

public actor CoreDataRepository<CD, T>: NSObject,
                                        Repository,
                                        NSFetchedResultsControllerDelegate where CD: CoreDataUniqueEntity,
                                                                                 T: UniqueEntity {

    private let entityName: String

    private let context: NSManagedObjectContext

    private let observingResults: Bool

    private let fromMapper: (CD) throws -> T?

    private let toMapper: (T, NSManagedObjectContext) throws -> CD

    private let onResultError: ((Error) -> CoreDataResultAction)?

    private let entitiesSubject: CurrentValueSubject<EntitiesResult<T>, Never>

    // cannot easily use CD as generic
    private var resultsController: NSFetchedResultsController<CD>

    public init(
        context: NSManagedObjectContext,
        observingResults: Bool,
        beforeFetch: ((NSFetchRequest<CD>) -> Void)? = nil,
        fromMapper: @escaping (CD) throws -> T?,
        toMapper: @escaping (T, NSManagedObjectContext) throws -> CD,
        onResultError: ((Error) -> CoreDataResultAction)? = nil
    ) {
        guard let entityName = CD.entity().name else {
            fatalError("Unable to find entity name for \(CD.self)")
        }

        self.entityName = entityName
        self.context = context
        self.observingResults = observingResults
        self.fromMapper = fromMapper
        self.toMapper = toMapper
        self.onResultError = onResultError
        entitiesSubject = CurrentValueSubject(EntitiesResult())

        let request = NSFetchRequest<CD>(entityName: entityName)
        beforeFetch?(request)
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()

        resultsController.delegate = self
        do {
            try resultsController.performFetch()
            sendResults(from: resultsController)
        } catch {
            //
        }
    }

    public nonisolated var entitiesPublisher: AnyPublisher<EntitiesResult<T>, Never> {
        entitiesSubject
            .eraseToAnyPublisher()
    }

    public func filter(byFormat format: String, arguments: [Any]?) async throws {
        try await filter(byPredicate: NSPredicate(format: format, argumentArray: arguments))
    }

    public func resetFilter() async throws {
        try await filter(byPredicate: nil)
    }

    public func saveEntities(_ entities: [T]) async throws {
        try await context.perform { [weak self] in
            guard let self else {
                return
            }
            do {
                let request = newFetchRequest()
                let existingIds = entities.compactMap(\.uuid)
                request.predicate = NSPredicate(
                    format: "any uuid in %@",
                    existingIds
                )
                let existing = try context.fetch(request)
                existing.forEach(context.delete)
                for entity in entities {
                    _ = try self.toMapper(entity, context)
                }
                try context.save()
            } catch {
                context.rollback()
                throw error
            }
        }
    }

    public func removeEntities(withIds ids: [UUID]?) async throws {
        try await context.perform { [weak self] in
            guard let self else {
                return
            }
            let request = newFetchRequest()
            if let ids {
                request.predicate = NSPredicate(
                    format: "any uuid in %@",
                    ids
                )
            }
            do {
                let existing = try context.fetch(request)
                existing.forEach(context.delete)

                try context.save()
            } catch {
                context.rollback()
                throw error
            }
        }
    }

    // MARK: NSFetchedResultsControllerDelegate

    // XXX: triggers on entity insert/update/delete and reloads/remaps ALL into entitiesSubject
    public nonisolated func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard observingResults else {
            return
        }
        guard let cdController = controller as? NSFetchedResultsController<CD> else {
            fatalError("Unable to upcast results to \(CD.self)")
        }
        sendResults(from: cdController)
    }
}

private extension CoreDataRepository {
    enum ResultError: Error {
        case mapping(Error)
    }

    func filter(byPredicate predicate: NSPredicate?) async throws {
        let request = resultsController.fetchRequest
        request.predicate = predicate
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        resultsController.delegate = self
        try resultsController.performFetch()
        sendResults(from: resultsController)
    }

    nonisolated func newFetchRequest() -> NSFetchRequest<CD> {
        NSFetchRequest(entityName: entityName)
    }

    nonisolated func sendResults(from controller: NSFetchedResultsController<CD>) {
        Task.detached { [weak self] in
            await self?.context.perform { [weak self] in
                guard let cdEntities = controller.fetchedObjects else {
                    return
                }
                do {
                    let entities = try cdEntities.compactMap {
                        do {
                            return try self?.fromMapper($0)
                        } catch {
                            switch self?.onResultError?(error) {
                            case .discard:
                                self?.context.delete($0)

                            case .halt:
                                throw ResultError.mapping(error)

                            default:
                                break
                            }
                            return nil
                        }
                    }

                    try self?.context.save()

                    let result = EntitiesResult(entities, isFiltering: controller.fetchRequest.predicate != nil)
                    self?.entitiesSubject.send(result)
                } catch {
                    NSLog("Unable to send Core Data entities: \(error)")
                }
            }
        }
    }
}
