//
//  CoreDataPersistentStore.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/14/22.
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

import CloudKit
import Combine
import CoreData
import Foundation

public final class CoreDataPersistentStore {
    private let container: NSPersistentContainer

    public convenience init(withName containerName: String, model: NSManagedObjectModel, cloudKit: Bool, cloudKitIdentifier: String?, author: String?) {
        let container: NSPersistentContainer
        if cloudKit {
            container = NSPersistentCloudKitContainer(name: containerName, managedObjectModel: model)
            pp_log.debug("Setting up CloudKit container: \(containerName)")
        } else {
            container = NSPersistentContainer(name: containerName, managedObjectModel: model)
            pp_log.debug("Setting up local container: \(containerName)")
        }
        self.init(withContainer: container, cloudKitIdentifier: cloudKitIdentifier, author: author)
    }

    private init(withContainer container: NSPersistentContainer, cloudKitIdentifier: String?, author: String?) {
        self.container = container

        guard let desc = container.persistentStoreDescriptions.first else {
            fatalError("Could not read persistent store description")
        }
        pp_log.debug("Container description: \(desc)")

        // optional container identifier for CloudKit, first in entitlements otherwise
        if let cloudKitIdentifier {
            desc.cloudKitContainerOptions = .init(containerIdentifier: cloudKitIdentifier)
        }

        // set this even for local container, to avoid readonly mode in case
        // container was formerly created with CloudKit option
        desc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        // report remote notifications (do this BEFORE loadPersistentStores)
        //
        // https://stackoverflow.com/a/69507329/784615
//        desc.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        container.loadPersistentStores {
            if let error = $1 {
                fatalError("Could not load persistent store: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true

        if let author = author {
            pp_log.debug("Setting transaction author: \(author)")
            container.viewContext.transactionAuthor = author
        }
    }
}

extension CoreDataPersistentStore {
    public var context: NSManagedObjectContext {
        container.viewContext
    }

    public var backgroundContext: NSManagedObjectContext {
        container.newBackgroundContext()
    }

    public var coordinator: NSPersistentStoreCoordinator {
        container.persistentStoreCoordinator
    }
}

// MARK: Development

extension CoreDataPersistentStore {
    public var containerURLs: [URL]? {
        guard let url = container.persistentStoreDescriptions.first?.url else {
            return nil
        }
        return [
            url,
            url.deletingPathExtension().appendingPathExtension("sqlite-shm"),
            url.deletingPathExtension().appendingPathExtension("sqlite-wal")
        ]
    }

//    public func remoteChangesPublisher() -> AnyPublisher<Void, Never> {
//        NotificationCenter.default.publisher(
//            for: .NSPersistentStoreRemoteChange,
//            object: coordinator
//        ).flatMap { _ in
//            Just(())
//        }.eraseToAnyPublisher()
//    }

    public func truncate() {
        let coordinator = container.persistentStoreCoordinator
        container.persistentStoreDescriptions.forEach {
            do {
                try $0.url.map {
                    try coordinator.destroyPersistentStore(at: $0, ofType: NSSQLiteStoreType)
                    try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: $0, options: nil)
                }
            } catch {
                pp_log.warning("Could not truncate persistent store: \(error)")
            }
        }
    }
}
