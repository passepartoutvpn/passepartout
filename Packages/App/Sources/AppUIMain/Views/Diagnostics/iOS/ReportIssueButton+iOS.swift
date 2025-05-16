//
//  ReportIssueButton+iOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/18/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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
import CommonUtils
import SwiftUI
import UIKit

extension ReportIssueButton: View {
    var body: some View {
        HStack {
            Button(title) {
                modalRoute = .comment
            }
            if isPending {
                Spacer()
                ProgressView()
            }
        }
        .disabled(isPending)
        .themeModal(item: $modalRoute) {
            switch $0 {
            case .comment:
                commentInputView()
            case .submit(let issue):
                emailComposerView(issue: issue)
            }
        }
    }
}

extension ReportIssueButton {
    func emailComposerView(issue: Issue) -> some View {
        MailComposerView(
            isPresented: Binding {
                switch modalRoute {
                case .submit:
                    return true
                default:
                    return false
                }
            } set: {
                if !$0 {
                    modalRoute = nil
                }
            },
            toRecipients: [issue.to],
            subject: issue.subject,
            messageBody: issue.body,
            attachments: issue.attachments
        )
    }

    @MainActor
    func sendEmail(comment: String) {
        Task {
            isPending = true
            defer {
                isPending = false
            }
            let issue = await Issue.withMetadata(.init(
                ctx: .global,
                profile: installedProfile,
                provider: currentProvider,
                versionString: BundleConfiguration.mainVersionString,
                purchasedProducts: purchasedProducts,
                tunnel: tunnel,
                urlForTunnelLog: BundleConfiguration.urlForTunnelLog,
                parameters: Constants.shared.log,
                comment: comment
            ))
            guard MailComposerView.canSendMail() else {
                openMailTo(with: issue)
                return
            }
            modalRoute = .submit(issue)
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
            list.append(.init(data: appLog, mimeType: mimeType, fileName: Constants.shared.log.appPath))
        }
        if let tunnelLog {
            list.append(.init(data: tunnelLog, mimeType: mimeType, fileName: Constants.shared.log.tunnelPath))
        }
        return list
    }
}

#endif
