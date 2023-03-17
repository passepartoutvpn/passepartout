//
//  UpgradeManager+Migrations.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/20/22.
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
import GenericJSON
import TunnelKitCore
import TunnelKitOpenVPNCore
import TunnelKitManager
import PassepartoutCore
import PassepartoutUtils

private typealias Map = [String: Any]

// MARK: Migrate old store

extension UpgradeManager {
    fileprivate enum LegacyStoreKey: String, KeyStoreLocation, CaseIterable {
        case activeProfileId

        case launchesOnLogin

        case isStatusMenuEnabled

        case isShowingFavorites

        case confirmsQuit

        case logFormat

        case tunnelLogFormat

        case masksPrivateData

        case didHandleSubreddit

        case persistenceAuthor

        case didMigrateToV2

        case other1 = "MasksPrivateData"

        case other2 = "DidHandleSubreddit"

        case other3 = "Convenience.Reviewer.LastVersion"

        case other4 = "didMigrateKeychainContext"

        var key: String {
            rawValue
        }
    }

    func doMigrateStore(_ store: KeyValueStore) {
        if !didMigrateToV2 {
            guard let legacyDidMigrateToV2: Bool = store.value(forLocation: LegacyStoreKey.didMigrateToV2) else {
                return
            }
            didMigrateToV2 = legacyDidMigrateToV2
        }

        LegacyStoreKey.allCases.forEach {
            store.removeValue(forLocation: $0)
        }
    }
}

// MARK: Migrate to version 2

extension UpgradeManager {
    fileprivate enum MigrationError: Error {
        case json

        case missingId

        case missingOpenVPNConfiguration

        case missingHostname

        case missingEndpointProtocols

        case missingProviderName
    }

    private var appGroup: String {
        "group.com.algoritmico.Passepartout"
    }

    func doMigrateToV2() -> [Profile] {
        var migrated: [Profile] = []
        pp_log.info("Migrating data to v2")

        let fm = FileManager.default

        guard let documents = fm.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
            .appendingPathComponent("Documents") else {

            pp_log.info("No data to migrate")
            return []
        }

        let cs = documents.appendingPathComponent("ConnectionService.json")
        let hostsFolder = documents.appendingPathComponent("Hosts")
        let providersFolder = documents.appendingPathComponent("Providers")

        do {
            let csJSON = try cs.asJSON()
//            pp_log.error(csJSON)

            do {
                var authUserPassUUIDs: Set<String> = []

                for host in try fm.contentsOfDirectory(at: hostsFolder, includingPropertiesForKeys: nil) {
                    guard host.isFileURL && host.pathExtension == "ovpn" else {
                        continue
                    }

                    do {
                        let uuid = host.deletingPathExtension().lastPathComponent
                        let content = try String(contentsOf: host)

                        if content.contains("auth-user-pass") {
                            authUserPassUUIDs.insert(uuid)
                        }
                    } catch {
                        pp_log.warning("Unable to read host profile .ovpn: \(host)")
                    }
                }

//                print(">>> authUserPassUUIDs: \(authUserPassUUIDs)")

                for host in try fm.contentsOfDirectory(at: hostsFolder, includingPropertiesForKeys: nil) {
                    guard host.isFileURL && host.pathExtension == "json" else {
                        continue
                    }
                    do {
                        let json = try host.asJSON()
//                        pp_log.error(json)

                        let result = try migratedV1Profile(csJSON, hostMap: json, authUserPass: authUserPassUUIDs)
//                        pp_log.info(result.profile)
//                        print(">>> Account: \(result.profile.username) -> \(result.password)")

                        migrated.append(result)
                    } catch {
                        pp_log.warning("Unable to migrate host profile: \(host)")
                        continue
                    }
                }
            } catch {
                pp_log.warning(error)
            }

            do {
                for provider in try fm.contentsOfDirectory(at: providersFolder, includingPropertiesForKeys: nil) {
                    guard provider.isFileURL && provider.pathExtension == "json" else {
                        continue
                    }
                    do {
                        let json = try provider.asJSON()
//                        pp_log.error(json)

                        let result = try migratedV1Profile(csJSON, providerMap: json)
//                        pp_log.info(result.profile)
//                        print(">>> Account: \(result.profile.username) -> \(result.password)")

                        migrated.append(result)
                    } catch {
                        pp_log.warning("Unable to migrate provider profile: \(provider)")
                        continue
                    }
                }
            } catch {
                pp_log.warning(error)
            }
        } catch {
            pp_log.warning(error)
        }

        return migrated
    }

    // SHARED
    //
    // username/password ("username")
    // trusted networks ("trustedNetworks")
    // network settings ("networkChoices", "manualNetworkSettings")
    //

    // HOST
    //
    // provider configuration ("parameters") -- not crucial
    // custom endpoint ("parameters"?) -- not crucial
    // ovpn configuration ("parameters" -> "sessionConfiguration")
    //
    private func migratedV1Profile(_ cs: Map, hostMap: Map, authUserPass: Set<String>) throws -> Profile {
        guard let oldUUIDString = hostMap["id"] as? String else {
            throw MigrationError.missingId
        }

        let name = (cs["hostTitles"] as? Map)?[oldUUIDString] as? String ?? oldUUIDString
        let header = Profile.Header(name: name) // new UUID

        // configuration
        guard let params = hostMap["parameters"] as? Map else {
            throw MigrationError.missingOpenVPNConfiguration
        }
        guard var ovpn = params["sessionConfiguration"] as? Map else {
            throw MigrationError.missingOpenVPNConfiguration
        }
        guard let hostname = ovpn["hostname"] as? String else {
            throw MigrationError.missingHostname
        }
        guard let rawEps = ovpn["endpointProtocols"] as? [String] else {
            throw MigrationError.missingEndpointProtocols
        }
        let eps = rawEps.compactMap(EndpointProtocol.init(rawValue:))
        var remotes: [String] = []
        eps.forEach {
            remotes.append("\(hostname):\($0)")
        }
        ovpn["remotes"] = remotes
        ovpn["authUserPass"] = authUserPass.contains(oldUUIDString)
        let cfg = try JSON(ovpn).decode(OpenVPN.Configuration.self)

        // keychain
        let username = hostMap["username"] as? String ?? ""
        let password = migratedV1Password(forProfileId: oldUUIDString, profileType: "host", username: username)

        var profile = Profile(header, configuration: cfg)
        var account = Profile.Account()
        account.username = username
        account.password = password
        profile.account = account

        // shared
        profile.onDemand = migratedV1TrustedNetworks(hostMap)
        profile.networkSettings = migratedV1NetworkSettings(hostMap)

        return profile
    }

    // HOST
    //
    // poolId -- not crucial
    // presetId
    // favoriteGroupIds
    //
    private func migratedV1Profile(_ cs: Map, providerMap: Map) throws -> Profile {
        guard let name = providerMap["name"] as? String else {
            throw MigrationError.missingProviderName
        }

        let header = Profile.Header(name: name, providerName: name)
        var provider = Profile.Provider(name)

        // keychain
        var account = Profile.Account()
        account.username = providerMap["username"] as? String ?? ""
        account.password = migratedV1Password(forProfileId: name, profileType: "provider", username: account.username)

        // provider configuration
        var settings = Profile.Provider.Settings()
        if let apiId = providerMap["poolId"] as? String {
            settings.serverId = ProviderServer.id(withName: name, vpnProtocol: .openVPN, apiId: apiId)
        }
        settings.presetId = providerMap["presetId"] as? String
        settings.favoriteLocationIds = Set((providerMap["favoriteGroupIds"] as? [String])?.compactMap {
            "\(name):\($0.replacingOccurrences(of: "/", with: ":"))"
        } ?? [])
        settings.account = account
        provider.vpnSettings[.openVPN] = settings

        var profile = Profile(header, provider: provider)

        // shared
        profile.onDemand = migratedV1TrustedNetworks(providerMap)
        profile.networkSettings = migratedV1NetworkSettings(providerMap)

        return profile
    }

    private func migratedV1Password(forProfileId profileId: String, profileType: String, username: String) -> String {
        let keychain = Keychain(group: appGroup)
        let passwordContext = "\(Bundle.main.bundleIdentifier!).\(profileType).\(profileId)"
        do {
            return try keychain.password(for: username, context: passwordContext)
        } catch {
            return ""
        }
    }

    private func migratedV1TrustedNetworks(_ map: Map) -> Profile.OnDemand {
        var onDemand = Profile.OnDemand()
        onDemand.isEnabled = true
        if let trusted = map["trustedNetworks"] as? Map {
            onDemand.withMobileNetwork = trusted["includesMobile"] as? Bool ?? false
            onDemand.withEthernetNetwork = trusted["includesEthernet"] as? Bool ?? false
            onDemand.withSSIDs = trusted["includedWiFis"] as? [String: Bool] ?? [:]
            if let rawPolicy = trusted["policy"] as? String, let policy = Profile.OnDemand.Policy(rawValue: rawPolicy) {
                onDemand.policy = policy
            }
        }
        return onDemand
    }

    private func migratedV1NetworkSettings(_ map: Map) -> Profile.NetworkSettings {
        var settings = Profile.NetworkSettings()

        if let choices = map["networkChoices"] as? Map {
            settings.gateway.choice = migratedV1Choice(choices, key: "gateway")
            settings.dns.choice = migratedV1Choice(choices, key: "dns")
            settings.proxy.choice = migratedV1Choice(choices, key: "proxy")
            settings.mtu.choice = migratedV1Choice(choices, key: "mtu")
        }

        if let manual = map["manualNetworkSettings"] as? Map {

            // gateway
            settings.gateway.isDefaultIPv4 = (manual["gatewayPolicies"] as? [String])?.contains("IPv4") ?? false
            settings.gateway.isDefaultIPv6 = (manual["gatewayPolicies"] as? [String])?.contains("IPv6") ?? false

            // dns
            (manual["dnsProtocol"] as? String).map {
                settings.dns.configurationType = .init(rawValue: $0) ?? .plain
            }
            settings.dns.dnsServers = manual["dnsServers"] as? [String] ?? []
            settings.dns.dnsSearchDomains = manual["dnsSearchDomains"] as? [String] ?? []
            (manual["dnsHTTPSURL"] as? String).map {
                settings.dns.dnsHTTPSURL = URL(string: $0)
            }
            settings.dns.dnsTLSServerName = manual["dnsTLSServerName"] as? String

            // proxy
            settings.proxy.proxyAddress = manual["proxyAddress"] as? String
            settings.proxy.proxyPort = manual["proxyPort"] as? UInt16
            (manual["proxyAutoConfigurationURL"] as? String).map {
                settings.proxy.proxyAutoConfigurationURL = URL(string: $0)
            }
            settings.proxy.proxyBypassDomains = manual["proxyBypassDomains"] as? [String] ?? []

            // mtu
            settings.mtu.mtuBytes = manual["mtuBytes"] as? Int ?? 0
        }

        return settings
    }

    private func migratedV1Choice(_ map: Map, key: String) -> Network.Choice {
        (map[key] as? String) == "manual" ? .manual : .automatic
    }
}

private extension URL {
    func asJSON() throws -> Map {
        let data = try Data(contentsOf: self)
        guard let json = try JSONSerialization.jsonObject(with: data) as? Map else {
            throw UpgradeManager.MigrationError.json
        }
        return json
    }
}
