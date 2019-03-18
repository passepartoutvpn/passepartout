//
//  TransientStore.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/16/18.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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
import SwiftyBeaver

private let log = SwiftyBeaver.self

public class TransientStore {
    private struct Keys {
        static let didHandleSubreddit = "DidHandleSubreddit"
    }
    
    public static let shared = TransientStore()
    
    private static var serviceURL: URL {
        return GroupConstants.App.documentsURL.appendingPathComponent(AppConstants.Store.serviceFilename)
    }
    
    public let service: ConnectionService

    public var didHandleSubreddit: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.didHandleSubreddit)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.didHandleSubreddit)
        }
    }

    private init() {
        TransientStore.migrateDocumentsToAppGroup()

        // this must be graceful
        ConnectionService.migrateJSON(from: TransientStore.serviceURL, to: TransientStore.serviceURL)

        let cfg = AppConstants.VPN.baseConfiguration()
        do {
            let data = try Data(contentsOf: TransientStore.serviceURL)
            if let content = String(data: data, encoding: .utf8) {
                log.verbose("Service JSON:")
                log.verbose(content)
            }
            service = try JSONDecoder().decode(ConnectionService.self, from: data)
            service.baseConfiguration = cfg
            service.loadProfiles()
        } catch let e {
            log.error("Could not decode service: \(e)")
            service = ConnectionService(
                withAppGroup: GroupConstants.App.appGroup,
                baseConfiguration: cfg
            )

//            // hardcoded loading
//            _ = service.addProfile(ProviderConnectionProfile(name: .pia), credentials: nil)
//            _ = service.addProfile(HostConnectionProfile(title: "vps"), credentials: Credentials(username: "foo", password: "bar"))
//            service.activateProfile(service.profiles.first!)
        }
    }
    
    public func serialize(withProfiles: Bool) {
        try? JSONEncoder().encode(service).write(to: TransientStore.serviceURL)
        if withProfiles {
            service.saveProfiles()
        }
    }
    
    //
    
    private static func migrateDocumentsToAppGroup() {
        var hasMigrated = false
        let oldDocumentsURL = FileManager.default.userURL(for: .documentDirectory, appending: nil)
        let newDocumentsURL = GroupConstants.App.documentsURL
        log.debug("App documentsURL: \(oldDocumentsURL)")
        log.debug("Group documentsURL: \(newDocumentsURL)")
        let fm = FileManager.default
        do {
            for c in try fm.contentsOfDirectory(atPath: oldDocumentsURL.path) {
                guard c != "Inbox" else {
                    continue
                }
                let old = oldDocumentsURL.appendingPathComponent(c)
                let new = newDocumentsURL.appendingPathComponent(c)
                log.verbose("Move:")
                log.verbose("\tFROM: \(old)")
                log.verbose("\tTO: \(new)")
                try fm.moveItem(at: old, to: new)
                hasMigrated = true
            }
        } catch let e {
            hasMigrated = false
            log.error("Could not migrate documents to App Group: \(e)")
        }
        if hasMigrated {
            log.debug("Documents migrated to App Group")
        }
    }
}
