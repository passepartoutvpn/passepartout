// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import SwiftUI

struct ProfileAttributesView: View {
    enum Attribute {
        case shared

        case tv
    }

    let attributes: [Attribute]

    let isRemoteImportingEnabled: Bool

    var body: some View {
        if !attributes.isEmpty {
            ZStack(alignment: .centerFirstTextBaseline) {
                Group {
                    ThemeImage(.cloudOn)
                    ThemeImage(.cloudOff)
                    ThemeImage(.tvOn)
                    ThemeImage(.tvOff)
                }
                .hidden()

                HStack(alignment: .firstTextBaseline) {
                    ForEach(imageModels, id: \.name) {
                        ThemeImage($0.name)
                            .help($0.help)
                    }
                }
            }
            .foregroundStyle(.secondary)
        }
    }

    var imageModels: [(name: Theme.ImageName, help: String)] {
        attributes.map {
            switch $0 {
            case .shared:
                return (
                    isRemoteImportingEnabled ? .cloudOn : .cloudOff,
                    Strings.Unlocalized.iCloud
                )

            case .tv:
                return (
                    isRemoteImportingEnabled ? .tvOn : .tvOff,
                    Strings.Unlocalized.appleTV
                )
            }
        }
    }
}

#Preview {
    struct ContentView: View {

        @State
        private var isRemoteImportingEnabled = false

        let timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()

        var body: some View {
            ProfileAttributesView(
                attributes: [.shared, .tv],
                isRemoteImportingEnabled: isRemoteImportingEnabled
            )
            .onReceive(timer) { _ in
                isRemoteImportingEnabled.toggle()
            }
            .border(.black)
            .padding()
            .withMockEnvironment()
        }
    }

    return ContentView()
}

#Preview("Row Alignment") {
    IconsPreview()
        .withMockEnvironment()
}

struct IconsPreview: View {
    var body: some View {
        Form {
            HStack(alignment: .firstTextBaseline) {
                ThemeImage(.cloudOn)
                ThemeImage(.cloudOff)
                ThemeImage(.tvOn)
                ThemeImage(.tvOff)
                ThemeImage(.info)
            }
        }
        .themeForm()
    }
}
