//
//  IssueReporter.swift
//  Passepartout-macOS
//
//  Created by Davide De Rosa on 9/5/19.
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
import TunnelKit
import PassepartoutCore

class IssueReporter: NSObject {
    static let shared = IssueReporter()
    
    override private init() {
        super.init()
    }

    func present(withIssue issue: Issue) {
        if issue.debugLog {
            let alert = Macros.warning(L10n.Core.IssueReporter.title, L10n.Core.IssueReporter.message)
            alert.present(in: nil, withOK: L10n.Core.IssueReporter.Buttons.accept, cancel: L10n.Core.Global.cancel, handler: {
                VPN.shared.requestDebugLog(fallback: AppConstants.Log.debugSnapshot) {
                    self.composeEmail(withDebugLog: $0, issue: issue)
                }
            }, cancelHandler: nil)
        } else {
            composeEmail(withDebugLog: nil, issue: issue)
        }
    }
    
    private func composeEmail(withDebugLog debugLog: String?, issue: Issue) {
        guard let sharing = NSSharingService(named: .composeEmail) else {
            // TODO: show error alert
            return
        }
        sharing.recipients = [AppConstants.IssueReporter.Email.recipient]
        sharing.subject = AppConstants.IssueReporter.Email.subject
       
        var items: [Any] = []

        // delete temporary files on exit
        // NO, they're needed until NSSharingService is dismissed (who knows when?)
//        defer {
//            for item in items {
//                guard let url = item as? URL else {
//                    continue
//                }
//                try? FileManager.default.removeItem(at: url)
//            }
//        }
        
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
        let body = AppConstants.IssueReporter.Email.body(bodyContent, bodyMetadata)
        items.append(body)

        if let raw = debugLog {
            let attachment = DebugLog(raw: raw).decoratedData()
            if let item = attachment.temporaryURL(withFileName: AppConstants.IssueReporter.Filenames.debugLog) {
                items.append(item)
            }
        }
        if let url = issue.configurationURL {
            do {
                let parsedFile = try OpenVPN.ConfigurationParser.parsed(fromURL: url, returnsStripped: true)
                if let attachment = parsedFile.strippedLines?.joined(separator: "\n").data(using: .utf8),
                    let item = attachment.temporaryURL(withFileName: AppConstants.IssueReporter.Filenames.configuration) {

                    items.append(item)
                }
            } catch {
            }
        }

        guard sharing.canPerform(withItems: items) else {
            // TODO: show error alert
            return
        }
        sharing.perform(withItems: items)
    }
}

private extension Data {
    func temporaryURL(withFileName fileName: String) -> URL? {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let dest = tempURL.appendingPathComponent(fileName)
        do {
            try write(to: dest)
        } catch {
            return nil
        }
        return dest
    }
}
