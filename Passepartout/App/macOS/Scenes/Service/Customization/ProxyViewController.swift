//
//  ProxyViewController.swift
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

class ProxyViewController: NSViewController, ProfileCustomization {
    private struct Templates {
        static let bypass = "domain.com"
    }
    
    @IBOutlet private weak var popupChoice: NSPopUpButton!
    
    @IBOutlet private weak var viewSettings: NSView!
    
    @IBOutlet private weak var labelProxyCaption: NSTextField!
    
    @IBOutlet private weak var textProxyAddress: NSTextField!
    
    @IBOutlet private weak var textProxyPort: NSTextField!
    
    @IBOutlet private weak var viewProxyBypass: NSView!
    
    @IBOutlet private var constraintChoiceBottom: NSLayoutConstraint!
    
    @IBOutlet private var constraintSettingsTop: NSLayoutConstraint!
    
    private lazy var tableProxyBypass: TextTableView = .get()
    
    private lazy var choices = NetworkChoice.choices(for: profile)
    
    private lazy var currentChoice = profile?.networkChoices?.proxy ?? ProfileNetworkChoices.with(profile: profile).proxy

    private lazy var clientNetworkSettings = profile?.clientNetworkSettings
    
    private let networkSettings = ProfileNetworkSettings()

    // MARK: ProfileCustomization
    
    var profile: ConnectionProfile?
    
    weak var delegate: ProfileCustomizationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelProxyCaption.stringValue = L10n.Core.Global.Captions.address.asCaption
        textProxyAddress.placeholderString = L10n.Core.Global.Values.none
        textProxyPort.placeholderString = L10n.Core.Global.Values.none

        tableProxyBypass.title = L10n.App.NetworkSettings.Proxy.Cells.BypassDomains.title.asCaption
        viewProxyBypass.addSubview(tableProxyBypass)
        tableProxyBypass.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableProxyBypass.topAnchor.constraint(equalTo: viewProxyBypass.topAnchor),
            tableProxyBypass.bottomAnchor.constraint(equalTo: viewProxyBypass.bottomAnchor),
            tableProxyBypass.leftAnchor.constraint(equalTo: viewProxyBypass.leftAnchor),
            tableProxyBypass.rightAnchor.constraint(equalTo: viewProxyBypass.rightAnchor),
        ])
        tableProxyBypass.rowTemplate = Templates.bypass

        loadSettings(from: currentChoice)

        popupChoice.removeAllItems()
        for choice in choices {
            popupChoice.addItem(withTitle: choice.description)
            if choice == currentChoice {
                popupChoice.selectItem(at: popupChoice.numberOfItems - 1)
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction private func pickChoice(_ sender: Any?) {
        let choice = choices[popupChoice.indexOfSelectedItem]
        loadSettings(from: choice)

        delegate?.profileCustomization(self, didUpdateProxy: choice, withManualSettings: networkSettings)
    }
    
    func commitManualSettings() {
        guard currentChoice == .manual else {
            return
        }
        view.endEditing()
        networkSettings.proxyAddress = textProxyAddress.stringValue
        networkSettings.proxyPort = UInt16(textProxyPort.stringValue)
        networkSettings.proxyBypassDomains = tableProxyBypass.rows

        delegate?.profileCustomization(self, didUpdateProxy: .manual, withManualSettings: networkSettings)
    }
    
    // MARK: Helpers
    
    private func loadSettings(from choice: NetworkChoice) {
        currentChoice = choice
        switch currentChoice {
        case .client:
            if let settings = clientNetworkSettings {
                networkSettings.copyProxy(from: settings)
            }
            
        case .server:
            break
            
        case .manual:
            if let settings = profile?.manualNetworkSettings {
                networkSettings.copyProxy(from: settings)
            }
        }
        
        textProxyAddress.isEnabled = (currentChoice == .manual)
        textProxyAddress.stringValue = networkSettings.proxyAddress ?? ""
        textProxyPort.isEnabled = (currentChoice == .manual)
        textProxyPort.stringValue = networkSettings.proxyPort?.description ?? ""
        tableProxyBypass.reset(withRows: networkSettings.proxyBypassDomains ?? [], isAddEnabled: currentChoice == .manual)

        let isServer = (currentChoice == .server)
        constraintChoiceBottom.priority = isServer ? .defaultHigh : .defaultLow
        constraintSettingsTop.priority = isServer ? .defaultLow : .defaultHigh
        viewSettings.isHidden = isServer
    }
}
