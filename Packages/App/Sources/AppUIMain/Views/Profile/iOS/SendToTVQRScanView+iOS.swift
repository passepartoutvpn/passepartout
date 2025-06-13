//
//  SendToTVQRScanView+iOS.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/10/25.
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

import CommonUtils
import SwiftUI

struct SendToTVQRScanView: View {
    let onLoad: (Error?) -> Void

    let onDetect: (String) -> Void

    @State
    private var isScannerAvailable = true

    var body: some View {
        ZStack {
            videoView
            if isScannerAvailable {
                overlayView
            } else {
                Text("FIXME: ###, scanner unavailable")
            }
        }
    }
}

private extension SendToTVQRScanView {
    var messageView: some View {
        Text(Strings.Views.Profile.SendTv.Qr.message(
            Strings.Global.Nouns.profiles,
            Strings.Views.Tv.Profiles.importLocal,
            Strings.Unlocalized.appleTV
        ))
        .multilineTextAlignment(.center)
        .foregroundStyle(.white)
    }

    var videoView: some View {
        QRScanView(
            isAvailable: $isScannerAvailable,
            onLoad: onLoad,
            onDetect: onDetect
        )
    }

    var overlayView: some View {
        VStack {
            messageView
                .padding(15.0)
                .background(.black.opacity(0.8))
                .cornerRadius(15.0)
                .padding()

            Spacer()
        }
    }
}

// MARK: -

#Preview {
    SendToTVQRScanView(
        onLoad: { _ in },
        onDetect: { _ in }
    )
}

#endif
