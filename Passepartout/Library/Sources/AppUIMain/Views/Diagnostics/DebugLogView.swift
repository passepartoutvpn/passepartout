//
//  DebugLogView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/31/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

import CommonLibrary
import PassepartoutKit
import SwiftUI
import UtilsLibrary

extension DebugLogView {
    static func withApp(parameters: Constants.Log) -> DebugLogView {
        DebugLogView {
            PassepartoutConfiguration.shared.currentLog(parameters: parameters)
        }
    }

    static func withTunnel(_ tunnel: ConnectionObserver, parameters: Constants.Log) -> DebugLogView {
        DebugLogView {
            await tunnel.currentLog(parameters: parameters)
        }
    }

    static func withURL(_ url: URL) -> DebugLogView {
        DebugLogView {
            do {
                return try String(contentsOf: url)
                    .split(separator: "\n")
                    .map(String.init)
            } catch {
                return []
            }
        }
    }
}

struct DebugLogView: View {
    let fetchLines: () async -> [String]

    @State
    private(set) var currentLines: [String] = []

    var body: some View {
        ZStack {
            if !currentLines.isEmpty {
                contentView
            } else {
                Text(Strings.Global.noContent)
                    .themeEmptyMessage()
            }
        }
        .toolbar(content: toolbarContent)
        .task {
            currentLines = await fetchLines()
        }
    }

    var content: String {
        currentLines.joined(separator: "\n")
    }
}

private extension DebugLogView {

    @ViewBuilder
    func toolbarContent() -> some View {
        copyButton
//        if !currentLines.isEmpty {
//            shareButton
//        }
    }

    var copyButton: some View {
        Button {
            copyToPasteboard(content)
        } label: {
            ThemeImage(.copy)
        }
        .disabled(currentLines.isEmpty)
    }

    // TODO: #658, share as temporary URL (could enable email)
//    var shareButton: some View {
//        ShareLink(item: content)
//    }
}
