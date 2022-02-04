//
//  IssueReporter.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/26/18.
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

import Foundation
import MessageUI
import PassepartoutCore

class IssueReporter: NSObject {
    static let shared = IssueReporter()
    
    private weak var viewController: UIViewController?
    
    override private init() {
        super.init()
    }

    func present(in viewController: UIViewController, withIssue issue: Issue) {
        guard MFMailComposeViewController.canSendMail() else {
            let app = UIApplication.shared
            let V = AppConstants.IssueReporter.Email.self
            let body = V.body(V.template, DebugLog(raw: "--").decoratedString())
            guard let url = URL.mailto(to: V.recipient, subject: V.subject, body: body), app.canOpenURL(url) else {
                let alert = UIAlertController.asAlert(L10n.IssueReporter.title, L10n.Global.emailNotConfigured)
                alert.addCancelAction(L10n.Global.ok)
                viewController.present(alert, animated: true, completion: nil)
                return
            }
            app.open(url, options: [:], completionHandler: nil)
            return
        }
        
        self.viewController = viewController
        
        if issue.debugLog {
            let alert = UIAlertController.asAlert(L10n.IssueReporter.title, L10n.IssueReporter.message)
            alert.addPreferredAction(L10n.IssueReporter.Buttons.accept) {
                VPN.shared.requestDebugLog(fallback: TransientStore.shared.debugSnapshot) {
                    self.composeEmail(withDebugLog: $0, issue: issue)
                }
            }
            alert.addCancelAction(L10n.Global.cancel)
            viewController.present(alert, animated: true, completion: nil)
        } else {
            composeEmail(withDebugLog: nil, issue: issue)
        }
    }
    
    private func composeEmail(withDebugLog debugLog: String?, issue: Issue) {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([AppConstants.IssueReporter.Email.recipient])
        vc.setSubject(AppConstants.IssueReporter.Email.subject)

        let bodyContent = AppConstants.IssueReporter.Email.template
        var bodyMetadata = "--\n\n"
        bodyMetadata += DebugLog(raw: "").decoratedString()
        if let metadata = issue.infrastructureMetadata {
            bodyMetadata += "Provider: \(metadata.description)\n"
            if let lastUpdated = InfrastructureFactory.shared.modificationDate(forName: metadata.name) {
                bodyMetadata += "Last updated: \(lastUpdated)\n"
            }
            bodyMetadata += "\n"
        }
        bodyMetadata += "--"
        vc.setMessageBody(AppConstants.IssueReporter.Email.body(bodyContent, bodyMetadata), isHTML: false)

        if let raw = debugLog {
            let attachment = DebugLog(raw: raw).decoratedData()
            vc.addAttachmentData(attachment, mimeType: AppConstants.IssueReporter.MIME.debugLog, fileName: AppConstants.IssueReporter.Filenames.debugLog)
        }
        if let url = issue.configurationURL {
            do {
                let parsedFile = try OpenVPN.ConfigurationParser.parsed(fromURL: url, returnsStripped: true)
                if let attachment = parsedFile.strippedLines?.joined(separator: "\n").data(using: .utf8) {
                    vc.addAttachmentData(attachment, mimeType: AppConstants.IssueReporter.MIME.configuration, fileName: AppConstants.IssueReporter.Filenames.configuration)
                }
            } catch {
            }
        }
        vc.mailComposeDelegate = self
        vc.apply(.current)
        viewController?.present(vc, animated: true, completion: nil)
    }
}

extension IssueReporter: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        viewController?.dismiss(animated: true, completion: nil)
    }
}
