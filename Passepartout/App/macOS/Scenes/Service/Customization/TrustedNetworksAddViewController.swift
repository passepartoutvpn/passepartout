//
//  TrustedNetworksAddViewController.swift
//  Passepartout-macOS
//
//  Created by Davide De Rosa on 7/30/18.
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

protocol TrustedNetworksAddViewControllerDelegate: class {
    func trustedController(_ trustedController: TrustedNetworksAddViewController, didEnterSSID ssid: String)
}

class TrustedNetworksAddViewController: NSViewController {
    @IBOutlet private weak var textSSID: NSTextField!
    
    @IBOutlet private weak var buttonOK: NSButton!
    
    @IBOutlet private weak var buttonCancel: NSButton!
    
    weak var delegate: TrustedNetworksAddViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonOK.title = L10n.Core.Global.ok
        buttonCancel.title = L10n.Core.Global.cancel

        textSSID.stringValue = Utils.currentWifiNetworkName() ?? ""
    }

    @IBAction private func confirm(_ sender: Any?) {
        let ssid = textSSID.stringValue.trimmingCharacters(in: .whitespaces)
        guard !ssid.isEmpty else {
            return
        }
        delegate?.trustedController(self, didEnterSSID: ssid)
        dismiss(self)
    }
}
