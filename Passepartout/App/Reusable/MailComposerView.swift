//
//  MailComposerView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/23/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

import SwiftUI
import MessageUI

struct MailComposerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding private var isPresented: Bool

        init(_ view: MailComposerView) {
            _isPresented = view._isPresented
        }

        public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            isPresented = false
        }
    }

    struct Attachment {
        let data: Data

        let mimeType: String

        let fileName: String
    }

    static func canSendMail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }

    @Binding var isPresented: Bool

    let toRecipients: [String]

    let subject: String

    let messageBody: String

    var attachments: [Attachment]?

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailComposerView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(toRecipients)
        vc.setSubject(subject)
        vc.setMessageBody(messageBody, isHTML: false)
        attachments?.forEach {
            vc.addAttachmentData($0.data, mimeType: $0.mimeType, fileName: $0.fileName)
        }
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailComposerView>) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
