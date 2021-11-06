//
//  ConnectionService.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/3/18.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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
import NetworkExtension
import SwiftyBeaver
import TunnelKit
import TunnelKitOpenVPN
import PassepartoutConstants

private let log = SwiftyBeaver.self

public protocol ConnectionServiceDelegate: AnyObject {
    func connectionService(didAdd profile: ConnectionProfile)

    func connectionService(didRename profile: ConnectionProfile, to newTitle: String)

    func connectionService(didRemoveProfileWithKey key: ProfileKey)

    func connectionService(willDeactivate profile: ConnectionProfile)

    func connectionService(didActivate profile: ConnectionProfile)

    func connectionService(didUpdate profile: ConnectionProfile)
}

public class ConnectionService: Codable {
    public enum CodingKeys: String, CodingKey {
        case build
        
        case appGroup
        
        case baseConfiguration
        
        case activeProfileKey
        
        case preferences
        
        case hostTitles
    }
    
    public struct NotificationKeys {
        public static let dataCount = "DataCount"
    }

    public static let didUpdateDataCount = Notification.Name("ConnectionServiceDidUpdateDataCount")

    public var rootURL: URL {
        return GroupConstants.App.documentsURL
    }
    
    var providersURL: URL {
        return rootURL.appendingPathComponent(AppConstants.Store.providersDirectory)
    }

    var hostsURL: URL {
        return rootURL.appendingPathComponent(AppConstants.Store.hostsDirectory)
    }
    
    private var build: Int
    
    private let appGroup: String
    
    private let defaults: UserDefaults

    private let keychain: Keychain
    
    public var baseConfiguration: OpenVPNProvider.Configuration
    
    private var cache: [ProfileKey: ConnectionProfile]
    
    // XXX: access needed by +Migration
    var hostTitles: [String: String]
    
    public internal(set) var activeProfileKey: ProfileKey? {
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
    
    public var activeProfile: ConnectionProfile? {
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
    
    public let preferences: EditablePreferences
    
    public weak var delegate: ConnectionServiceDelegate?
    
    public init(withAppGroup appGroup: String, baseConfiguration: OpenVPNProvider.Configuration) {
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
        hostTitles = [:]

        ensureDirectoriesExistence()
    }
    
    // MARK: Codable

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let appGroup = try container.decode(String.self, forKey: .appGroup)
        guard let defaults = UserDefaults(suiteName: appGroup) else {
            fatalError("No entitlements for group '\(appGroup)'")
        }
        build = try container.decode(Int.self, forKey: .build)
        self.appGroup = appGroup
        self.defaults = defaults
        keychain = Keychain(group: appGroup)

        baseConfiguration = try container.decode(OpenVPNProvider.Configuration.self, forKey: .baseConfiguration)
        activeProfileKey = try container.decodeIfPresent(ProfileKey.self, forKey: .activeProfileKey)
        preferences = try container.decode(EditablePreferences.self, forKey: .preferences)

        cache = [:]
        hostTitles = try container.decode([String: String].self, forKey: .hostTitles)

        ensureDirectoriesExistence()
    }
    
    public func encode(to encoder: Encoder) throws {
        build = GroupConstants.App.buildNumber
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(build, forKey: .build)
        try container.encode(appGroup, forKey: .appGroup)
        try container.encode(baseConfiguration, forKey: .baseConfiguration)
        try container.encodeIfPresent(activeProfileKey, forKey: .activeProfileKey)
        try container.encode(preferences, forKey: .preferences)
        try container.encode(hostTitles, forKey: .hostTitles)
    }
    
    // MARK: Serialization
    
    public func loadProfiles() {
        let fm = FileManager.default
        do {
            let files = try fm.contentsOfDirectory(at: providersURL, includingPropertiesForKeys: nil, options: [])
//            log.debug("Found \(files.count) provider files: \(files)")
            for entry in files {
                guard let id = ConnectionService.profileId(fromURL: entry) else {
                    continue
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
        
        // clean up hostTitles if necessary
        let staleHostIds = hostTitles.keys.filter { cache[ProfileKey(.host, $0)] == nil }
        staleHostIds.forEach {
            hostTitles.removeValue(forKey: $0)
        }
    }
    
    public func saveProfiles() {
        let encoder = JSONEncoder()
        for profile in cache.values {
            saveProfile(profile, withEncoder: encoder)
        }
    }
    
    private func ensureDirectoriesExistence() {
        let fm = FileManager.default
        do {
            try fm.createDirectory(at: providersURL, withIntermediateDirectories: false, attributes: nil)
        } catch let e {
            log.warning("Could not create providers folder: \(e) (\(providersURL))")
        }
        do {
            try fm.createDirectory(at: hostsURL, withIntermediateDirectories: false, attributes: nil)
        } catch let e {
            log.warning("Could not create hosts folder: \(e) (\(hostsURL))")
        }
        
    }
    
    private func saveProfile(_ profile: ConnectionProfile, withEncoder encoder: JSONEncoder) {
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
    
    public func profile(withContext context: Context, id: String) -> ConnectionProfile? {
        return profile(withKey: ProfileKey(context, id))
    }
    
    public func profile(withKey key: ProfileKey) -> ConnectionProfile? {
        var profile = cache[key]
        if let _ = profile as? PlaceholderConnectionProfile {
            let decoder = JSONDecoder()
            do {
                let data = try profileData(key)
                switch key.context {
                case .provider:
                    let providerProfile = try decoder.decode(ProviderConnectionProfile.self, from: data)
                    
                    // XXX: fix renamed presets, fall back to default
                    if providerProfile.preset == nil {
                        providerProfile.presetId = providerProfile.infrastructure.defaults.preset
                    }
                    
                    // XXX: fix renamed pool, fall back to default
                    if providerProfile.pool == nil, let fallbackPool = providerProfile.infrastructure.defaultPool() {
                        providerProfile.poolId = fallbackPool.id
                    }
                    
                    // XXX: fix unsupported preset
                    providerProfile.setSupportedPreset()
                    
                    // XXX: patch empty favorites
                    if providerProfile.favoriteGroupIds == nil {
                        providerProfile.favoriteGroupIds = []
                    }

                    profile = providerProfile
                    
                case .host:
                    let hostProfile = try decoder.decode(HostConnectionProfile.self, from: data)

                    profile = hostProfile
                }
                cache[key] = profile
            } catch let e {
                log.error("Could not decode profile JSON: \(e)")
                
//                // drop corrupt cache entry
//                cache.removeValue(forKey: key)
//                try? FileManager.default.removeItem(at: profileURL(key))
                
                return nil
            }
        }
        
        // XXX: preload trusted networks in a backwards compatible manner (deserialization)
        if profile?.trustedNetworks == nil {
            profile?.trustedNetworks = TrustedNetworks()
        }

        // propagate delegate
        profile?.serviceDelegate = delegate
        return profile
    }
    
    public func allProfileKeys() -> [ProfileKey] {
        return Array(cache.keys)
    }
    
    public func ids(forContext context: Context) -> [String] {
        return cache.keys.filter { $0.context == context }.map { $0.id }
    }
    
    public func contextURL(_ key: ProfileKey) -> URL {
        switch key.context {
        case .provider:
            return providersURL
            
        case .host:
            return hostsURL
        }
    }
    
    public func profileURL(_ key: ProfileKey) -> URL {
        return contextURL(key).appendingPathComponent(key.id).appendingPathExtension("json")
    }
    
    public func profileData(_ key: ProfileKey) throws -> Data {
        return try Data(contentsOf: profileURL(key))
    }
    
    private static func profileId(fromURL url: URL) -> String? {
        guard url.pathExtension == "json" else {
            return nil
        }
        return url.deletingPathExtension().lastPathComponent
    }
    
    // MARK: Profiles

    public func hasProfiles() -> Bool {
        return !cache.isEmpty
    }
    
    public func addProfile(_ profile: ConnectionProfile, credentials: Credentials?) -> Bool {
        guard cache.index(forKey: ProfileKey(profile)) == nil else {
            return false
        }
        addOrReplaceProfile(profile, credentials: credentials)
        return true
    }
    
    public func addOrReplaceProfile(_ profile: ConnectionProfile, credentials: Credentials?, title: String? = nil) {
        let key = ProfileKey(profile)
        cache[key] = profile
        if key.context == .host {
            hostTitles[key.id] = title
        }
        try? setCredentials(credentials, for: profile)

        if cache.count == 1 {
            activeProfileKey = key
        }
        delegate?.connectionService(didAdd: profile)

        // serialization (can fail)
        saveProfile(profile, withEncoder: JSONEncoder())
    }

    public func renameProfile(_ key: ProfileKey, to newTitle: String) {
        precondition(key.context == .host, "Can only rename a HostConnectionProfile")
        guard let profile = cache[key] else {
            return
        }

        hostTitles[key.id] = newTitle
        delegate?.connectionService(didRename: profile, to: newTitle)
    }

    public func renameProfile(_ profile: ConnectionProfile, to newTitle: String) {
        renameProfile(ProfileKey(profile), to: newTitle)
    }
    
    public func removeProfile(_ key: ProfileKey) {
        guard let profile = cache[key] else {
            return
        }

        if key == activeProfileKey {
            activeProfileKey = nil
        }
        cache.removeValue(forKey: key)
        if key.context == .host {
            hostTitles.removeValue(forKey: key.id)
        }
        removeCredentials(for: profile)

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
    
    public func containsProfile(_ key: ProfileKey) -> Bool {
        return cache.index(forKey: key) != nil
    }

    public func containsProfile(_ profile: ConnectionProfile) -> Bool {
        return containsProfile(ProfileKey(profile))
    }
    
    public func hasActiveProfile() -> Bool {
        return activeProfileKey != nil
    }

    public func isActiveProfile(_ key: ProfileKey) -> Bool {
        return key == activeProfileKey
    }
    
    public func isActiveProfile(_ profile: ConnectionProfile) -> Bool {
        return isActiveProfile(ProfileKey(profile))
    }
    
    public func activateProfile(_ profile: ConnectionProfile) {
        activeProfileKey = ProfileKey(profile)
    }
    
    public func existingHostId(withTitle title: String) -> String? {
        for id in hostTitles.keys {
            guard let _ = cache[ProfileKey(.host, id)] else {
                continue
            }
            if hostTitles[id] == title {
                return id
            }
        }
        return nil
    }
    
    public func hostProfile(withTitle title: String) -> HostConnectionProfile? {
        guard let id = existingHostId(withTitle: title) else {
            return nil
        }
        return profile(withContext: .host, id: id) as? HostConnectionProfile
    }
    
    // MARK: Credentials
    
    public func needsCredentials(for profile: ConnectionProfile) -> Bool {
        guard profile.requiresCredentials else {
            return false
        }
        guard let creds = credentials(for: profile) else {
            return true
        }
        return !creds.isValid
    }
    
    public func credentials(for profile: ConnectionProfile) -> Credentials? {
        guard let username = profile.username else {
            return nil
        }
        let password = (try? keychain.password(for: username, context: profile.passwordContext)) ?? "" // make password optional
        return Credentials(username, password)
    }
    
    public func setCredentials(_ credentials: Credentials?, for profile: ConnectionProfile) throws {
        profile.username = credentials?.username
        try profile.setPassword(credentials?.password, in: keychain)
    }
    
    public func removeCredentials(for profile: ConnectionProfile) {
        profile.removePassword(in: keychain)
    }
    
    // MARK: VPN
    
    public func vpnConfiguration() throws -> NetworkExtensionVPNConfiguration {
        guard let profile = activeProfile else {
            throw ApplicationError.missingProfile
        }
        let creds = credentials(for: profile)
        if profile.requiresCredentials {
            guard creds != nil else {
                throw ApplicationError.missingCredentials
            }
        }
        
        var cfg = try profile.generate(from: baseConfiguration, preferences: preferences)
        
        // override network settings
        if let choices = profile.networkChoices, let settings = profile.manualNetworkSettings {
            var builder = cfg.builder()
            var sessionBuilder = builder.sessionConfiguration.builder()

            // enforce default gateway for providers unless "Manual"
            if type(of: profile) == ProviderConnectionProfile.self {
                if choices.gateway == .manual {
                    sessionBuilder.applyGateway(from: choices, settings: settings)
                }
            } else {
                sessionBuilder.applyGateway(from: choices, settings: settings)
            }
            
            sessionBuilder.applyDNS(from: choices, settings: settings)
            sessionBuilder.applyProxy(from: choices, settings: settings)
            sessionBuilder.applyMTU(from: choices, settings: settings)
            builder.sessionConfiguration = sessionBuilder.build()
            cfg = builder.build()
        }

        let protocolConfiguration = try cfg.generatedTunnelProtocol(
            withBundleIdentifier: AppConstants.App.tunnelBundleId,
            appGroup: appGroup,
            context: profile.passwordContext,
            username: creds?.username
        )
        protocolConfiguration.disconnectOnSleep = preferences.disconnectsOnSleep

        log.verbose("Configuration:")
        log.verbose(protocolConfiguration)
        
        var rules: [NEOnDemandRule] = []
        do {
            try ProductManager.shared.verifyEligible(forFeature: .trustedNetworks)
            #if os(iOS)
            if profile.trustedNetworks.includesMobile {
                let rule = policyRule(for: profile)
                rule.interfaceTypeMatch = .cellular
                rules.append(rule)
            }
            #else
            if profile.trustedNetworks.includesEthernet {
                let rule = policyRule(for: profile)
                rule.interfaceTypeMatch = .ethernet
                rules.append(rule)
            }
            #endif
            let reallyTrustedWifis = Array(profile.trustedNetworks.includedWiFis.filter { $1 }.keys)
            if !reallyTrustedWifis.isEmpty {
                let rule = policyRule(for: profile)
                rule.interfaceTypeMatch = .wiFi
                rule.ssidMatch = reallyTrustedWifis
                rules.append(rule)
            }
        } catch {
        }
        let connection = NEOnDemandRuleConnect()
        connection.interfaceTypeMatch = .any
        rules.append(connection)
        
        return NetworkExtensionVPNConfiguration(
            title: screenTitle(ProfileKey(profile)),
            protocolConfiguration: protocolConfiguration,
            onDemandRules: rules
        )
    }
    
    private func policyRule(for profile: ConnectionProfile) -> NEOnDemandRule {
        switch profile.trustedNetworks.policy {
        case .ignore:
            return NEOnDemandRuleIgnore()
            
        case .disconnect:
            return NEOnDemandRuleDisconnect()
        }
    }
    
    public var vpnLog: String {
        return baseConfiguration.existingLog(in: appGroup) ?? ""
    }
    
    public func eraseVpnLog() {
        log.info("Erasing VPN log...")
        guard let url = baseConfiguration.urlForLog(in: appGroup) else {
            return
        }
        try? FileManager.default.removeItem(at: url)
    }

    public var vpnLastError: OpenVPNProviderError? {
        return baseConfiguration.lastError(in: appGroup)
    }
    
    public func clearVpnLastError() {
        baseConfiguration.clearLastError(in: appGroup)
    }

    public func observeVPNDataCount(milliseconds: Int) {
        reportDataCountAndRepeat(after: milliseconds)
    }
    
    private func reportDataCountAndRepeat(after milliseconds: Int) {
        reportDataCount()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds)) { [weak self] in
            self?.reportDataCountAndRepeat(after: milliseconds)
        }
    }

    private func reportDataCount() {
        guard let dataCount = vpnDataCount else {
            return
        }
        NotificationCenter.default.post(name: ConnectionService.didUpdateDataCount, object: nil, userInfo: [NotificationKeys.dataCount: dataCount])
    }

    public var vpnDataCount: (Int, Int)? {
        return baseConfiguration.dataCount(in: appGroup)
    }
}

public extension ConnectionService {
    func providerNames() -> [InfrastructureName] {
        return ids(forContext: .provider)
    }
    
    func hostIds() -> [String] {
        return ids(forContext: .host)
    }

    func sortedProviderNames() -> [InfrastructureName] {
        return providerNames().sorted()
    }

    func sortedHostIds() -> [String] {
        return hostIds().sorted {
            let title1 = screenTitle(ProfileKey(.host, $0))
            let title2 = screenTitle(ProfileKey(.host, $1))
            return title1.lowercased() < title2.lowercased()
        }
    }

    func screenTitle(forHostId id: String) -> String {
        return screenTitle(ProfileKey(.host, id))
    }

    func screenTitle(forProviderName name: InfrastructureName) -> String {
        return screenTitle(ProfileKey(.provider, name))
    }

    func screenTitle(_ key: ProfileKey) -> String {
        switch key.context {
        case .provider:
            if let metadata = InfrastructureFactory.shared.metadata(forName: key.id) {
                return metadata.description
            }
            
        case .host:
            if let title = hostTitles[key.id] {
                return title
            }
        }
        return key.id
    }
}
