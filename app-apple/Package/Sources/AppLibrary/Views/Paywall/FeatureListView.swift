// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import SwiftUI

enum FeatureListViewStyle {
    case list

#if !os(tvOS)
    case table
#endif
}

struct FeatureListView<Content>: View where Content: View {
    let style: FeatureListViewStyle

    var header: String?

    let features: [AppFeature]

    let content: (AppFeature) -> Content

    var body: some View {
        switch style {
        case .list:
            listView

#if !os(tvOS)
        case .table:
            tableView
#endif
        }
    }
}

private extension FeatureListView {
    var listView: some View {
        ForEach(features.sorted(), id: \.id, content: content)
            .themeSection(header: header)
    }

#if !os(tvOS)
    var tableView: some View {
        Table(features.sorted()) {
            TableColumn(header ?? "", content: content)
        }
    }
#endif
}
