//
//  IssueReporter.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/26/18.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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
import TunnelKit
import MessageUI
import PassepartoutCore

class IssueReporter: NSObject {
    struct Attachments {
        let debugLog: Bool
        
        let configurationURL: URL?
        
        var description: String?
        
        init(debugLog: Bool, configurationURL: URL?) {
            self.debugLog = debugLog
            self.configurationURL = configurationURL
        }

        init(debugLog: Bool, profile: ConnectionProfile) {
            let url = TransientStore.shared.service.configurationURL(for: profile)
            self.init(debugLog: debugLog, configurationURL: url)
        }
    }
    
    static let shared = IssueReporter()
    
    private weak var viewController: UIViewController?
    
    override private init() {
        super.init()
    }

    func present(in viewController: UIViewController, withAttachments attachments: Attachments) {
        guard MFMailComposeViewController.canSendMail() else {
            let app = UIApplication.shared
            let V = AppConstants.IssueReporter.Email.self
            let body = V.body(V.template, DebugLog(raw: "--").decoratedString())
            guard let url = Utils.mailto(to: V.recipient, subject: V.subject, body: body), app.canOpenURL(url) else {
                let alert = Macros.alert(L10n.Core.IssueReporter.title, L10n.Core.Global.emailNotConfigured)
                alert.addCancelAction(L10n.Core.Global.ok)
                viewController.present(alert, animated: true, completion: nil)
                return
            }
            app.open(url, options: [:], completionHandler: nil)
            return
        }
        
        self.viewController = viewController
        
        if attachments.debugLog {
            let alert = Macros.alert(L10n.Core.IssueReporter.title, L10n.Core.IssueReporter.message)
            alert.addDefaultAction(L10n.Core.IssueReporter.Buttons.accept) {
                VPN.shared.requestDebugLog(fallback: AppConstants.Log.debugSnapshot) {
                    self.composeEmail(withDebugLog: $0, configurationURL: attachments.configurationURL, description: attachments.description)
                }
            }
            alert.addCancelAction(L10n.Core.Global.cancel)
            viewController.present(alert, animated: true, completion: nil)
        } else {
            composeEmail(withDebugLog: nil, configurationURL: attachments.configurationURL, description: attachments.description)
        }
    }
    
    private func composeEmail(withDebugLog debugLog: String?, configurationURL: URL?, description: String?) {
        let metadata = DebugLog(raw: "--").decoratedString()
        
        let vc = MFMailComposeViewController()
        vc.setToRecipients([AppConstants.IssueReporter.Email.recipient])
        vc.setSubject(AppConstants.IssueReporter.Email.subject)
        vc.setMessageBody(AppConstants.IssueReporter.Email.body(description ?? AppConstants.IssueReporter.Email.template, metadata), isHTML: false)
        if let raw = debugLog {
            let attachment = DebugLog(raw: raw).decoratedData()
            vc.addAttachmentData(attachment, mimeType: AppConstants.IssueReporter.MIME.debugLog, fileName: AppConstants.IssueReporter.Filenames.debugLog)
        }
        if let url = configurationURL {
            do {
                let parsedFile = try OpenVPN.ConfigurationParser.parsed(fromURL: url, returnsStripped: true)
                if let attachment = parsedFile.strippedLines?.joined(separator: "\n").data(using: .utf8) {
                    vc.addAttachmentData(attachment, mimeType: AppConstants.IssueReporter.MIME.configuration, fileName: AppConstants.IssueReporter.Filenames.configuration)
                }
            } catch {
            }
        }
        vc.mailComposeDelegate = self
        vc.apply(Theme.current)
        viewController?.present(vc, animated: true, completion: nil)
    }
}

extension IssueReporter: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        viewController?.dismiss(animated: true, completion: nil)
    }
}
