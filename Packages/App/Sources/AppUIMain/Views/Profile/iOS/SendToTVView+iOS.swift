//
//  SendToTVView+iOS.swift
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

#if os(iOS)

import CommonLibrary
import CommonUtils
import SwiftUI

// FIXME: ###, upload iOS
extension SendToTVView {
    var body: some View {
        QRScanView { string in
            guard let url = URL(string: string) else {
                return
            }
            path.append(NavigationRoute.enterPasscode(url))
        } onClose: {
#if targetEnvironment(simulator)
//            path.append(NavigationRoute.enterPasscode(URL(string: "http://10.42.0.132:10000")!))
            path.append(NavigationRoute.enterPasscode(URL(string: "http://172.20.10.14:10000")!))
#else
            isPresented = false
#endif
        }
        .navigationDestination(for: NavigationRoute.self, destination: pushDestination)
        .themeNavigationStack(
            closable: true,
            onClose: {
                isPresented = false
            },
            path: $path
        )
    }
}

private struct TVPasscodeView: View {
    let registryCoder: RegistryCoder

    let profile: Profile

    let url: URL

    @Binding
    var isPresented: Bool

    @StateObject
    var errorHandler: ErrorHandler = .default()

    var body: some View {
        PasscodeInputView(length: Constants.shared.webUploader.passcodeLength) { passcode in
            let client = WebUploaderClient(registryCoder: registryCoder, profile: profile)
            do {
                try await client.send(to: url, passcode: passcode)
                isPresented = false
            } catch {
                errorHandler.handle(error)
                throw error
            }
        }
        .withErrorHandler(errorHandler)
    }
}

private extension SendToTVView {
    enum NavigationRoute: Hashable {
        case enterPasscode(URL)
    }

    @ViewBuilder
    func pushDestination(for item: NavigationRoute) -> some View {
        switch item {
        case .enterPasscode(let url):
            TVPasscodeView(
                registryCoder: registryCoder,
                profile: profile,
                url: url,
                isPresented: $isPresented
            )
        }
    }
}

#endif
