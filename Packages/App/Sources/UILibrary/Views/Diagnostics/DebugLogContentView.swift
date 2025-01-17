//
//  DebugLogContentView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/23/24.
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

import SwiftUI

public struct DebugLogContentView: View {

    @EnvironmentObject
    private var theme: Theme

    public let lines: [String]

    public init(lines: [String]) {
        self.lines = lines
    }

    public var body: some View {
        ScrollViewReader { proxy in
            scrollView
                .onLoad {
                    withAnimation {
                        proxy.scrollTo(lines.count - 1, anchor: .bottom)
                    }
                }
        }
    }
}

#if os(macOS)

private extension DebugLogContentView {
    struct Entry: Identifiable {
        let id: Int

        let line: String
    }

    var scrollView: some View {
        let entries = lines
            .enumerated()
            .map {
                Entry.init(id: $0.offset, line: $0.element)
            }

        return Table(entries) {
            TableColumn("") { entry in
                HStack {
                    EmptyView()
                        .themeTip(entry.line, edge: .bottom, width: 400.0, alignment: .leading) {
                            ThemeImage(.search)
                        }
                        .environmentObject(theme) // TODO: #873, Table loses environment

                    Text(entry.line)
                        .font(.caption)
                }
            }
        }
        .withoutColumnHeaders()
    }
}

#else

private extension DebugLogContentView {
    var scrollView: some View {
        List(lines.indices, id: \.self, rowContent: entryView)
            .listStyle(.plain)
    }

    func entryView(for index: Int) -> some View {
        Text(lines[index])
            .themeMultiLine(true)
            .scrollableOnTV()
            .buttonStyle(.plain)
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .id(index)
    }
}

#endif

#Preview {
    DebugLogContentView(
        lines: Array(repeating: "foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar foobar ", count: 200)
    )
}
