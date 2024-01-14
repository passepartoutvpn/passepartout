//
//  PersistenceManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/6/22.
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
import PassepartoutLibrary

@MainActor
final class PersistenceManager: ObservableObject {
    let store: KeyValueStore

    private let ckContainerId: String

    private let ckSharedContainerId: String

    private let ckCoreDataZone: String

    private var vpnPersistence: VPNPersistence?

    private var sharedVPNPersistence: VPNPersistence?

    private var providersPersistence: ProvidersPersistence?

    private(set) var isCloudSyncingEnabled: Bool {
        didSet {
            pp_log.info("CloudKit enabled: \(isCloudSyncingEnabled)")
            didChangePersistence.send()
        }
    }

    @Published private(set) var isErasingCloudKitStore = false

    let didChangePersistence = PassthroughSubject<Void, Never>()

    init(store: KeyValueStore,
         ckContainerId: String,
         ckSharedContainerId: String,
         ckCoreDataZone: String) {
        self.store = store
        self.ckContainerId = ckContainerId
        self.ckSharedContainerId = ckSharedContainerId
        self.ckCoreDataZone = ckCoreDataZone
        isCloudSyncingEnabled = store.canEnableCloudSyncing

        // set once
        if persistenceAuthor == nil {
            persistenceAuthor = UUID().uuidString
        }
    }

    func loadVPNPersistence(withName containerName: String) -> VPNPersistence {
        let persistence = VPNPersistence(withName: containerName,
                                         cloudKit: isCloudSyncingEnabled,
                                         cloudKitIdentifier: nil,
                                         author: persistenceAuthor)
        vpnPersistence = persistence
        return persistence
    }

    func loadSharedVPNPersistence(withName containerName: String) -> VPNPersistence {
        let persistence = VPNPersistence(withName: containerName,
                                         cloudKit: true,
                                         cloudKitIdentifier: ckSharedContainerId,
                                         author: persistenceAuthor)
        sharedVPNPersistence = persistence
        return persistence
    }

    func loadProvidersPersistence(withName containerName: String) -> ProvidersPersistence {
        let persistence = ProvidersPersistence(withName: containerName, cloudKit: false, author: persistenceAuthor)
        providersPersistence = persistence
        return persistence
    }
}

// MARK: CloudKit

extension PersistenceManager {
    func eraseCloudKitStore() async {
        isErasingCloudKitStore = true
        await Self.eraseCloudKitStore(
            fromContainerWithId: ckContainerId,
            zoneId: .init(zoneName: ckCoreDataZone)
        )
        await Self.eraseCloudKitStore(
            fromContainerWithId: ckSharedContainerId,
            zoneId: .init(zoneName: ckCoreDataZone)
        )
        isErasingCloudKitStore = false
    }

    // WARNING: this is not running on main actor
    private static func eraseCloudKitStore(fromContainerWithId containerId: String, zoneId: CKRecordZone.ID) async {
        do {
            let container = CKContainer(identifier: containerId)
            let db = container.privateCloudDatabase
            try await db.deleteRecordZone(withID: zoneId)
        } catch {
            pp_log.error("Unable to erase CloudKit store: \(error)")
        }
    }
}

// MARK: KeyValueStore

private extension KeyValueStore {
    private var cloudKitToken: Any? {
        FileManager.default.ubiquityIdentityToken
    }

    private var isCloudKitSupported: Bool {
        #if !os(tvOS)
        cloudKitToken != nil
        #else
        true
        #endif
    }

    var canEnableCloudSyncing: Bool {
        isCloudKitSupported && shouldEnableCloudSyncing
    }

    var shouldEnableCloudSyncing: Bool {
        get {
            value(forLocation: PersistenceManager.StoreKey.shouldEnableCloudSyncing) ?? false
        }
        set {
            setValue(newValue, forLocation: PersistenceManager.StoreKey.shouldEnableCloudSyncing)
        }
    }
}

extension PersistenceManager {
    private(set) var persistenceAuthor: String? {
        get {
            store.value(forLocation: StoreKey.persistenceAuthor)
        }
        set {
            store.setValue(newValue, forLocation: StoreKey.persistenceAuthor)
        }
    }

    var shouldEnableCloudSyncing: Bool {
        get {
            store.shouldEnableCloudSyncing
        }
        set {
            objectWillChange.send()
            store.shouldEnableCloudSyncing = newValue

            // iCloud may be externally disabled from the device settings
            let newIsCloudSyncingEnabled = store.canEnableCloudSyncing
            guard newIsCloudSyncingEnabled != isCloudSyncingEnabled else {
                pp_log.debug("CloudKit state did not change")
                return
            }
            isCloudSyncingEnabled = newIsCloudSyncingEnabled
        }
    }
}

// TODO: iCloud, restore private after dropping migration from 2.2.0
// private extension PersistenceManager {
extension PersistenceManager {
    enum StoreKey: String, KeyStoreDomainLocation {
        case persistenceAuthor

        case shouldEnableCloudSyncing

        var domain: String {
            "Passepartout.PersistenceManager"
        }
    }
}
