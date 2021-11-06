//
//  DefaultGatewayViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/21/19.
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

class DefaultGatewayViewController: NSViewController, ProfileCustomization {
    @IBOutlet private weak var popupChoice: NSPopUpButton!
    
    @IBOutlet private weak var viewSettings: NSView!
    
    @IBOutlet private weak var checkIPv4: NSButton!
    
    @IBOutlet private weak var checkIPv6: NSButton!
    
    @IBOutlet private var constraintChoiceBottom: NSLayoutConstraint!
    
    @IBOutlet private var constraintSettingsTop: NSLayoutConstraint!
    
    private lazy var choices = NetworkChoice.choices(for: profile)

    private lazy var currentChoice = profile?.networkChoices?.gateway ?? ProfileNetworkChoices.with(profile: profile).gateway
    
    private lazy var clientNetworkSettings = profile?.clientNetworkSettings
    
    private let networkSettings = ProfileNetworkSettings()

    // MARK: ProfileCustomization
    
    var profile: ConnectionProfile?
    
    weak var delegate: ProfileCustomizationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIPv4.title = "IPv4"
        checkIPv6.title = "IPv6"
        
        popupChoice.removeAllItems()
        for choice in choices {
            popupChoice.addItem(withTitle: choice.description)
            if choice == currentChoice {
                popupChoice.selectItem(at: popupChoice.numberOfItems - 1)
            }
        }
        loadSettings(from: currentChoice)
    }
    
    // MARK: Actions
    
    @IBAction private func pickChoice(_ sender: Any?) {
        let choice = choices[popupChoice.indexOfSelectedItem]
        loadSettings(from: choice)

        delegate?.profileCustomization(self, didUpdateGateway: choice, withManualSettings: networkSettings)
    }

    @IBAction private func checkPolicy(_ sender: Any?) {
        guard let button = sender as? NSButton else {
            return
        }
        var policies = Set(networkSettings.gatewayPolicies ?? [])
        let policy: OpenVPN.RoutingPolicy
        switch button {
        case checkIPv4:
            policy = .IPv4

        case checkIPv6:
            policy = .IPv6
            
        default:
            return
        }
        if button.state == .on {
            policies.insert(policy)
        } else {
            policies.remove(policy)
        }
        networkSettings.gatewayPolicies = Array(policies)

        delegate?.profileCustomization(self, didUpdateGateway: .manual, withManualSettings: networkSettings)
    }

    private func loadSettings(from choice: NetworkChoice) {
        currentChoice = choice
        switch currentChoice {
        case .client:
            if let settings = clientNetworkSettings {
                networkSettings.copyGateway(from: settings)
            }
            
        case .server:
            break
            
        case .manual:
            if let settings = profile?.manualNetworkSettings {
                networkSettings.copyGateway(from: settings)
            }
        }
        
        let policies = networkSettings.gatewayPolicies ?? []
        
        checkIPv4.isEnabled = (currentChoice == .manual)
        checkIPv4.state = policies.contains(.IPv4) ? .on : .off
        checkIPv6.isEnabled = (currentChoice == .manual)
        checkIPv6.state = policies.contains(.IPv6) ? .on : .off
        
        let isServer = (currentChoice == .server)
        constraintChoiceBottom.priority = isServer ? .defaultHigh : .defaultLow
        constraintSettingsTop.priority = isServer ? .defaultLow : .defaultHigh
        viewSettings.isHidden = isServer
    }
}
