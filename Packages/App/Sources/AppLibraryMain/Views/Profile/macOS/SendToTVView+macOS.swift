// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

#if os(macOS)

import CommonLibrary
import CommonUtils
import SwiftUI

struct SendToTVView: View {

    @Binding
    var isPresented: Bool

    let onComplete: (URL, String) async throws -> Void

    @State
    private var address = ""

    @State
    private var port = String(Constants.shared.webReceiver.port)

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
        SendToTVFormView(address: $address, port: $port, passcode: $passcode)
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
    var url: URL? {
        guard let port = Int(port) else {
            return nil
        }
        return URL(httpAddress: address, port: port)
    }

    var canSend: Bool {
        url != nil
    }

    func performSend() {
        guard let url else {
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
