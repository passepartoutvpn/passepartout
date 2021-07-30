//
//  ProfileCustomizationViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/19/19.
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

import Cocoa
import PassepartoutCore
import TunnelKit

protocol ProfileCustomization: AnyObject {
    var profile: ConnectionProfile? { get set }
    
    var delegate: ProfileCustomizationDelegate? { get set }
}

protocol ProfileCustomizationDelegate: AnyObject {
    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateEndpointWithAddress newAddress: String?)

    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateEndpointWithProtocol newEndpointProtocol: EndpointProtocol?)
    
    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdatePreset newPreset: InfrastructurePreset)

    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateConfiguration newConfiguration: OpenVPN.ConfigurationBuilder)
    
    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateTrustedNetworks newTrustedNetworks: TrustedNetworks)

    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateGateway choice: NetworkChoice, withManualSettings newSettings: ProfileNetworkSettings)

    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateDNS choice: NetworkChoice, withManualSettings newSettings: ProfileNetworkSettings)

    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateProxy choice: NetworkChoice, withManualSettings newSettings: ProfileNetworkSettings)

    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateMTU choice: NetworkChoice, withManualSettings newSettings: ProfileNetworkSettings)
}

class ProfileCustomizationContainerViewController: NSViewController {
    @IBOutlet private weak var buttonOK: NSButton!
    
    @IBOutlet private weak var buttonCancel: NSButton!
    
    fileprivate weak var endpointController: EndpointViewController?

    fileprivate weak var dnsController: DNSViewController?
    
    fileprivate weak var proxyController: ProxyViewController?
    
    var profile: ConnectionProfile?
    
    // MARK: Pending (provider)

    private var pendingAddress: String?

    private var pendingProtocol: EndpointProtocol?
    
    private var pendingPreset: InfrastructurePreset?
    
    // MARK: Pending (host)
    
    private var pendingParameters: OpenVPN.ConfigurationBuilder?

    // MARK: Pending
    
    private var pendingTrustedNetworks: TrustedNetworks?
    
    private var pendingChoices: ProfileNetworkChoices?

    private let pendingManualNetworkSettings = ProfileNetworkSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonOK.title = L10n.Core.Global.ok
        buttonCancel.title = L10n.Core.Global.cancel
        
        pendingAddress = (profile as? ProviderConnectionProfile)?.customAddress
        pendingProtocol = (profile as? ProviderConnectionProfile)?.customProtocol
        pendingPreset = (profile as? ProviderConnectionProfile)?.preset
        pendingTrustedNetworks = profile?.trustedNetworks
        pendingParameters = (profile as? HostConnectionProfile)?.parameters.sessionConfiguration.builder()
        pendingChoices = ProfileNetworkChoices.with(profile: profile)
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let customVC = segue.destinationController as? ProfileCustomizationViewController else {
            return
        }
        customVC.containerController = self
        customVC.profile = profile
    }
    
    // MARK: Actions
    
    @IBAction private func commitChanges(_ sender: Any?) {
        dnsController?.commitManualSettings()
        proxyController?.commitManualSettings()
        
        if let providerProfile = profile as? ProviderConnectionProfile {
            if let pending = pendingPreset {
                providerProfile.presetId = pending.id
            }
        } else if let hostProfile = profile as? HostConnectionProfile, let pendingParameters = pendingParameters {
            var builder = hostProfile.parameters.builder()
            builder.sessionConfiguration = pendingParameters.build()
            hostProfile.parameters = builder.build()
        }
        profile?.customAddress = pendingAddress
        profile?.customProtocol = pendingProtocol
        profile?.trustedNetworks = pendingTrustedNetworks
        
        if let choices = pendingChoices {
            let settings = profile?.manualNetworkSettings ?? ProfileNetworkSettings()
            if choices.gateway == .manual {
                settings.copyGateway(from: pendingManualNetworkSettings)
            }
            if choices.dns == .manual {
                settings.copyDNS(from: pendingManualNetworkSettings)
            }
            if choices.proxy == .manual {
                settings.copyProxy(from: pendingManualNetworkSettings)
            }
            if choices.mtu == .manual {
                settings.copyMTU(from: pendingManualNetworkSettings)
            }
            profile?.networkChoices = choices
            profile?.manualNetworkSettings = settings
        }
        
        TransientStore.shared.serialize(withProfiles: true) // customize

        if let profile = profile, TransientStore.shared.service.isActiveProfile(ProfileKey(profile)) {
            let vpn = GracefulVPN(service: TransientStore.shared.service)
            if vpn.isEnabled {
                switch vpn.status {
                case .connected, .connecting:
                    let alert = Macros.warning(
                        L10n.App.Configuration.title,
                        L10n.App.Configuration.Alerts.Commit.message
                    )
                    if alert.presentModally(
                        withOK: L10n.App.Configuration.Alerts.Commit.Buttons.reconnect,
                        cancel: L10n.App.Configuration.Alerts.Commit.Buttons.skip) {

                        vpn.reconnect(completionHandler: nil)
                    } else {
                        vpn.reinstall(completionHandler: nil)
                    }

                default:
                    vpn.reinstall(completionHandler: nil)
                }
            }
        }
        
        presentingViewController?.dismiss(self)
    }
}

extension ProfileCustomizationContainerViewController: ProfileCustomizationDelegate {
    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateEndpointWithAddress newAddress: String?) {
        pendingAddress = newAddress
    }

    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateEndpointWithProtocol newEndpointProtocol: EndpointProtocol?) {
        pendingProtocol = newEndpointProtocol
    }
    
    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdatePreset newPreset: InfrastructurePreset) {
        pendingPreset = newPreset

        // XXX: commit immediately to update endpoints
        (profile as? ProviderConnectionProfile)?.presetId = newPreset.id
        endpointController?.reloadEndpoints()
    }
    
    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateConfiguration newConfiguration: OpenVPN.ConfigurationBuilder) {
        pendingParameters = newConfiguration
    }
    
    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateTrustedNetworks newTrustedNetworks: TrustedNetworks) {
        pendingTrustedNetworks = newTrustedNetworks
    }
    
    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateGateway choice: NetworkChoice, withManualSettings newSettings: ProfileNetworkSettings) {
        pendingChoices?.gateway = choice
        pendingManualNetworkSettings.gatewayPolicies = newSettings.gatewayPolicies
    }
    
    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateDNS choice: NetworkChoice, withManualSettings newSettings: ProfileNetworkSettings) {
        pendingChoices?.dns = choice
        pendingManualNetworkSettings.dnsProtocol = newSettings.dnsProtocol
        pendingManualNetworkSettings.dnsHTTPSURL = newSettings.dnsHTTPSURL
        pendingManualNetworkSettings.dnsTLSServerName = newSettings.dnsTLSServerName
        pendingManualNetworkSettings.dnsServers = newSettings.dnsServers
        pendingManualNetworkSettings.dnsSearchDomains = newSettings.dnsSearchDomains
    }
    
    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateProxy choice: NetworkChoice, withManualSettings newSettings: ProfileNetworkSettings) {
        pendingChoices?.proxy = choice
        pendingManualNetworkSettings.proxyAddress = newSettings.proxyAddress
        pendingManualNetworkSettings.proxyPort = newSettings.proxyPort
        pendingManualNetworkSettings.proxyBypassDomains = newSettings.proxyBypassDomains
    }

    func profileCustomization(_ profileCustomization: ProfileCustomization, didUpdateMTU choice: NetworkChoice, withManualSettings newSettings: ProfileNetworkSettings) {
        pendingChoices?.mtu = choice
        pendingManualNetworkSettings.mtuBytes = newSettings.mtuBytes
    }
}

//

class ProfileCustomizationViewController: NSTabViewController {
    fileprivate weak var containerController: ProfileCustomizationContainerViewController?
    
    fileprivate var profile: ConnectionProfile? {
        didSet {
            for item in tabViewItems {
                guard let custom = item.viewController as? ProfileCustomization else {
                    continue
                }
                custom.profile = profile
                custom.delegate = containerController

                if let vc = custom as? EndpointViewController {
                    containerController?.endpointController = vc
                } else if let vc = custom as? DNSViewController {
                    containerController?.dnsController = vc
                } else if let vc = custom as? ProxyViewController {
                    containerController?.proxyController = vc
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let expectedTabs = 7
        assert(tabViewItems.count == expectedTabs, "Customization tabs misconfigured (expected \(expectedTabs))")

        tabViewItems[0].label = L10n.Core.Endpoint.title
        tabViewItems[1].label = L10n.App.Configuration.title
        tabViewItems[2].label = L10n.Core.Service.Sections.Trusted.header
        tabViewItems[3].label = L10n.Core.NetworkSettings.Gateway.title
        tabViewItems[4].label = L10n.Core.NetworkSettings.Dns.title
        tabViewItems[5].label = L10n.Core.NetworkSettings.Proxy.title
        tabViewItems[6].label = L10n.Core.NetworkSettings.Mtu.title
    }
}
