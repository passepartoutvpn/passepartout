//
//  SendToTVPasscodeView+iOS.swift
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

// FIXME: ###, iOS passcode instructions
struct SendToTVPasscodeView: View {

    @EnvironmentObject
    private var registryCoder: RegistryCoder

    let profile: Profile

    let url: URL

    @Binding
    var isPresented: Bool

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        PasscodeInputView(length: Constants.shared.webReceiver.passcodeLength) { passcode in
            let client = WebUploader(registryCoder: registryCoder, profile: profile)
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

#endif
