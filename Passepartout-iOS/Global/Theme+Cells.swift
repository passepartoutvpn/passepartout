//
//  Theme+Cells.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 6/25/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
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

extension UITableViewCell {
    func applyChecked(_ checked: Bool, _ theme: Theme) {
        accessoryType = checked ? .checkmark : .none
        tintColor = Theme.current.palette.colorAccessory
    }
}

extension DestructiveTableViewCell {
    func apply(_ theme: Theme) {
        accessoryType = .none
        selectionStyle = .default
        captionColor = theme.palette.colorDestructive
    }
}

extension FieldTableViewCell {
    func apply(_ theme: Theme) {
        captionColor = theme.palette.colorPrimaryText
    }
}

extension SettingTableViewCell {
    func apply(_ theme: Theme) {
        leftTextColor = theme.palette.colorPrimaryText
        rightTextColor = theme.palette.colorSecondaryText
    }
}

extension ToggleTableViewCell {
    func apply(_ theme: Theme) {
        captionColor = theme.palette.colorPrimaryText
    }
}

extension SettingTableViewCell {
    func applyAction(_ theme: Theme) {
        leftTextColor = theme.palette.colorAction
        rightTextColor = nil
        accessoryType = .none
    }
    
    func applyVPN(_ theme: Theme, with vpnStatus: VPNStatus?) {
        leftTextColor = theme.palette.colorPrimaryText
        guard let vpnStatus = vpnStatus else {
            rightText = L10n.Vpn.disabled
            rightTextColor = theme.palette.colorSecondaryText
            return
        }
        
        switch vpnStatus {
        case .connecting:
            rightText = L10n.Vpn.connecting
            rightTextColor = theme.palette.colorIndeterminate
            
        case .connected:
            rightText = L10n.Vpn.active
            rightTextColor = theme.palette.colorOn
            
        case .disconnecting:
            rightText = L10n.Vpn.disconnecting
            rightTextColor = theme.palette.colorIndeterminate
            
        case .disconnected:
            rightText = L10n.Vpn.inactive
            rightTextColor = theme.palette.colorOff
        }
    }
}
