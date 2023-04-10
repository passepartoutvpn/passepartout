//
//  PassepartoutMenu+StatusButton.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/5/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

import Foundation
import AppKit

extension PassepartoutMenu {

    @MainActor
    class StatusButton {
        private lazy var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        private lazy var statusButton: NSStatusBarButton = {
            guard let statusButton = statusItem.button else {
                fatalError("Missing status item button?")
            }
            return statusButton
        }()

        private let profileManager: LightProfileManager

        private let vpnManager: LightVPNManager

        init(profileManager: LightProfileManager, vpnManager: LightVPNManager) {
            self.profileManager = profileManager
            self.vpnManager = vpnManager

            vpnManager.addDelegate(self, withIdentifier: "PassepartoutMenu")
            setStatus(vpnManager.vpnStatus)
        }

        deinit {
            Task { @MainActor in
                vpnManager.removeDelegate(withIdentifier: "PassepartoutMenu")
            }
        }

        func install(systemMenu: SystemMenu) {
            statusItem.menu = systemMenu.asMenu
        }
    }
}

extension PassepartoutMenu.StatusButton: LightVPNManagerDelegate {
    func didUpdateState(isEnabled: Bool, vpnStatus: LightVPNStatus) {
        guard isEnabled else {
            setStatus(.disconnected)
            return
        }
        setStatus(vpnStatus)
    }

    private func setStatus(_ vpnStatus: LightVPNStatus) {
        statusButton.setStatus(vpnStatus, withActiveProfileName: profileManager.activeProfileName)
    }
}

private extension NSStatusBarButton {
    func setStatus(_ vpnStatus: LightVPNStatus, withActiveProfileName activeProfileName: String?) {
        image = vpnStatus.image
        alphaValue = vpnStatus.imageAlpha

        guard let activeProfileName = activeProfileName else {
            toolTip = nil
            return
        }
        toolTip = [
            Constants.Global.appName,
            activeProfileName,
            vpnStatus.localizedDescription
        ].joined(separator: "\n")
    }
}
