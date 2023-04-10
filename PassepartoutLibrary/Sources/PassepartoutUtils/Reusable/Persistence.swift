//
//  Persistence.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/14/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

import Foundation
import CoreData
import Combine

public class Persistence {
    private let container: NSPersistentContainer

    public var context: NSManagedObjectContext {
        container.viewContext
    }

    public var coordinator: NSPersistentStoreCoordinator {
        container.persistentStoreCoordinator
    }

    public convenience init(withLocalName containerName: String, model: NSManagedObjectModel, author: String?) {
        let container = NSPersistentContainer(name: containerName, managedObjectModel: model)
        self.init(withContainer: container, author: author)
    }

    public convenience init(withCloudKitName containerName: String, model: NSManagedObjectModel, author: String?) {
        let container = NSPersistentCloudKitContainer(name: containerName, managedObjectModel: model)
        self.init(withContainer: container, author: author)
    }

    private init(withContainer container: NSPersistentContainer, author: String?) {
        self.container = container

        guard let desc = container.persistentStoreDescriptions.first else {
            fatalError("Could not read persistent store description")
        }
        pp_log.debug("Container description: \(desc)")

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
