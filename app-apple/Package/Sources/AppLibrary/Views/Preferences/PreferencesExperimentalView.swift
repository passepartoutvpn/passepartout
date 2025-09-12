// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import SwiftUI

struct PreferencesExperimentalView: View {
    @Binding
    var experimental: AppPreferenceValues.Experimental

    private let flags: [ConfigFlag] = [
        .neSocketUDP,
        .neSocketTCP,
        .ovpnCrossConnection,
        .wgCrossConnection
    ]

    private func description(for flag: ConfigFlag) -> String {
        switch flag {
        case .neSocketUDP:
            return "NESocketUDP"
        case .neSocketTCP:
            return "NESocketTCP"
        case .ovpnCrossConnection:
            return "OpenVPN Cross Connection"
        case .wgCrossConnection:
            return "WireGuard Cross Connection"
        default:
            assertionFailure()
            return ""
        }
    }

    var body: some View {
        ForEach(flags, id: \.rawValue) { flag in
            Toggle(description(for: flag), isOn: Binding<Bool> {
                experimental.isUsed(flag)
            } set: {
                experimental.setUsed(flag, isUsed: $0)
            })
        }
    }
}

private extension AppPreferenceValues.Experimental {
    func isUsed(_ flag: ConfigFlag) -> Bool {
        !ignoredConfigFlags.contains(flag)
    }

    mutating func setUsed(_ flag: ConfigFlag, isUsed: Bool) {
        if isUsed {
            ignoredConfigFlags.remove(flag)
        } else {
            ignoredConfigFlags.insert(flag)
        }
    }
}
