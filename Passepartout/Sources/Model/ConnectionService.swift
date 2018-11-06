//
//  ConnectionService.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/3/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
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
import NetworkExtension
import SwiftyBeaver

private let log = SwiftyBeaver.self

protocol ConnectionServiceDelegate: class {
    func connectionService(didAdd profile: ConnectionProfile)

    func connectionService(didRename oldProfile: ConnectionProfile, to newProfile: ConnectionProfile)

    func connectionService(didRemoveProfileWithKey key: ConnectionService.ProfileKey)

    func connectionService(willDeactivate profile: ConnectionProfile)

    func connectionService(didActivate profile: ConnectionProfile)
}

class ConnectionService: Codable {
    enum CodingKeys: String, CodingKey {
        case build
        
        case appGroup
        
        case baseConfiguration
        
        case activeProfileKey
        
        case preferences
    }

    struct ProfileKey: RawRepresentable, Hashable, Codable {
        let context: Context
        
        let id: String

        init(_ context: Context, _ id: String) {
            self.context = context
            self.id = id
        }

        init(_ profile: ConnectionProfile) {
            context = profile.context
            id = profile.id
        }
        
        // MARK: RawRepresentable
        
        var rawValue: String {
            return "\(context).\(id)"
        }
        
        init?(rawValue: String) {
            let comps = rawValue.components(separatedBy: ".")
            guard comps.count == 2 else {
                return nil
            }
            guard let context = Context(rawValue: comps[0]) else {
                return nil
            }
            self.context = context
            id = comps[1]
        }
    }

    var directory: String? = nil
    
    var rootURL: URL {
        return FileManager.default.userURL(for: .documentDirectory, appending: directory)
    }
    
    private var providersURL: URL {
        return rootURL.appendingPathComponent(AppConstants.Store.providersDirectory)
    }

    private var hostsURL: URL {
        return rootURL.appendingPathComponent(AppConstants.Store.hostsDirectory)
    }
    
    private var build: Int
    
    private let appGroup: String
    
    private let defaults: UserDefaults

    private let keychain: Keychain
    
    var baseConfiguration: TunnelKitProvider.Configuration
    
    private var cache: [ProfileKey: ConnectionProfile]
    
    private(set) var activeProfileKey: ProfileKey? {
        willSet {
            if let oldProfile = activeProfile {
                delegate?.connectionService(willDeactivate: oldProfile)
            }
        }
        didSet {
            if let newProfile = activeProfile {
                delegate?.connectionService(didActivate: newProfile)
            }
        }
    }
    
    var activeProfile: ConnectionProfile? {
        guard let id = activeProfileKey else {
            return nil
        }
        var hit = cache[id]
        if let placeholder = hit as? PlaceholderConnectionProfile {
            hit = profile(withContext: placeholder.context, id: placeholder.id)
            cache[id] = hit
        }
        return hit
    }
    
    let preferences: EditablePreferences
    
    weak var delegate: ConnectionServiceDelegate?
    
    init(withAppGroup appGroup: String, baseConfiguration: TunnelKitProvider.Configuration) {
        guard let defaults = UserDefaults(suiteName: appGroup) else {
            fatalError("No entitlements for group '\(appGroup)'")
        }
        build = GroupConstants.App.buildNumber
        self.appGroup = appGroup
        self.defaults = defaults
        keychain = Keychain(group: appGroup)

        self.baseConfiguration = baseConfiguration
        activeProfileKey = nil
        preferences = EditablePreferences()

        cache = [:]
    }
    
    // MARK: Codable

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let appGroup = try container.decode(String.self, forKey: .appGroup)
        guard let defaults = UserDefaults(suiteName: appGroup) else {
            fatalError("No entitlements for group '\(appGroup)'")
        }
        build = try container.decode(Int.self, forKey: .build)
        self.appGroup = appGroup
        self.defaults = defaults
        keychain = Keychain(group: appGroup)

        baseConfiguration = try container.decode(TunnelKitProvider.Configuration.self, forKey: .baseConfiguration)
        activeProfileKey = try container.decodeIfPresent(ProfileKey.self, forKey: .activeProfileKey)
        preferences = try container.decode(EditablePreferences.self, forKey: .preferences)

        cache = [:]
    }
    
    func encode(to encoder: Encoder) throws {
        build = GroupConstants.App.buildNumber
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(build, forKey: .build)
        try container.encode(appGroup, forKey: .appGroup)
        try container.encode(baseConfiguration, forKey: .baseConfiguration)
        try container.encodeIfPresent(activeProfileKey, forKey: .activeProfileKey)
        try container.encode(preferences, forKey: .preferences)
    }
    
    // MARK: Serialization
    
    func loadProfiles() {
        let fm = FileManager.default
        try? fm.createDirectory(at: providersURL, withIntermediateDirectories: false, attributes: nil)
        try? fm.createDirectory(at: hostsURL, withIntermediateDirectories: false, attributes: nil)
        
        do {
            let files = try fm.contentsOfDirectory(at: providersURL, includingPropertiesForKeys: nil, options: [])
//            log.debug("Found \(files.count) provider files: \(files)")
            for entry in files {
                guard let id = ConnectionService.profileId(fromURL: entry) else {
                    return
                }
                let key = ProfileKey(.provider, id)
                cache[key] = PlaceholderConnectionProfile(key)
            }
        } catch let e {
            log.warning("Could not list provider contents: \(e) (\(providersURL))")
        }
        do {
            let files = try fm.contentsOfDirectory(at: hostsURL, includingPropertiesForKeys: nil, options: [])
//            log.debug("Found \(files.count) host files: \(files)")
            for entry in files {
                guard let id = ConnectionService.profileId(fromURL: entry) else {
                    continue
                }
                let key = ProfileKey(.host, id)
                cache[key] = PlaceholderConnectionProfile(key)
            }
        } catch let e {
            log.warning("Could not list host contents: \(e) (\(hostsURL))")
        }
    }
    
    func saveProfiles() {
        let encoder = JSONEncoder()
        ensureDirectoriesExistence()

        for profile in cache.values {
            saveProfile(profile, withEncoder: encoder, checkDirectories: false)
        }
    }
    
    private func ensureDirectoriesExistence() {
        let fm = FileManager.default
        try? fm.createDirectory(at: providersURL, withIntermediateDirectories: false, attributes: nil)
        try? fm.createDirectory(at: hostsURL, withIntermediateDirectories: false, attributes: nil)
    }
    
    private func saveProfile(_ profile: ConnectionProfile, withEncoder encoder: JSONEncoder, checkDirectories: Bool) {
        if checkDirectories {
            ensureDirectoriesExistence()
        }
        do {
            let url = profileURL(ProfileKey(profile))
            var optData: Data?
            if let providerProfile = profile as? ProviderConnectionProfile {
                optData = try encoder.encode(providerProfile)
            } else if let hostProfile = profile as? HostConnectionProfile {
                optData = try encoder.encode(hostProfile)
            } else if let placeholder = profile as? PlaceholderConnectionProfile {
                log.debug("Skipped placeholder \(placeholder)")
            } else {
                fatalError("Attempting to add an unhandled profile type: \(type(of: profile))")
            }
            guard let data = optData else {
                return
            }
            try data.write(to: url)
            log.debug("Serialized profile \(profile)")
        } catch let e {
            log.warning("Could not serialize profile \(profile): \(e)")
        }
    }
    
    func profile(withContext context: Context, id: String) -> ConnectionProfile? {
        let key = ProfileKey(context, id)
        var profile = cache[key]
        if let _ = profile as? PlaceholderConnectionProfile {
            let decoder = JSONDecoder()
            do {
                let data = try profileData(key)
                switch context {
                case .provider:
                    profile = try decoder.decode(ProviderConnectionProfile.self, from: data)
                    
                case .host:
                    profile = try decoder.decode(HostConnectionProfile.self, from: data)
                }
                cache[key] = profile
            } catch let e {
                log.error("Could not decode profile JSON: \(e)")
                return nil
            }
        }
        return profile
    }
    
    func ids(forContext context: Context) -> [String] {
        return cache.keys.filter { $0.context == context }.map { $0.id }
    }
    
    func contextURL(_ key: ProfileKey) -> URL {
        switch key.context {
        case .provider:
            return providersURL
            
        case .host:
            return hostsURL
        }
    }
    
    func profileURL(_ key: ProfileKey) -> URL {
        return contextURL(key).appendingPathComponent(key.id).appendingPathExtension("json")
    }
    
    func profileData(_ key: ProfileKey) throws -> Data {
        return try Data(contentsOf: profileURL(key))
    }
    
    private static func profileId(fromURL url: URL) -> String? {
        guard url.pathExtension == "json" else {
            return nil
        }
        return url.deletingPathExtension().lastPathComponent
    }
    
    // MARK: Profiles

    func addProfile(_ profile: ConnectionProfile, credentials: Credentials?) -> Bool {
        guard cache.index(forKey: ProfileKey(profile)) == nil else {
            return false
        }
        addOrReplaceProfile(profile, credentials: credentials)
        return true
    }
    
    func addOrReplaceProfile(_ profile: ConnectionProfile, credentials: Credentials?) {
        let key = ProfileKey(profile)
        cache[key] = profile
        try? setCredentials(credentials, for: profile)
        if cache.count == 1 {
            activeProfileKey = key
        }
        delegate?.connectionService(didAdd: profile)

        // serialization (can fail)
        saveProfile(profile, withEncoder: JSONEncoder(), checkDirectories: true)
    }

    @discardableResult func renameProfile(_ key: ProfileKey, to newId: String) -> ConnectionProfile? {
        precondition(newId != key.id)

        // WARNING: can be a placeholder
        guard let oldProfile = cache[key] else {
            return nil
        }

        let fm = FileManager.default
        let temporaryDelegate = delegate
        delegate = nil

        // 1. add renamed profile
        let newProfile = oldProfile.with(newId: newId)
        let newKey = ProfileKey(newProfile)
        let sameCredentials = credentials(for: oldProfile)
        addOrReplaceProfile(newProfile, credentials: sameCredentials)

        // 2. rename .ovpn (if present)
        if let cfgFrom = configurationURL(for: key) {
            let cfgTo = targetConfigurationURL(for: newKey)
            try? fm.removeItem(at: cfgTo)
            try? fm.moveItem(at: cfgFrom, to: cfgTo)
        }

        // 3. remove old entry
        removeProfile(key)

        // 4. replace active key (if active)
        if key == activeProfileKey {
            activeProfileKey = newKey
        }

        delegate = temporaryDelegate
        delegate?.connectionService(didRename: oldProfile, to: newProfile)
        
        return newProfile
    }

    @discardableResult func renameProfile(_ profile: ConnectionProfile, to id: String) -> ConnectionProfile? {
        return renameProfile(ProfileKey(profile), to: id)
    }
    
    func removeProfile(_ key: ProfileKey) {
        guard let profile = cache[key] else {
            return
        }

        cache.removeValue(forKey: key)
        removeCredentials(for: profile)
        if cache.isEmpty {
            activeProfileKey = nil
        }
        
        delegate?.connectionService(didRemoveProfileWithKey: key)

        // serialization (can fail)
        do {
            let fm = FileManager.default
            if let cfg = configurationURL(for: key) {
                try? fm.removeItem(at: cfg)
            }
            let url = profileURL(key)
            try fm.removeItem(at: url)
            log.debug("Deleted removed profile '\(profile.id)'")
        } catch let e {
            log.warning("Could not delete profile '\(profile.id)': \(e)")
        }
    }
    
    func containsProfile(_ key: ProfileKey) -> Bool {
        return cache.index(forKey: key) != nil
    }

    func containsProfile(_ profile: ConnectionProfile) -> Bool {
        return containsProfile(ProfileKey(profile))
    }
    
    func hasActiveProfile() -> Bool {
        return activeProfileKey != nil
    }

    func isActiveProfile(_ key: ProfileKey) -> Bool {
        return key == activeProfileKey
    }
    
    func isActiveProfile(_ profile: ConnectionProfile) -> Bool {
        return isActiveProfile(ProfileKey(profile))
    }
    
    func activateProfile(_ profile: ConnectionProfile) {
        activeProfileKey = ProfileKey(profile)
    }
    
    // MARK: Credentials
    
    func needsCredentials(for profile: ConnectionProfile) -> Bool {
        guard profile.requiresCredentials else {
            return false
        }
        guard let creds = credentials(for: profile) else {
            return true
        }
        return creds.isEmpty
    }
    
    func credentials(for profile: ConnectionProfile) -> Credentials? {
        guard let username = profile.username, let key = profile.passwordKey else {
            return nil
        }
        guard let password = try? keychain.password(for: key) else {
            return nil
        }
        return Credentials(username, password)
    }
    
    func setCredentials(_ credentials: Credentials?, for profile: ConnectionProfile) throws {
        profile.username = credentials?.username
        try profile.setPassword(credentials?.password, in: keychain)
    }
    
    func removeCredentials(for profile: ConnectionProfile) {
        profile.removePassword(in: keychain)
    }
    
    // MARK: VPN
    
    func vpnConfiguration() throws -> NetworkExtensionVPNConfiguration {
        guard let profile = activeProfile else {
            throw ApplicationError.missingProfile
        }
        let creds = credentials(for: profile)
        if profile.requiresCredentials {
            guard creds != nil else {
                throw ApplicationError.missingCredentials
            }
        }
        
        let cfg = try profile.generate(from: baseConfiguration, preferences: preferences)
        let protocolConfiguration = try cfg.generatedTunnelProtocol(
            withBundleIdentifier: GroupConstants.App.tunnelIdentifier,
            appGroup: appGroup,
            hostname: profile.mainAddress,
            credentials: creds
        )
        protocolConfiguration.disconnectOnSleep = preferences.disconnectsOnSleep

        log.verbose("Configuration:")
        log.verbose(protocolConfiguration)
        
        var rules: [NEOnDemandRule] = []
        #if os(iOS)
        if preferences.trustsMobileNetwork {
            let rule = policyRule()
            rule.interfaceTypeMatch = .cellular
            rules.append(rule)
        }
        #endif
        let reallyTrustedWifis = Array(preferences.trustedWifis.filter { $1 }.keys)
        if !reallyTrustedWifis.isEmpty {
            let rule = policyRule()
            rule.interfaceTypeMatch = .wiFi
            rule.ssidMatch = reallyTrustedWifis
            rules.append(rule)
        }
        rules.append(NEOnDemandRuleConnect())
        
        return NetworkExtensionVPNConfiguration(protocolConfiguration: protocolConfiguration, onDemandRules: rules)
    }
    
    private func policyRule() -> NEOnDemandRule {
        switch preferences.trustPolicy {
        case .ignore:
            return NEOnDemandRuleIgnore()
            
        case .disconnect:
            return NEOnDemandRuleDisconnect()
        }
    }
    
    var vpnLog: String {
        return baseConfiguration.existingLog(in: appGroup) ?? ""
    }
    
    var vpnLastError: TunnelKitProvider.ProviderError? {
        return baseConfiguration.lastError(in: appGroup)
    }
    
    func clearVpnLastError() {
        baseConfiguration.clearLastError(in: appGroup)
    }
    
//    func eraseVpnLog() {
//        defaults.removeObject(forKey: Keys.vpnLog)
//    }
}
