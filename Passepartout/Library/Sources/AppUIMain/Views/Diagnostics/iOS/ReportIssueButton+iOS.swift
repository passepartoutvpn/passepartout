//
//  ReportIssueButton+iOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/18/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

#if os(iOS)

import CommonLibrary
import PassepartoutKit
import SwiftUI
import UIKit
import CommonUtils

extension ReportIssueButton: View {
    var body: some View {
        HStack {
            Button(title, action: sendEmail)
            if isPending {
                Spacer()
                ProgressView()
            }
        }
        .disabled(isPending)
        .themeModal(item: $issueBeingReported) {
            MailComposerView(
                isPresented: Binding {
                    issueBeingReported != nil
                } set: {
                    if !$0 {
                        issueBeingReported = nil
                    }
                },
                toRecipients: [$0.to],
                subject: $0.subject,
                messageBody: $0.body,
                attachments: $0.attachments
            )
        }
    }
}

private extension ReportIssueButton {

    @MainActor
    func sendEmail() {
        Task {
            isPending = true
            defer {
                isPending = false
            }
            let issue = await Issue.withMetadata(.init(
                profile: installedProfile,
                provider: currentProvider,
                configuration: .shared,
                versionString: BundleConfiguration.mainVersionString,
                purchasedProducts: purchasedProducts,
                tunnel: tunnel,
                urlForTunnelLog: BundleConfiguration.urlForTunnelLog,
                parameters: Constants.shared.log
            ))
            guard MailComposerView.canSendMail() else {
                openMailTo(with: issue)
                return
            }
            issueBeingReported = issue
        }
    }

    func openMailTo(with issue: Issue) {
        guard let url = URL.mailto(to: issue.to, subject: issue.subject, body: issue.body) else {
            return
        }
        guard UIApplication.shared.canOpenURL(url) else {
            isUnableToEmail = true
            return
        }
        UIApplication.shared.open(url)
    }
}

private extension Issue {
    var attachments: [MailComposerView.Attachment] {
        var list: [MailComposerView.Attachment] = []
        let mimeType = Strings.Unlocalized.Issues.attachmentMimeType
        if let appLog {
            list.append(.init(data: appLog, mimeType: mimeType, fileName: Strings.Unlocalized.Issues.appLogFilename))
        }
        if let tunnelLog {
            list.append(.init(data: tunnelLog, mimeType: mimeType, fileName: Strings.Unlocalized.Issues.tunnelLogFilename))
        }
        return list
    }
}

#endif
