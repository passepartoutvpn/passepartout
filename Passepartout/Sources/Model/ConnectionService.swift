//
//  ConnectionService.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/3/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
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
    func connectionService(didActivate profile: ConnectionProfile)

    func connectionService(didDeactivate profile: ConnectionProfile)
}

class ConnectionService: Codable {
    enum CodingKeys: String, CodingKey {
        case appGroup
        
        case tunnelConfiguration
        
        case profiles
        
        case activeProfileId
        
        case preferences
    }

    private let appGroup: String
    
    private let defaults: UserDefaults

    private let keychain: Keychain
    
    var tunnelConfiguration: TunnelKitProvider.Configuration
    
    private var profiles: [String: ConnectionProfile]
    
    private var activeProfileId: String? {
        willSet {
            if let oldProfile = activeProfile {
                delegate?.connectionService(didDeactivate: oldProfile)
            }
        }
        didSet {
            if let newProfile = activeProfile {
                delegate?.connectionService(didActivate: newProfile)
            }
        }
    }
    
    var activeProfile: ConnectionProfile? {
        guard let id = activeProfileId else {
            return nil
        }
        return profiles[id]
    }
    
    let preferences: EditablePreferences
    
    weak var delegate: ConnectionServiceDelegate?
    
    init(withAppGroup appGroup: String, tunnelConfiguration: TunnelKitProvider.Configuration) {
        guard let defaults = UserDefaults(suiteName: appGroup) else {
            fatalError("No entitlements for group '\(appGroup)'")
        }
        self.appGroup = appGroup
        self.defaults = defaults
        keychain = Keychain(group: appGroup)

        self.tunnelConfiguration = tunnelConfiguration
        profiles = [:]
        activeProfileId = nil
        preferences = EditablePreferences()
    }
    
    // MARK: Codable

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let appGroup = try container.decode(String.self, forKey: .appGroup)
        guard let defaults = UserDefaults(suiteName: appGroup) else {
            fatalError("No entitlements for group '\(appGroup)'")
        }
        self.appGroup = appGroup
        self.defaults = defaults
        keychain = Keychain(group: appGroup)

        tunnelConfiguration = try container.decode(TunnelKitProvider.Configuration.self, forKey: .tunnelConfiguration)
        let profilesArray = try container.decode([ConnectionProfileHolder].self, forKey: .profiles).map { $0.contained }
        var profiles: [String: ConnectionProfile] = [:]
        profilesArray.forEach {
            guard let p = $0 else {
                return
            }
            profiles[p.id] = p
        }
        self.profiles = profiles
        activeProfileId = try container.decodeIfPresent(String.self, forKey: .activeProfileId)
        preferences = try container.decode(EditablePreferences.self, forKey: .preferences)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(appGroup, forKey: .appGroup)
        try container.encode(tunnelConfiguration, forKey: .tunnelConfiguration)
        try container.encode(profiles.map { ConnectionProfileHolder($0.value) }, forKey: .profiles)
        try container.encodeIfPresent(activeProfileId, forKey: .activeProfileId)
        try container.encode(preferences, forKey: .preferences)
    }
    
    // MARK: Profiles
    
    func profileIds() -> [String] {
        return Array(profiles.keys)
    }
    
    func profile(withId id: String) -> ConnectionProfile? {
        return profiles[id]
    }
    
    func addProfile(_ profile: ConnectionProfile, credentials: Credentials?) -> Bool {
        guard profiles.index(forKey: profile.id) == nil else {
            return false
        }
        addOrReplaceProfile(profile, credentials: credentials)
        return true
    }
    
    func addOrReplaceProfile(_ profile: ConnectionProfile, credentials: Credentials?) {
        profiles[profile.id] = profile
        try? setCredentials(credentials, for: profile)
        if profiles.count == 1 {
            activeProfileId = profile.id
        }
    }
    
    func removeProfile(_ profile: ConnectionProfile) {
        guard let i = profiles.index(forKey: profile.id) else {
            return
        }
        profiles.remove(at: i)
        if profiles.isEmpty {
            activeProfileId = nil
        }
    }
    
    func containsProfile(_ profile: ConnectionProfile) -> Bool {
        return profiles.index(forKey: profile.id) != nil
    }

    func hasActiveProfile() -> Bool {
        return activeProfileId != nil
    }

    func isActiveProfile(_ profile: ConnectionProfile) -> Bool {
        return profile.id == activeProfileId
    }
    
    func activateProfile(_ profile: ConnectionProfile) {
        activeProfileId = profile.id
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
    
    // MARK: VPN
    
    func vpnConfiguration() throws -> NetworkExtensionVPNConfiguration {
        guard let profile = activeProfile else {
            throw ApplicationError.missingProfile
        }
        guard let credentials = credentials(for: profile) else {
            throw ApplicationError.missingCredentials
        }
        
        let cfg = try profile.generate(from: tunnelConfiguration, preferences: preferences)
        let protocolConfiguration = try cfg.generatedTunnelProtocol(
            withBundleIdentifier: GroupConstants.App.tunnelIdentifier,
            appGroup: appGroup,
            hostname: profile.mainAddress,
            credentials: credentials
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
        guard let logKey = tunnelConfiguration.debugLogKey else {
            return ""
        }
        guard let lines = defaults.array(forKey: logKey) as? [String] else {
            return ""
        }
        return lines.joined(separator: "\n")
    }
    
//    func eraseVpnLog() {
//        defaults.removeObject(forKey: Keys.vpnLog)
//    }
}
