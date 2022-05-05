//
//  AppManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/8/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
import SwiftyBeaver

@MainActor
public class AppManager: ObservableObject {
    public enum DefaultKey: String {
        case activeProfileId
        
        case launchesOnLogin
        
        case isShowingFavorites
        
        case confirmsQuit
        
        case logFormat
        
        case tunnelLogFormat
        
        case masksPrivateData
        
        case didHandleSubreddit
        
        // internal use
        
        case persistenceAuthor
        
        case didMigrateToV2
    }
    
    private let defaults: UserDefaults = .standard
    
    public var logLevel: SwiftyBeaver.Level = .info
    
    public var logFile: URL?
    
    // MARK: State
    
    @Published public private(set) var isDoingMigrations = true

    public init() {
        defaults.register(keyedDefaults: [
            .activeProfileId: nil,
            .launchesOnLogin: false,
            .isShowingFavorites: false,
            .confirmsQuit: true,
            .logFormat: nil,
            .tunnelLogFormat: nil,
            .masksPrivateData: true,
            .didHandleSubreddit: false,
            //
            .didMigrateToV2: false
        ])

        // set once
        if persistenceAuthor == nil {
            persistenceAuthor = UUID().uuidString
        }
    }
    
    public func configureLogging() {
        let console = ConsoleDestination()
        console.minLevel = logLevel
//        console.useNSLog = true
        if let logFormat = logFormat {
            console.format = logFormat
        }
        SwiftyBeaver.addDestination(console)
        
        if let fileURL = logFile {
            let file = FileDestination()
            file.minLevel = logLevel
            file.logFileURL = fileURL
            if let logFormat = logFormat {
                file.format = logFormat
            }
            _ = file.deleteLogFile()
            SwiftyBeaver.addDestination(file)
        }

        CoreConfiguration.masksPrivateData = masksPrivateData
    }
    
    public func doMigrations(_ profileManager: ProfileManager) {
//        profileManager.removeAllProfiles()
        guard didMigrateToV2 else {
            isDoingMigrations = true
            let migrated = doMigrateToV2()
            if !migrated.isEmpty {
                pp_log.info("Migrating \(migrated.count) profiles")
                migrated.forEach {
                    var profile = $0
                    if profileManager.isExistingProfile(withName: profile.header.name) {
                        profile = profile.renamedUniquely(withLastUpdate: true)
                    }
                    profileManager.saveProfile(profile, isActive: nil)
                }
            } else {
                pp_log.info("Nothing to migrate!")
            }
            isDoingMigrations = false

            didMigrateToV2 = true
            return
        }
        isDoingMigrations = false
    }
    
    // MARK: Current state
    
    public var preferences: AppPreferences {
        return DefaultAppPreferences(
            activeProfileId: activeProfileId,
            logFormat: logFormat,
            tunnelLogFormat: tunnelLogFormat,
            masksPrivateData: masksPrivateData
        )
    }
}

extension AppManager: AppPreferences {
    public var activeProfileId: UUID? {
        get {
            guard let uuidString = defaults.string(forKey: DefaultKey.activeProfileId.rawValue) else {
                return nil
            }
            return UUID(uuidString: uuidString)
        }
        set {
            defaults.set(newValue?.uuidString, forKey: DefaultKey.activeProfileId.rawValue)
            defaults.synchronize()
            objectWillChange.send()
        }
    }
    
    public var logFormat: String? {
        get {
            defaults.string(forKey: DefaultKey.logFormat.rawValue)
        }
        set {
            defaults.set(newValue, forKey: DefaultKey.logFormat.rawValue)
            objectWillChange.send()
        }
    }

    public var tunnelLogFormat: String? {
        get {
            defaults.string(forKey: DefaultKey.tunnelLogFormat.rawValue)
        }
        set {
            defaults.set(newValue, forKey: DefaultKey.tunnelLogFormat.rawValue)
            objectWillChange.send()
        }
    }

    public var masksPrivateData: Bool {
        get {
            defaults.bool(forKey: DefaultKey.masksPrivateData.rawValue)
        }
        set {
            defaults.set(newValue, forKey: DefaultKey.masksPrivateData.rawValue)
            CoreConfiguration.masksPrivateData = newValue

            objectWillChange.send()
        }
    }
    
    // MARK: Internal use (readonly)

    public private(set) var persistenceAuthor: String? {
        get {
            defaults.string(forKey: DefaultKey.persistenceAuthor.rawValue)
        }
        set {
            defaults.set(newValue, forKey: DefaultKey.persistenceAuthor.rawValue)
        }
    }
    
    public internal(set) var didMigrateToV2: Bool {
        get {
            defaults.bool(forKey: DefaultKey.didMigrateToV2.rawValue)
        }
        set {
            defaults.set(newValue, forKey: DefaultKey.didMigrateToV2.rawValue)
        }
    }
}

private extension UserDefaults {
    func register(keyedDefaults: [AppManager.DefaultKey: Any?]) {
        let mapped = keyedDefaults.reduce(into: [String: Any]()) {
            $0[$1.key.rawValue] = $1.value
        }
        register(defaults: mapped)
    }
}
