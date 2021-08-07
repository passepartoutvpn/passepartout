//
//  PreferencesGeneralViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/31/19.
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
import ServiceManagement

class PreferencesGeneralViewController: NSViewController {
    @IBOutlet private weak var checkLaunchOnLogin: NSButton!

    @IBOutlet private weak var labelLaunchOnLogin: NSTextField!

    @IBOutlet private weak var checkConfirmQuit: NSButton!

    @IBOutlet private weak var labelConfirmQuit: NSTextField!

    @IBOutlet private weak var checkResolveHostname: NSButton!

    @IBOutlet private weak var labelResolveHostname: NSTextField!

    private let service = TransientStore.shared.service

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLaunchOnLogin.title = L10n.Preferences.Cells.LaunchesOnLogin.caption
        labelLaunchOnLogin.stringValue = L10n.Preferences.Cells.LaunchesOnLogin.footer
        checkConfirmQuit.title = L10n.Preferences.Cells.ConfirmQuit.caption
        labelConfirmQuit.stringValue = L10n.Preferences.Cells.ConfirmQuit.footer
        checkResolveHostname.title = L10n.Service.Cells.VpnResolvesHostname.caption
        labelResolveHostname.stringValue = L10n.Service.Sections.VpnResolvesHostname.footer
        
        checkLaunchOnLogin.state = (service.preferences.launchesOnLogin ?? true) ? .on : .off
        checkConfirmQuit.state = (service.preferences.confirmsQuit ?? true) ? .on : .off
        checkResolveHostname.state = service.preferences.resolvesHostname ? .on : .off
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        TransientStore.shared.serialize(withProfiles: false) // close preferences
    }
    
    @IBAction private func toggleLaunchesOnLogin(_ sender: Any?) {
        service.preferences.launchesOnLogin = (checkLaunchOnLogin.state == .on)
        SMLoginItemSetEnabled(AppConstants.App.appLauncherId as CFString, service.preferences.launchesOnLogin ?? true)
    }

    @IBAction private func toggleConfirmQuit(_ sender: Any?) {
        service.preferences.confirmsQuit = (checkConfirmQuit.state == .on)
    }

    @IBAction private func toggleResolvesHostname(_ sender: Any?) {
        service.preferences.resolvesHostname = (checkResolveHostname.state == .on)
        cycleVPNIfNeeded()
    }

    private func cycleVPNIfNeeded() {
        let vpn = GracefulVPN(service: service)
        guard vpn.isEnabled else {
            return
        }
//        guard vpn.status == .disconnected else {
//            confirmVpnReconnection()
//            return
//        }
        vpn.reinstall(completionHandler: nil)
    }
}
