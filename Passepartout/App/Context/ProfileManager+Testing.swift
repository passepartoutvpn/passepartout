//
//  ProfileManager+Testing.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/28/24.
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

import CommonLibrary
import Foundation
import PassepartoutKit

extension ProfileManager {
    public static func forUITesting(withRegistry registry: Registry, processor: ProfileProcessor) -> ProfileManager {
        let repository = InMemoryProfileRepository()
        let remoteRepository = InMemoryProfileRepository()
        let manager = ProfileManager(repository: repository, remoteRepositoryBlock: { _ in
            remoteRepository
        }, processor: processor)

        Task {
            do {
                try await manager.observeLocal()
                try await manager.observeRemote(true)

                for parameters in mockParameters {
                    var builder = Profile.Builder()
                    builder.name = parameters.name
                    builder.attributes.isAvailableForTV = parameters.isTV

                    for moduleType in parameters.moduleTypes {
                        var moduleBuilder = moduleType.newModule(with: registry, providerId: parameters.providerId)

                        if moduleBuilder.buildsConnectionModule {
                            assert((moduleBuilder as? any ProviderSelecting)?.providerId == parameters.providerId)
                        }

                        if parameters.name == "Hide.me" {
                            if var ovpnBuilder = moduleBuilder as? OpenVPNModule.Builder {
#if !os(tvOS)
                                ovpnBuilder.isInteractive = true
#endif
                                ovpnBuilder.providerEntity = mockHideMeEntity
                                moduleBuilder = ovpnBuilder
                            } else if var onDemandBuilder = moduleBuilder as? OnDemandModule.Builder {
#if !os(tvOS)
                                onDemandBuilder.isEnabled = true
#endif
                                onDemandBuilder.policy = .excluding
                                onDemandBuilder.withSSIDs = [
                                    "Friend's House": false,
                                    "My Home Network": true,
                                    "Safe Wi-Fi": true
                                ]
                                moduleBuilder = onDemandBuilder
                            } else if var dnsBuilder = moduleBuilder as? DNSModule.Builder {
                                dnsBuilder.protocolType = .https
                                dnsBuilder.dohURL = "https://cloudflare-dns.com/dns-query"
                                dnsBuilder.servers = ["1.1.1.1", "1.0.0.1"]
                                dnsBuilder.domainName = "my-domain.com"
                                dnsBuilder.searchDomains = ["search-one.com", "search-two.org"]
                                moduleBuilder = dnsBuilder
                            }
                        }

                        if parameters.name == "My VPS" {
                            if var ovpnBuilder = moduleBuilder as? OpenVPNModule.Builder {
                                var cfgBuilder = OpenVPN.Configuration.Builder()
                                cfgBuilder.ca = .init(pem: "...")
                                cfgBuilder.remotes = [
                                    ExtendedEndpoint(rawValue: "1.2.3.4:UDP:1234")!
                                ]
                                ovpnBuilder.configurationBuilder = cfgBuilder
                                moduleBuilder = ovpnBuilder
                            } else if var onDemandBuilder = moduleBuilder as? OnDemandModule.Builder {
                                onDemandBuilder.isEnabled = true
                                moduleBuilder = onDemandBuilder
                            }
                        }

                        let module = try moduleBuilder.tryBuild()
                        builder.modules.append(module)
                    }
                    builder.activateAllModules()

                    let profile = try builder.tryBuild()
                    try await manager.save(profile, isLocal: true, remotelyShared: parameters.isShared)
                }
            } catch {
                pp_log(.App.profiles, .error, "Unable to build ProfileManager for UI testing: \(error)")
            }
        }

        return manager
    }
}

private extension ProfileManager {
    struct Parameters {
        let name: String

        let isShared: Bool

        let isTV: Bool

        let moduleTypes: [ModuleType]

        let providerId: ProviderID?

        init(_ name: String, _ isShared: Bool, _ isTV: Bool, _ moduleTypes: [ModuleType], _ providerId: ProviderID? = nil) {
            self.name = name
            self.isShared = isShared
            self.isTV = isTV
            self.moduleTypes = moduleTypes
            self.providerId = providerId
        }
    }

    static let mockParameters: [Parameters] = [
        Parameters("CloudFlare DoT", false, false, [.dns]),
        Parameters("Coffee VPN", true, false, [.wireGuard, .onDemand]),
        Parameters("Hide.me", true, true, [.openVPN, .onDemand, .dns, .ip], .hideme),
        Parameters("My VPS", true, true, [.openVPN, .onDemand]),
        Parameters("Office", true, false, [.onDemand, .httpProxy]),
        Parameters("Personal DoH", false, false, [.dns, .onDemand])
    ]

    static var mockHideMeEntity: VPNEntity<OpenVPN.Configuration> {
        do {
            var cfgBuilder = OpenVPN.Configuration.Builder()
            cfgBuilder.ca = .init(pem: "...")
            let cfg = try cfgBuilder.tryBuild(isClient: false)
            let cfgData = try JSONEncoder().encode(cfg)

            let preset = AnyVPNPreset(
                providerId: .hideme,
                presetId: "default",
                description: "Default",
                endpoints: [.init(.udp, 1194)],
                configurationIdentifier: "OpenVPN",
                configuration: cfgData
            )

            return VPNEntity(
                server: .init(
                    provider: .init(
                        id: .hideme,
                        serverId: "be-v4",
                        supportedConfigurationIdentifiers: ["OpenVPN"],
                        supportedPresetIds: nil,
                        categoryName: "",
                        countryCode: "BE",
                        otherCountryCodes: nil,
                        area: nil
                    ),
                    hostname: "be-v4.hideservers.net",
                    ipAddresses: nil
                ),
                preset: try preset.ofType(OpenVPN.Configuration.self)
            )
        } catch {
            fatalError("Unable to build Hide.me entity: \(error)")
        }
    }
}
