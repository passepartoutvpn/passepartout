// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import SwiftUI

struct PreferencesExperimentalView: View {

    @EnvironmentObject
    private var configManager: ConfigManager

    @Binding
    var experimental: AppPreferenceValues.Experimental

    private let flags: [ConfigFlag] = [
        .neSocketUDP,
        .neSocketTCP,
        .ovpnCrossConnection,
        .wgCrossConnection
    ]

    private func description(for flag: ConfigFlag) -> String {
        let V = Strings.Entities.Ui.ConfigFlag.self
        switch flag {
        case .neSocketUDP:
            return V.neSocketUDP
        case .neSocketTCP:
            return V.neSocketTCP
        case .ovpnCrossConnection:
            return V.ovpnCrossConnection
        case .wgCrossConnection:
            return V.wgCrossConnection
        default:
            assertionFailure()
            return ""
        }
    }

    var body: some View {
        ForEach(flags, id: \.rawValue) { flag in
            Toggle(isOn: Binding<Bool> {
                experimental.isUsed(flag)
            } set: {
                experimental.setUsed(flag, isUsed: $0)
            }) {
                VStack(alignment: .leading) {
                    Text(description(for: flag))
                    Text(configManager.isActive(flag) ? Strings.Global.Nouns.enabled : Strings.Global.Nouns.disabled)
                        .themeSubtitle()
                }
            }
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
