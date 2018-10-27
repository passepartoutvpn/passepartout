//
//  ParsedFile+Alerts.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 10/27/18.
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

import Foundation
import UIKit
import TunnelKit
import SwiftyBeaver

private let log = SwiftyBeaver.self

extension ParsedFile {
    static func from(_ url: URL, withErrorAlertIn viewController: UIViewController) -> ParsedFile? {
        log.debug("Parsing configuration URL: \(url)")
        do {
            return try TunnelKitProvider.Configuration.parsed(from: url)
        } catch ApplicationError.missingConfiguration(let option) {
            log.error("Could not parse configuration URL: missing configuration, \(option)")
            let message = L10n.ParsedFile.Alerts.Missing.message(option)
            alertConfigurationImportError(url: url, in: viewController, withMessage: message)
        } catch ApplicationError.unsupportedConfiguration(let option) {
            log.error("Could not parse configuration URL: unsupported configuration, \(option)")
            let message = L10n.ParsedFile.Alerts.Unsupported.message(option)
            alertConfigurationImportError(url: url, in: viewController, withMessage: message)
        } catch let e {
            log.error("Could not parse configuration URL: \(e)")
            let message = L10n.ParsedFile.Alerts.Parsing.message(e.localizedDescription)
            alertConfigurationImportError(url: url, in: viewController, withMessage: message)
        }
        return nil
    }
    
    private static func alertConfigurationImportError(url: URL, in vc: UIViewController, withMessage message: String) {
        let alert = Macros.alert(url.normalizedFilename, message)
//        alert.addDefaultAction(L10n.ParsedFile.Alerts.Buttons.report) {
//            var attach = IssueReporter.Attachments(debugLog: false, configurationURL: url)
//            attach.description = message
//            IssueReporter.shared.present(in: vc, withAttachments: attach)
//        }
        alert.addCancelAction(L10n.Global.ok)
        vc.present(alert, animated: true, completion: nil)
    }
}
