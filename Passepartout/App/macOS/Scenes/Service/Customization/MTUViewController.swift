//
//  MTUViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/28/20.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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

class MTUViewController: NSViewController, ProfileCustomization {
    @IBOutlet private weak var popupChoice: NSPopUpButton!
    
    @IBOutlet private weak var viewSettings: NSView!
    
    @IBOutlet private weak var labelMTUCaption: NSTextField!
    
    @IBOutlet private weak var popupMTU: NSPopUpButton!
    
    @IBOutlet private var constraintChoiceBottom: NSLayoutConstraint!
    
    @IBOutlet private var constraintSettingsTop: NSLayoutConstraint!
    
    private lazy var choices = NetworkChoice.choices(for: profile)

    private lazy var currentChoice = profile?.networkChoices?.mtu ?? ProfileNetworkChoices.with(profile: profile).mtu
    
    private lazy var clientNetworkSettings = profile?.clientNetworkSettings
    
    private let networkSettings = ProfileNetworkSettings()
    
    // MARK: ProfileCustomization
    
    var profile: ConnectionProfile?
    
    weak var delegate: ProfileCustomizationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupChoice.removeAllItems()
        for choice in choices {
            popupChoice.addItem(withTitle: choice.description)
            if choice == currentChoice {
                popupChoice.selectItem(at: popupChoice.numberOfItems - 1)
            }
        }
        labelMTUCaption.stringValue = L10n.NetworkSettings.Mtu.Cells.Bytes.caption.asCaption
        popupMTU.removeAllItems()
        for opt in ProfileNetworkSettings.mtuOptions {
            popupMTU.addItem(withTitle: (opt != 0) ? opt.description : L10n.Global.Values.default)
        }
        loadSettings(from: currentChoice ?? ProfileNetworkChoices.defaultChoice)
    }
    
    // MARK: Actions
    
    @IBAction private func pickChoice(_ sender: Any?) {
        let choice = choices[popupChoice.indexOfSelectedItem]
        loadSettings(from: choice)

        delegate?.profileCustomization(self, didUpdateMTU: choice, withManualSettings: networkSettings)
    }

    @IBAction private func pickBytes(_ sender: Any?) {
        guard let popup = sender as? NSPopUpButton, let title = popup.titleOfSelectedItem else {
            return
        }
        guard let bytes = Int(title) else {
            networkSettings.mtuBytes = nil
            return
        }
        networkSettings.mtuBytes = bytes

        delegate?.profileCustomization(self, didUpdateMTU: .manual, withManualSettings: networkSettings)
    }

    private func loadSettings(from choice: NetworkChoice) {
        currentChoice = choice
        switch choice {
        case .client:
            if let settings = clientNetworkSettings {
                networkSettings.copyMTU(from: settings)
            }

        case .server:
            break

        case .manual:
            if let settings = profile?.manualNetworkSettings {
                networkSettings.copyMTU(from: settings)
            }
        }

        let bytes = networkSettings.mtuBytes

        popupMTU.isEnabled = (currentChoice == .manual)
        for (i, opt) in popupMTU.itemTitles.enumerated() {
            if opt == L10n.Global.Values.default {
                if bytes == nil {
                    popupMTU.selectItem(at: i)
                    break
                }
                continue
            }
            guard let optValue = Int(opt) else {
                continue
            }
            if optValue == bytes {
                popupMTU.selectItem(at: i)
                break
            }
        }

        let isServer = (currentChoice == .server)
        constraintChoiceBottom.priority = isServer ? .defaultHigh : .defaultLow
        constraintSettingsTop.priority = isServer ? .defaultLow : .defaultHigh
        viewSettings.isHidden = isServer
    }
}
