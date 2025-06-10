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

struct SendToTVView: View {

    @Binding
    var isPresented: Bool

    let onComplete: (URL, String) async throws -> Void

    @State
    private var path = NavigationPath()

    var body: some View {
        qrScanView
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

private extension SendToTVView {
    enum NavigationRoute: Hashable {
        case enterPasscode(URL)
    }

    @ViewBuilder
    func pushDestination(for item: NavigationRoute) -> some View {
        switch item {
        case .enterPasscode(let url):
            passcodeView(url: url)
        }
    }
}

private extension SendToTVView {
    var qrScanView: some View {
        SendToTVQRScanView { string in
            guard let url = URL(string: string) else {
                return
            }
            path.append(NavigationRoute.enterPasscode(url))
        } onError: { error in
#if targetEnvironment(simulator)
//            path.append(NavigationRoute.enterPasscode(URL(string: "http://10.42.0.132:10000")!))
            path.append(NavigationRoute.enterPasscode(URL(string: "http://172.20.10.14:10000")!))
#else
            pp_log_g(.app, .error, "Unable to open QR scanner: \(error)")
            isPresented = false
#endif
        }
        .themeNavigationDetail()
        .navigationTitle(Strings.Views.Profile.SendTv.title)
    }

    func passcodeView(url: URL) -> some View {
        SendToTVPasscodeView(length: Constants.shared.webReceiver.passcodeLength) { passcode in
            try await onComplete(url, passcode)
        }
        .themeNavigationDetail()
        .navigationTitle(Strings.Global.Nouns.passcode)
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
