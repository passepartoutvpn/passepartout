//
//  DNSViewController.swift
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

class DNSViewController: NSViewController, ProfileCustomization {
    private struct Templates {
        static let server = "0.0.0.0"

        static let domain = ""
    }

    @IBOutlet private weak var popupChoice: NSPopUpButton!
    
    @IBOutlet private weak var viewSettings: NSView!

    @IBOutlet private weak var viewDNSAddresses: NSView!
    
    @IBOutlet private weak var viewDNSDomains: NSView!
    
    @IBOutlet private var constraintChoiceBottom: NSLayoutConstraint!
    
    @IBOutlet private var constraintSettingsTop: NSLayoutConstraint!
    
    private lazy var tableDNSDomains: TextTableView = .get()
    
    private lazy var tableDNSAddresses: TextTableView = .get()
    
    private lazy var choices = NetworkChoice.choices(for: profile)
    
    private lazy var currentChoice = profile?.networkChoices?.dns ?? ProfileNetworkChoices.with(profile: profile).dns

    private lazy var clientNetworkSettings = profile?.clientNetworkSettings

    private let networkSettings = ProfileNetworkSettings()
    
    // MARK: ProfileCustomization
    
    var profile: ConnectionProfile?
    
    weak var delegate: ProfileCustomizationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableDNSAddresses.title = L10n.App.NetworkSettings.Dns.Cells.Addresses.title.asCaption
        viewDNSAddresses.addSubview(tableDNSAddresses)
        tableDNSAddresses.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableDNSAddresses.topAnchor.constraint(equalTo: viewDNSAddresses.topAnchor),
            tableDNSAddresses.bottomAnchor.constraint(equalTo: viewDNSAddresses.bottomAnchor),
            tableDNSAddresses.leftAnchor.constraint(equalTo: viewDNSAddresses.leftAnchor),
            tableDNSAddresses.rightAnchor.constraint(equalTo: viewDNSAddresses.rightAnchor),
        ])
        
        tableDNSDomains.title = L10n.App.NetworkSettings.Dns.Cells.Domains.title.asCaption
        viewDNSDomains.addSubview(tableDNSDomains)
        tableDNSDomains.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableDNSDomains.topAnchor.constraint(equalTo: viewDNSDomains.topAnchor),
            tableDNSDomains.bottomAnchor.constraint(equalTo: viewDNSDomains.bottomAnchor),
            tableDNSDomains.leftAnchor.constraint(equalTo: viewDNSDomains.leftAnchor),
            tableDNSDomains.rightAnchor.constraint(equalTo: viewDNSDomains.rightAnchor),
        ])
        
        popupChoice.removeAllItems()
        for choice in choices {
            popupChoice.addItem(withTitle: choice.description)
            if choice == currentChoice {
                popupChoice.selectItem(at: popupChoice.numberOfItems - 1)
            }
        }
        tableDNSAddresses.rowTemplate = Templates.server
        tableDNSDomains.rowTemplate = Templates.domain
        loadSettings(from: currentChoice)
    }
    
    // MARK: Actions
    
    @IBAction private func pickChoice(_ sender: Any?) {
        let choice = choices[popupChoice.indexOfSelectedItem]
        loadSettings(from: choice)

        delegate?.profileCustomization(self, didUpdateDNS: choice, withManualSettings: networkSettings)
    }

    func commitManualSettings() {
        guard currentChoice == .manual else {
            return
        }
        view.endEditing()
        networkSettings.dnsServers = tableDNSAddresses.rows
        networkSettings.dnsSearchDomains = tableDNSDomains.rows

        delegate?.profileCustomization(self, didUpdateDNS: .manual, withManualSettings: networkSettings)
    }
    
    // MARK: Helpers

    private func loadSettings(from choice: NetworkChoice) {
        currentChoice = choice
        switch currentChoice {
        case .client:
            if let settings = clientNetworkSettings {
                networkSettings.copyDNS(from: settings)
            }
            
        case .server:
            break
            
        case .manual:
            if let settings = profile?.manualNetworkSettings {
                networkSettings.copyDNS(from: settings)
            }
        }
        
        tableDNSAddresses.reset(withRows: networkSettings.dnsServers ?? [], isAddEnabled: currentChoice == .manual)
        tableDNSDomains.reset(withRows: networkSettings.dnsSearchDomains ?? [], isAddEnabled: currentChoice == .manual)

        let isServer = (currentChoice == .server)
        constraintChoiceBottom.priority = isServer ? .defaultHigh : .defaultLow
        constraintSettingsTop.priority = isServer ? .defaultLow : .defaultHigh
        viewSettings.isHidden = isServer
    }
}
