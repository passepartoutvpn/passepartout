//
//  HostImporter.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/18/19.
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

import Foundation
import PassepartoutCore
import TunnelKit
import SwiftyBeaver

private let log = SwiftyBeaver.self

class HostImporter {
    private let service = TransientStore.shared.service
    
    private let windowController: NSWindowController?
    
    private let viewController: NSViewController?
    
    private weak var accountDelegate: AccountViewControllerDelegate?

    private let configurationURL: URL
    
    private var createdTitle: String?

    private var replacedProfile: ConnectionProfile?
    
    init(withConfigurationURL configurationURL: URL) {
        self.configurationURL = configurationURL
        log.debug("Parsing configuration URL: \(configurationURL)")

        windowController = WindowManager.shared.showOrganizer()
        viewController = windowController?.contentViewController
        accountDelegate = viewController as? AccountViewControllerDelegate
    }
    
    func importHost(withPassphrase passphrase: String?) {
        let result: OpenVPN.ConfigurationParser.Result
        do {
            result = try OpenVPN.ConfigurationParser.parsed(fromURL: configurationURL, passphrase: passphrase)
        } catch let e as ConfigurationError {
            switch e {
            case .encryptionPassphrase, .unableToDecrypt(_):
                enterPassphraseForHost(at: configurationURL)
                
            default:
                let message = HostImporter.localizedMessage(forError: e)
                let alert = Macros.warning(configurationURL.normalizedFilename, message)
                _ = alert.presentModally(withOK: L10n.Core.Global.ok, cancel: nil)
            }
            return
        } catch let e {
            let message = HostImporter.localizedMessage(forError: e)
            let alert = Macros.warning(configurationURL.normalizedFilename, message)
            _ = alert.presentModally(withOK: L10n.Core.Global.ok, cancel: nil)
            return
        }
        
        if let warning = result.warning {
            let message = HostImporter.localizedDetailsMessage(forWarning: warning)
            let alert = Macros.warning(configurationURL.normalizedFilename, L10n.Core.ParsedFile.Alerts.PotentiallyUnsupported.message(message))
            
            if alert.presentModally(withOK: L10n.Core.Global.ok, cancel: L10n.Core.Global.cancel) {
                enterProfileName(forHostWithResult: result)
            }
            
            return
        }
        
        enterProfileName(forHostWithResult: result)
    }

    private func enterPassphraseForHost(at url: URL) {
        let vc = StoryboardScene.Main.textInputViewController.instantiate()
        vc.caption = L10n.Core.ParsedFile.Alerts.EncryptionPassphrase.message
        vc.isSecure = true
        vc.object = url
        vc.delegate = self
        present(vc)
    }
    
    private func enterProfileName(forHostWithResult result: OpenVPN.ConfigurationParser.Result) {
        guard let title = result.url?.normalizedFilename, let hostname = result.configuration.hostname else {
            return
        }

        let vc = StoryboardScene.Main.textInputViewController.instantiate()
        vc.caption = L10n.Core.Service.Alerts.Rename.title.asCaption
        let profile = HostConnectionProfile(hostname: hostname)
        let builder = OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: result.configuration)
        profile.parameters = builder.build()
        vc.text = title
        vc.placeholder = L10n.Core.Global.Host.TitleInput.placeholder
        vc.object = profile
        vc.delegate = self
        present(vc)
    }
    
    private func enterCredentials(forProfile profile: ConnectionProfile) {
        let vc = StoryboardScene.Service.accountViewController.instantiate()
        vc.profile = profile
        vc.delegate = self
        present(vc)
    }
    
    // MARK: Helpers

    private func present(_ presentedViewController: NSViewController) {
        viewController?.presentAsSheet(presentedViewController)
    }
    
    private func dismiss(_ presentedViewController: NSViewController) {
        viewController?.dismiss(presentedViewController)
    }

    // XXX: copy/paste from iOS
    private static func localizedMessage(forError error: Error) -> String {
        if let appError = error as? ConfigurationError {
            switch appError {
            case .malformed(let option):
                log.error("Could not parse configuration URL: malformed option, \(option)")
                return L10n.Core.ParsedFile.Alerts.Malformed.message(option)
                
            case .missingConfiguration(let option):
                log.error("Could not parse configuration URL: missing configuration, \(option)")
                return L10n.Core.ParsedFile.Alerts.Missing.message(option)
                
            case .unsupportedConfiguration(let option):
                log.error("Could not parse configuration URL: unsupported configuration, \(option)")
                return L10n.Core.ParsedFile.Alerts.Unsupported.message(option)
                
            default:
                break
            }
        }
        log.error("Could not parse configuration URL: \(error)")
        return L10n.Core.ParsedFile.Alerts.Parsing.message(error.localizedDescription)
    }
    
    // XXX: copy/paste from iOS
    private static func localizedDetailsMessage(forWarning warning: ConfigurationError) -> String {
        switch warning {
        case .malformed(let option):
            return option
            
        case .missingConfiguration(let option):
            return option
            
        case .unsupportedConfiguration(let option):
            return option
            
        default:
            return "" // XXX: should never get here
        }
    }
}

extension HostImporter: TextInputViewControllerDelegate {
    func textInputController(_ textInputController: TextInputViewController, shouldEnterText text: String) -> Bool {

        // rename profile
        guard let _ = textInputController.object as? ConnectionProfile else {
            return true
        }
        return true//text.rangeOfCharacter(from: CharacterSet.filename.inverted) == nil
    }
    
    func textInputController(_ textInputController: TextInputViewController, didEnterText text: String) {

        // rename profile
        if let profile = textInputController.object as? ConnectionProfile {
            createdTitle = text

            // overwrite host with existing name?
            replacedProfile = nil
            if let existingHostId = service.existingHostId(withTitle: text) {
                dismiss(textInputController)

                let alert = Macros.warning(text, L10n.Core.Wizards.Host.Alerts.Existing.message)
                if alert.presentModally(withOK: L10n.Core.Global.ok, cancel: L10n.Core.Global.cancel) {
                    guard let existingProfile = service.profile(withContext: profile.context, id: existingHostId) else {
                        fatalError("ConnectionService.existingHostId() returned a non-existing host profile?")
                    }
                    replacedProfile = existingProfile
                    enterCredentials(forProfile: profile)
                }
                return
            }
            enterCredentials(forProfile: profile)
        }
        // enter passphrase
        else {
            importHost(withPassphrase: text)
        }

        dismiss(textInputController)
    }
}

// enrich delegate
extension HostImporter : AccountViewControllerDelegate {
    func accountController(_ accountController: AccountViewController, shouldUpdateCredentials credentials: Credentials, forProfile profile: ConnectionProfile) -> Bool {
        return accountDelegate?.accountController(accountController, shouldUpdateCredentials: credentials, forProfile: profile) ?? true
    }
    
    func accountController(_ accountController: AccountViewController, didUpdateCredentials credentials: Credentials, forProfile profile: ConnectionProfile) {
        if let replacedProfile = replacedProfile {
            service.removeProfile(ProfileKey(replacedProfile))
        }
        service.addOrReplaceProfile(profile, credentials: credentials, title: createdTitle)
        _ = try? service.save(configurationURL: configurationURL, for: profile)

        accountDelegate?.accountController(accountController, didUpdateCredentials: credentials, forProfile: profile)
    }
    
    func accountControllerDidCancel(_ accountController: AccountViewController) {
        accountDelegate?.accountControllerDidCancel(accountController)
    }
}
