//
//  SendToTVView+macOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/8/25.
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

#if os(macOS)

import CommonLibrary
import CommonUtils
import SwiftUI

struct SendToTVView: View {

    @Binding
    var isPresented: Bool

    let onComplete: (URL, String) async throws -> Void

    @State
    private var addressPort: HTTPAddressPort = .forWebReceiver

    @State
    private var passcode = ""

    @State
    private var isSending = false

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        formView
            .disabled(isSending)
            .toolbar {
                ToolbarItem(placement: .cancellationAction, content: cancelButton)
                ToolbarItem(placement: .confirmationAction, content: confirmButton)
            }
            .themeNavigationStack()
            .withErrorHandler(errorHandler)
    }
}

private extension SendToTVView {
    var formView: some View {
        SendToTVFormView(addressPort: $addressPort, passcode: $passcode)
    }

    func cancelButton() -> some View {
        Button(Strings.Global.Actions.cancel, role: .cancel) {
            isPresented = false
        }
    }

    func confirmButton() -> some View {
        Button(Strings.Global.Actions.send, action: performSend)
            .disabled(isSending)
    }
}

private extension SendToTVView {
    var canSend: Bool {
        addressPort.url != nil
    }

    func performSend() {
        guard let url = addressPort.url else {
            return
        }
        Task {
            do {
                isSending = true
                try await onComplete(url, passcode)
                isSending = false
            } catch {
                isSending = false
                errorHandler.handle(error)
            }
        }
    }
}

#Preview {
    SendToTVView(
        isPresented: .constant(true),
        onComplete: { _, _ in }
    )
    .withMockEnvironment()
}

#endif
