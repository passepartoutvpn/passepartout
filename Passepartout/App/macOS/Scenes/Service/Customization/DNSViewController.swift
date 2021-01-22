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
import TunnelKit

class DNSViewController: NSViewController, ProfileCustomization {
    @IBOutlet private weak var popupChoice: NSPopUpButton!
    
    @IBOutlet private weak var viewSettings: NSView!

    @IBOutlet private weak var textDNSCustom: NSTextField!

    @IBOutlet private weak var viewDNSAddresses: NSView!
    
    @IBOutlet private weak var viewDNSDomains: NSView!
    
    @IBOutlet private weak var labelDNSProtocol: NSTextField!
    
    @IBOutlet private weak var popupDNSProtocol: NSPopUpButton!
    
    @IBOutlet private var constraintChoiceBottom: NSLayoutConstraint!
    
    @IBOutlet private var constraintSettingsTop: NSLayoutConstraint!
    
    @IBOutlet private var constraintCustomBottom: NSLayoutConstraint!
    
    @IBOutlet private var constraintAddressesBottom: NSLayoutConstraint!
    
    private lazy var tableDNSDomains: TextTableView = .get()
    
    private lazy var tableDNSAddresses: TextTableView = .get()
    
    private lazy var currentChoice = profile?.networkChoices?.dns ?? ProfileNetworkChoices.with(profile: profile).dns

    private lazy var clientNetworkSettings = profile?.clientNetworkSettings

    private let networkSettings = ProfileNetworkSettings()
    
    // MARK: ProfileCustomization
    
    var profile: ConnectionProfile?
    
    weak var delegate: ProfileCustomizationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelDNSProtocol.stringValue = L10n.Core.Global.Captions.protocol.asCaption

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
        
        loadSettings(from: currentChoice)

        popupChoice.removeAllItems()
        popupDNSProtocol.removeAllItems()
        let menuChoice = NSMenu()
        var indexOfChoice = 0
        for (i, choice) in NetworkChoice.choices(for: profile).enumerated() {
            let item = NSMenuItem(title: choice.description, action: nil, keyEquivalent: "")
            item.representedObject = choice
            menuChoice.addItem(item)
            if choice == currentChoice {
                indexOfChoice = i
            }
        }
        popupChoice.menu = menuChoice
        tableDNSAddresses.rowTemplate = AppConstants.Placeholders.dnsAddress
        tableDNSDomains.rowTemplate = AppConstants.Placeholders.dnsDomain
        let menuProtocol = NSMenu()
        var availableProtocols: [DNSProtocol] = [.plain]
        if #available(iOS 14, macOS 11, *) {
            availableProtocols.append(.https)
            availableProtocols.append(.tls)
        }
        var indexOfDNSProtocol = 0
        for (i, proto) in availableProtocols.enumerated() {
            let item = NSMenuItem(title: proto.description, action: nil, keyEquivalent: "")
            item.representedObject = proto
            menuProtocol.addItem(item)
            if proto == networkSettings.dnsProtocol {
                indexOfDNSProtocol = i
            }
        }
        popupChoice.menu = menuChoice
        popupChoice.selectItem(at: indexOfChoice)
        popupDNSProtocol.menu = menuProtocol
        popupDNSProtocol.selectItem(at: indexOfDNSProtocol)
    }
    
    // MARK: Actions
    
    @IBAction private func pickChoice(_ sender: Any?) {
        guard let choice = popupChoice.selectedItem?.representedObject as? NetworkChoice else {
            return
        }
        loadSettings(from: choice)

        delegate?.profileCustomization(self, didUpdateDNS: choice, withManualSettings: networkSettings)
    }

    @IBAction private func pickProtocol(_ sender: Any?) {
        guard let choice = popupChoice.selectedItem?.representedObject as? NetworkChoice else {
            return
        }
        guard let proto = popupDNSProtocol.selectedItem?.representedObject as? DNSProtocol else {
            return
        }
        networkSettings.dnsProtocol = proto
        updateProtocolVisibility()

        delegate?.profileCustomization(self, didUpdateDNS: choice, withManualSettings: networkSettings)
    }

    func commitManualSettings() {
        guard currentChoice == .manual else {
            return
        }
        view.endEditing()
        switch networkSettings.dnsProtocol {
        case .https:
            networkSettings.dnsHTTPSURL = URL(string: textDNSCustom.stringValue)

        case .tls:
            networkSettings.dnsTLSServerName = textDNSCustom.stringValue

        default:
            networkSettings.dnsServers = tableDNSAddresses.rows
        }
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
        
        let isManual = (currentChoice == .manual)
        popupDNSProtocol.isEnabled = isManual
        textDNSCustom.isEnabled = isManual
        tableDNSAddresses.reset(withRows: networkSettings.dnsServers ?? [], isAddEnabled: isManual)
        tableDNSDomains.reset(withRows: networkSettings.dnsSearchDomains ?? [], isAddEnabled: isManual)

        let isServer = (currentChoice == .server)
        constraintChoiceBottom.priority = isServer ? .defaultHigh : .defaultLow
        constraintSettingsTop.priority = isServer ? .defaultLow : .defaultHigh
        viewSettings.isHidden = isServer
        
        updateProtocolVisibility()
    }
    
    private func updateProtocolVisibility() {
        let isManual = (currentChoice == .manual)
        let isCustom: Bool
        switch networkSettings.dnsProtocol {
        case .https:
            isCustom = true
            textDNSCustom.placeholderString = isManual ? AppConstants.Placeholders.dohURL : ""
            textDNSCustom.stringValue = networkSettings.dnsHTTPSURL?.absoluteString ?? ""
            
        case .tls:
            isCustom = true
            textDNSCustom.placeholderString = isManual ? AppConstants.Placeholders.dotServerName : ""
            textDNSCustom.stringValue = networkSettings.dnsTLSServerName ?? ""

        default:
            isCustom = false
        }

        constraintCustomBottom.priority = isCustom ? .defaultHigh : .defaultLow
        constraintAddressesBottom.priority = isCustom ? .defaultLow : .defaultHigh
        textDNSCustom.isHidden = !isCustom
        viewDNSAddresses.isHidden = isCustom
    }
}
