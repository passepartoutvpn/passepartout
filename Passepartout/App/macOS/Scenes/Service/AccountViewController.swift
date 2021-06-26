//
//  AccountViewController.swift
//  Passepartout
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
import TunnelKit
import PassepartoutCore

protocol AccountViewControllerDelegate: AnyObject {
    func accountController(_ accountController: AccountViewController, shouldUpdateCredentials credentials: Credentials, forProfile profile: ConnectionProfile) -> Bool
    
    func accountController(_ accountController: AccountViewController, didUpdateCredentials credentials: Credentials, forProfile profile: ConnectionProfile)

    func accountControllerDidCancel(_ accountController: AccountViewController)
}

class AccountViewController: NSViewController {
    @IBOutlet private weak var labelUsernameCaption: NSTextField!

    @IBOutlet private weak var textUsername: NSTextField!
    
    @IBOutlet private weak var labelPasswordCaption: NSTextField!

    @IBOutlet private weak var textPassword: NSSecureTextField!

    @IBOutlet private weak var labelGuidance: NSTextField!
    
    @IBOutlet private weak var buttonGuidance: NSButton!

    @IBOutlet private weak var buttonOK: NSButton!

    @IBOutlet private weak var buttonCancel: NSButton!

    private let service = TransientStore.shared.service
    
    var profile: ConnectionProfile!

    weak var delegate: AccountViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(profile != nil, "Profile not set")
        
        labelUsernameCaption.stringValue = L10n.Core.Account.Cells.Username.caption.asCaption
        if let providerProfile = profile as? ProviderConnectionProfile {
            textUsername.placeholderString = providerProfile.infrastructure.defaults.username
        } else {
            textUsername.placeholderString = L10n.Core.Account.Cells.Username.placeholder
        }
        labelPasswordCaption.stringValue = L10n.Core.Account.Cells.Password.caption.asCaption
        textPassword.placeholderString = L10n.Core.Account.Cells.Password.placeholder
        buttonGuidance.title = L10n.Core.Account.Cells.OpenGuide.caption
        buttonOK.title = L10n.Core.Global.ok
        buttonCancel.title = L10n.Core.Global.cancel
        
        let credentials = service.credentials(for: profile)
        textUsername.stringValue = credentials?.username ?? ""
        textPassword.stringValue = credentials?.password ?? ""

        if let guidanceString = guidanceString, !guidanceString.isEmpty {
            labelGuidance.stringValue = guidanceString
            buttonGuidance.isHidden = (guidanceURL == nil)
        } else {
            labelGuidance.isHidden = true
            buttonGuidance.isHidden = true
        }
    }

    // MARK: Actions
    
    @IBAction private func openGuidanceURL(_ sender: Any?) {
        guard let url = guidanceURL else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    @IBAction private func confirm(_ sender: Any?) {
        let username = textUsername.stringValue
        let password = textPassword.stringValue
        let credentials = Credentials(username, password)
        if let delegate = delegate {
            guard delegate.accountController(self, shouldUpdateCredentials: credentials, forProfile: profile) else {
                return
            }
        }

        do {
            try service.setCredentials(credentials, for: profile)
        } catch {
            return
        }
        
        delegate?.accountController(self, didUpdateCredentials: credentials, forProfile: profile)
        presentingViewController?.dismiss(self)
    }
    
    @IBAction private func delegateAndDismiss(_ sender: Any?) {
        delegate?.accountControllerDidCancel(self)
        presentingViewController?.dismiss(self)
    }
    
    override func cancelOperation(_ sender: Any?) {
        delegateAndDismiss(sender)
    }
}

extension AccountViewController {
    private var guidanceString: String? {
        return metadata?.guidanceString
    }
    
    private var guidanceURL: URL? {
        return metadata?.guidanceURL
    }

    private var referralURL: URL? {
        return metadata?.referralURL
    }

    private var metadata: Infrastructure.Metadata? {
        guard let providerProfile = profile as? ProviderConnectionProfile else {
            return nil
        }
        return InfrastructureFactory.shared.metadata(forName: providerProfile.name)
    }
}
