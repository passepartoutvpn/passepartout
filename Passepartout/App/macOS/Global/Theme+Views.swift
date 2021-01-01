//
//  Theme+Views.swift
//  Passepartout-macOS
//
//  Created by Davide De Rosa on 7/29/18.
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

extension NSTextField {
    func applyVPN(_ theme: Theme, isActive: Bool, with vpnStatus: VPNStatus?, error: OpenVPNTunnelProvider.ProviderError?) {
        guard isActive else {
            stringValue = L10n.App.Vpn.unused
            textColor = theme.palette.colorSecondaryText
            return
        }
        guard let vpnStatus = vpnStatus else {
            stringValue = L10n.Core.Vpn.disabled
            textColor = theme.palette.colorSecondaryText
            return
        }
        
        switch vpnStatus {
        case .connecting:
            stringValue = L10n.Core.Vpn.connecting
            textColor = theme.palette.colorIndeterminate
            
        case .connected:
            stringValue = L10n.Core.Vpn.active
            textColor = theme.palette.colorOn
            
        case .disconnecting:
            stringValue = disconnectionReason(for: error) ?? L10n.Core.Vpn.disconnecting
            textColor = theme.palette.colorIndeterminate
            
        case .disconnected:
            stringValue = disconnectionReason(for: error) ?? L10n.Core.Vpn.inactive
            textColor = theme.palette.colorOff
        }
    }
    
    private func disconnectionReason(for error: OpenVPNTunnelProvider.ProviderError?) -> String? {
        guard let error = error else {
            return nil
        }
        let V = L10n.Core.Vpn.Errors.self
        switch error {
        case .socketActivity, .timeout:
            return V.timeout
            
        case .dnsFailure:
            return V.dns
            
        case .tlsInitialization, .tlsServerVerification, .tlsHandshake:
            return V.tls
            
        case .authentication:
            return V.auth
            
        case .encryptionInitialization, .encryptionData:
            return V.encryption
            
        case .serverCompression, .lzo:
            return V.compression
            
        case .networkChanged:
            return V.network
            
        case .routing:
            return V.routing
            
        case .gatewayUnattainable:
            return V.gateway

        default:
            return nil
        }
    }
}
