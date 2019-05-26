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
import TunnelKit
import SwiftyBeaver

private let log = SwiftyBeaver.self

public class TransientStore {
    private struct Keys {
        static let didHandleSubreddit = "DidHandleSubreddit"
        
        static let masksPrivateData = "MasksPrivateData"

        // migrations
        
        static let didMigrateHostsRoutingPolicies = "DidMigrateHostsRoutingPolicies"
    }
    
    public static let shared = TransientStore()
    
    private static var serviceURL: URL {
        return GroupConstants.App.documentsURL.appendingPathComponent(AppConstants.Store.serviceFilename)
    }
    
    public let service: ConnectionService

    public static var didHandleSubreddit: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.didHandleSubreddit)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.didHandleSubreddit)
        }
    }

    public static var masksPrivateData: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.masksPrivateData)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.masksPrivateData)
        }
    }
    
    public static var didMigrateHostsRoutingPolicies: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.didMigrateHostsRoutingPolicies)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.didMigrateHostsRoutingPolicies)
        }
    }
    
    public static var baseVPNConfiguration: OpenVPNTunnelProvider.ConfigurationBuilder {
        let sessionBuilder = OpenVPN.ConfigurationBuilder()
        var builder = OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build())
        builder.mtu = 1250
        builder.shouldDebug = true
//        builder.debugLogFormat = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $L $N.$F:$l - $M"
//        builder.debugLogFormat = "$DHH:mm:ss$d $N.$F:$l - $M"
        builder.debugLogFormat = AppConstants.Log.debugFormat
        builder.masksPrivateData = masksPrivateData
        return builder
    }

    private init() {
        UserDefaults.standard.register(defaults: [
            Keys.didHandleSubreddit: false,
            Keys.masksPrivateData: true
        ])
        
        TransientStore.migrateDocumentsToAppGroup()

        // this must be graceful
        ConnectionService.migrateJSON(from: TransientStore.serviceURL, to: TransientStore.serviceURL)
        
        let cfg = TransientStore.baseVPNConfiguration.build()
        do {
            let data = try Data(contentsOf: TransientStore.serviceURL)
            if let content = String(data: data, encoding: .utf8) {
                log.verbose("Service JSON:")
                log.verbose(content)
            }
            service = try JSONDecoder().decode(ConnectionService.self, from: data)
            service.baseConfiguration = cfg
            service.loadProfiles()

            // do migrations
            if !TransientStore.didMigrateHostsRoutingPolicies {
                if service.reloadHostProfilesFromConfigurationFiles() {
                    service.saveProfiles()
                }
                TransientStore.didMigrateHostsRoutingPolicies = true
            }
        } catch let e {
            log.error("Could not decode service: \(e)")
            service = ConnectionService(
                withAppGroup: GroupConstants.App.groupId,
                baseConfiguration: cfg
            )

//            // hardcoded loading
//            _ = service.addProfile(ProviderConnectionProfile(name: .pia), credentials: nil)
//            _ = service.addProfile(HostConnectionProfile(title: "vps"), credentials: Credentials(username: "foo", password: "bar"))
//            service.activateProfile(service.profiles.first!)
        }
        service.observeVPNDataCount(interval: TimeInterval(GroupConstants.VPN.dataCountInterval) / 1000.0)
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
