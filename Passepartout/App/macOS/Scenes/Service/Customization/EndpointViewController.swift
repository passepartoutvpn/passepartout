//
//  EndpointViewController.swift
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

class EndpointViewController: NSViewController, ProfileCustomization {
    @IBOutlet private weak var labelAddressCaption: NSTextField!

    @IBOutlet private weak var popupAddress: NSPopUpButton!
    
    @IBOutlet private weak var labelProtocolCaption: NSTextField!

    @IBOutlet private weak var popupProtocol: NSPopUpButton!

    // MARK: ProfileCustomization
    
    var profile: ConnectionProfile?
    
    weak var delegate: ProfileCustomizationDelegate?
    
    private lazy var dataSource: EndpointDataSource = {
        guard let profile = profile else {
            fatalError("No profile set")
        }
        return profile as EndpointDataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        labelAddressCaption.stringValue = L10n.App.Endpoint.Cells.address.asCaption
        labelProtocolCaption.stringValue = L10n.Core.Global.Captions.protocol.asCaption

        reloadEndpoints()
    }
    
    func reloadEndpoints() {
        popupAddress.removeAllItems()
        for address in dataSource.addresses {
            popupAddress.addItem(withTitle: address)
            if address == dataSource.customAddress {
                popupAddress.selectItem(at: popupAddress.numberOfItems - 1)
            }
        }
        popupProtocol.removeAllItems()
        for proto in dataSource.protocols {
            popupProtocol.addItem(withTitle: proto.rawValue)
            if proto == dataSource.customProtocol {
                popupProtocol.selectItem(at: popupProtocol.numberOfItems - 1)
            }
        }
        
        if dataSource.canCustomizeEndpoint {
            popupAddress.insertItem(withTitle: L10n.Core.Endpoint.Cells.AnyAddress.caption, at: 0)
            popupProtocol.insertItem(withTitle: L10n.Core.Endpoint.Cells.AnyProtocol.caption, at: 0)

            if dataSource.customAddress == nil {
                popupAddress.selectItem(at: 0)
            }
            if dataSource.customProtocol == nil {
                popupProtocol.selectItem(at: 0)
            }
//        } else {
//            popupAddress.isEnabled = false
//            popupProtocol.isEnabled = false
        }
    }
    
    // MARK: Actions

    @IBAction private func selectAddress(_ sender: Any?) {
        guard dataSource.canCustomizeEndpoint else {
            return
        }
        let customAddress: String?
        if popupAddress.indexOfSelectedItem == 0 {
            customAddress = nil
        } else {
            customAddress = popupAddress.selectedItem?.title
        }
        delegate?.profileCustomization(self, didUpdateEndpointWithAddress: customAddress)
    }

    @IBAction private func selectProtocol(_ sender: Any?) {
        guard dataSource.canCustomizeEndpoint else {
            return
        }
        let customProtocol: EndpointProtocol?
        if popupProtocol.indexOfSelectedItem == 0 {
            customProtocol = nil
        } else {
            if let title = popupProtocol.selectedItem?.title {
                customProtocol = EndpointProtocol(rawValue: title)
            } else {
                customProtocol = nil
            }
        }
        delegate?.profileCustomization(self, didUpdateEndpointWithProtocol: customProtocol)
    }
}
