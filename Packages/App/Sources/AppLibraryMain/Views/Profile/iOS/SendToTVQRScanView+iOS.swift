// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

#if os(iOS)

import CommonUtils
import SwiftUI

struct SendToTVQRScanView: View {
    let onDetect: (String) -> Void

    let onError: (Error) -> Void

    var body: some View {
        ZStack {
            videoView
            overlayView
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
            onDetect: onDetect,
            onError: onError
        )
    }

    var overlayView: some View {
        VStack {
            messageView
                .padding(15.0)
                .background(.black)
                .cornerRadius(15.0)
                .padding()

            Spacer()
        }
    }
}

// MARK: -

#Preview {
    SendToTVQRScanView(
        onDetect: { _ in },
        onError: { _ in }
    )
}

#endif
