//
//  Theme+Cells.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/25/18.
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

import UIKit
import PassepartoutCore
import ConvenienceUI

extension UITableViewCell {
    func applyChecked(_ checked: Bool, _ theme: Theme) {
        textLabel?.font = .preferredFont(forTextStyle: .body)
        accessoryType = checked ? .checkmark : .none
        tintColor = theme.palette.accessory
    }
}

extension SingleOptionViewController {
    func applyTint(_ theme: Theme) {
        configurationBlock = { (cell, _) in
            cell.tintColor = theme.palette.accessory
        }
    }
}

extension DestructiveTableViewCell {
    func apply(_ theme: Theme) {
        labelCaption?.font = .preferredFont(forTextStyle: .body)
        captionColor = theme.palette.destructive
        accessoryType = .none
        selectionStyle = .default
    }
}

extension FieldTableViewCell {
    func apply(_ theme: Theme) {
        textLabel?.font = .preferredFont(forTextStyle: .body)
        field.font = .preferredFont(forTextStyle: .body)
        captionColor = theme.palette.primaryText
    }
}

extension SettingTableViewCell {
    func apply(_ theme: Theme) {
        textLabel?.font = .preferredFont(forTextStyle: .body)
        detailTextLabel?.font = .preferredFont(forTextStyle: .body)
        leftTextColor = theme.palette.primaryText
        rightTextColor = theme.palette.secondaryText
    }
}

extension ToggleTableViewCell {
    func apply(_ theme: Theme) {
        textLabel?.font = .preferredFont(forTextStyle: .body)
        captionColor = theme.palette.primaryText
    }
}

extension ActivityTableViewCell {
    func apply(_ theme: Theme) {
        textLabel?.font = .preferredFont(forTextStyle: .body)
        textLabel?.text = nil
        detailTextLabel?.text = nil
    }
}

extension SettingTableViewCell {
    func applyAction(_ theme: Theme) {
        textLabel?.font = .preferredFont(forTextStyle: .body)
        detailTextLabel?.font = .preferredFont(forTextStyle: .body)
        leftTextColor = theme.palette.action
        rightTextColor = nil
        accessoryType = .none
    }
    
    func applyVPN(_ theme: Theme, with vpnStatus: VPNStatus?, error: OpenVPNProviderError?) {
        textLabel?.font = .preferredFont(forTextStyle: .body)
        detailTextLabel?.font = .preferredFont(forTextStyle: .body)

        leftTextColor = theme.palette.primaryText
        guard let vpnStatus = vpnStatus else {
            rightText = L10n.Vpn.disabled
            rightTextColor = theme.palette.secondaryText
            return
        }
        
        switch vpnStatus {
        case .connecting:
            rightText = L10n.Vpn.connecting
            rightTextColor = theme.palette.indeterminate
            
        case .connected:
            rightText = L10n.Vpn.active
            rightTextColor = theme.palette.on
            
        case .disconnecting, .disconnected:
            var disconnectionReason: String?
            if let error = error {
                switch error {
                case .socketActivity, .timeout:
                    disconnectionReason = L10n.Vpn.Errors.timeout
                    
                case .dnsFailure:
                    disconnectionReason = L10n.Vpn.Errors.dns
                    
                case .tlsInitialization, .tlsServerVerification, .tlsHandshake:
                    disconnectionReason = L10n.Vpn.Errors.tls
                    
                case .authentication:
                    disconnectionReason = L10n.Vpn.Errors.auth
                    
                case .encryptionInitialization, .encryptionData:
                    disconnectionReason = L10n.Vpn.Errors.encryption

                case .serverCompression, .lzo:
                    disconnectionReason = L10n.Vpn.Errors.compression
                    
                case .networkChanged:
                    disconnectionReason = L10n.Vpn.Errors.network
                    
                case .routing:
                    disconnectionReason = L10n.Vpn.Errors.routing
                    
                case .gatewayUnattainable:
                    disconnectionReason = L10n.Vpn.Errors.gateway
                    
                case .serverShutdown:
                    disconnectionReason = L10n.Vpn.Errors.shutdown
                    
                default:
                    break
                }
            }
            switch vpnStatus {
            case .disconnecting:
                rightText = disconnectionReason ?? L10n.Vpn.disconnecting
                rightTextColor = theme.palette.indeterminate
                
            case .disconnected:
                rightText = disconnectionReason ?? L10n.Vpn.inactive
                rightTextColor = theme.palette.off
                
            default:
                break
            }
        }
    }
}
