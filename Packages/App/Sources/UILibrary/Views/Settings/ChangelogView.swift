//
//  ChangelogView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/2/25.
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

#if !os(tvOS)

import CommonLibrary
import CommonUtils
import PassepartoutKit
import SwiftUI
import WebKit

public struct ChangelogView: View {

    @State
    private var entries: [ChangelogEntry] = []

    public init() {
    }

    public var body: some View {
        Form {
            ForEach(entries, id: \.id) { entry in
                if let url = entry.issueURL {
                    Link(entry.comment, destination: url)
                } else {
                    Text(entry.comment)
                }
            }
            .themeSection(header: versionString)
        }
        .themeForm()
        .themeProgress(if: entries.isEmpty)
        .task {
            await loadChangelog()
        }
    }
}

private extension ChangelogView {
    var versionString: String {
        BundleConfiguration.mainVersionString
    }

    var versionNumber: String {
        BundleConfiguration.mainVersionNumber
    }

    func loadChangelog() async {
        do {
            pp_log(.app, .info, "CHANGELOG: Load for version \(versionNumber)")
            guard let url = Constants.shared.github.urlForChangelog(ofVersion: versionNumber) else {
                throw PassepartoutError(.notFound)
            }
            pp_log(.app, .info, "CHANGELOG: Fetching \(url)")
            let result = try await URLSession.shared.data(from: url)
            guard let text = String(data: result.0, encoding: .utf8) else {
                throw PassepartoutError(.notFound)
            }
            entries = text
                .split(separator: "\n")
                .enumerated()
                .compactMap {
                    ChangelogEntry($0.offset, line: String($0.element))
                }
        } catch {
            pp_log(.app, .error, "CHANGELOG: Unable to load: \(error)")
        }
    }
}

#endif
