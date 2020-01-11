//
//  HostImporter.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 10/22/19.
//  Copyright (c) 2020 Davide De Rosa. All rights reserved.
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
    
    private weak var viewController: UIViewController?

    private let configurationURL: URL

    init(withConfigurationURL configurationURL: URL, parentViewController: UIViewController) {
        self.configurationURL = configurationURL
        log.debug("Parsing configuration URL: \(configurationURL)")

        viewController = parentViewController
    }
    
    func importHost(withPassphrase passphrase: String?, removeOnError: Bool, removeOnCancel: Bool, completionHandler: @escaping (OpenVPN.ConfigurationParser.Result) -> Void) {
        let result: OpenVPN.ConfigurationParser.Result
        do {
            result = try OpenVPN.ConfigurationParser.parsed(fromURL: configurationURL, passphrase: passphrase)
        } catch let e as ConfigurationError {
            switch e {
            case .encryptionPassphrase, .unableToDecrypt(_):
                enterPassphraseForHost(at: configurationURL, removeOnError: removeOnError, removeOnCancel: removeOnCancel, completionHandler: completionHandler)

            default:
                alertImportError(e, removeOnError: removeOnError)
            }
            return
        } catch let e {
            alertImportError(e, removeOnError: removeOnError)
            return
        }

        if let warning = result.warning {
            alertImportWarning(warning, removeOnCancel: removeOnCancel) {
                completionHandler(result)
            }
            return
        }
        
        completionHandler(result)
    }

    private func alertImportError(_ error: Error, removeOnError: Bool) {
        let message = HostImporter.localizedMessage(forError: error)
        let alert = UIAlertController.asAlert(configurationURL.normalizedFilename, message)
        alert.addCancelAction(L10n.Core.Global.ok)
        viewController?.present(alert, animated: true, completion: nil)

        if removeOnError {
            try? FileManager.default.removeItem(at: configurationURL)
        }
    }

    private func alertImportWarning(_ warning: ConfigurationError, removeOnCancel: Bool, completionHandler: @escaping () -> Void) {
        let message = HostImporter.localizedDetailsMessage(forWarning: warning)
        let alert = UIAlertController.asAlert(configurationURL.normalizedFilename, L10n.Core.ParsedFile.Alerts.PotentiallyUnsupported.message(message))
        alert.addPreferredAction(L10n.Core.Global.ok) {
            completionHandler()
        }
        alert.addCancelAction(L10n.Core.Global.cancel) {
            if removeOnCancel {
                try? FileManager.default.removeItem(at: self.configurationURL)
            }
        }
        viewController?.present(alert, animated: true, completion: nil)
    }

    private func enterPassphraseForHost(at url: URL, removeOnError: Bool, removeOnCancel: Bool, completionHandler: @escaping (OpenVPN.ConfigurationParser.Result) -> Void) {
        let alert = UIAlertController.asAlert(configurationURL.normalizedFilename, L10n.Core.ParsedFile.Alerts.EncryptionPassphrase.message)
        alert.addTextField { (field) in
            field.isSecureTextEntry = true
        }
        alert.addPreferredAction(L10n.Core.Global.ok) {
            guard let passphrase = alert.textFields?.first?.text else {
                return
            }
            self.importHost(
                withPassphrase: passphrase,
                removeOnError: removeOnError,
                removeOnCancel: removeOnCancel,
                completionHandler: completionHandler
            )
        }
        alert.addCancelAction(L10n.Core.Global.cancel) {
            if removeOnCancel {
                try? FileManager.default.removeItem(at: url)
            }
        }
        viewController?.present(alert, animated: true, completion: nil)
    }

    // MARK: Helpers

    private static func localizedMessage(forError error: Error) -> String {
        if let appError = error as? ConfigurationError {
            switch appError {
            case .malformed(let option):
                log.error("Could not parse configuration URL: malformed option, \(option)")
                return L10n.Core.ParsedFile.Alerts.Malformed.message(option)

            case .missingConfiguration(let option):
                log.error("Could not parse configuration URL: missing configuration, \(option)")
                return L10n.Core.ParsedFile.Alerts.Missing.message(option)
                
            case .unsupportedConfiguration(var option):
                if option.contains("external") {
                    option.append(" (see FAQ)")
                }
                log.error("Could not parse configuration URL: unsupported configuration, \(option)")
                return L10n.Core.ParsedFile.Alerts.Unsupported.message(option)
                
            default:
                break
            }
        }
        log.error("Could not parse configuration URL: \(error)")
        return L10n.Core.ParsedFile.Alerts.Parsing.message(error.localizedDescription)
    }
    
    private static func localizedDetailsMessage(forWarning warning: ConfigurationError) -> String {
        switch warning {
        case .malformed(let option):
            return option
            
        case .missingConfiguration(let option):
            return option
            
        case .unsupportedConfiguration(var option):
            if option.contains("external") {
                option.append(" (see FAQ)")
            }
            return option
            
        default:
            return "" // XXX: should never get here
        }
    }
}
