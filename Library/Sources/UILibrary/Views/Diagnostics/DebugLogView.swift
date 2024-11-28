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
import CommonUtils
import PassepartoutKit
import SwiftUI

public struct DebugLogView<Content>: View where Content: View {
    private let fetchLines: () async -> [String]

    private let content: ([String]) -> Content

    @State
    private(set) var currentLines: [String] = []

    public var body: some View {
        content(currentLines)
            .monospaced()
            .themeEmpty(if: currentLines.isEmpty, message: Strings.Global.Nouns.noContent)
            .toolbar(content: toolbarContent)
            .task {
                currentLines = await fetchLines()
            }
    }
}

private extension DebugLogView {

    @ViewBuilder
    func toolbarContent() -> some View {
#if !os(tvOS)
        copyButton
#endif
//        if !currentLines.isEmpty {
//            shareButton
//        }
    }

    var copyButton: some View {
        Button {
            Utils.copyToPasteboard(currentLines.joined(separator: "\n"))
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

// MARK: - Shortcuts

extension DebugLogView {
    public init(
        withAppParameters parameters: Constants.Log,
        content: @escaping ([String]) -> Content
    ) {
        self.init {
            PassepartoutConfiguration.shared.currentLog(parameters: parameters)
        } content: {
            content($0)
        }
    }

    public init(
        withTunnel tunnel: ExtendedTunnel,
        parameters: Constants.Log,
        content: @escaping ([String]) -> Content
    ) {
        self.init {
            await tunnel.currentLog(parameters: parameters)
        } content: {
            content($0)
        }
    }

    public init(
        withURL url: URL,
        content: @escaping ([String]) -> Content
    ) {
        self.init {
            do {
                return try String(contentsOf: url)
                    .split(separator: "\n")
                    .map(String.init)
            } catch {
                return []
            }
        } content: {
            content($0)
        }
    }
}
