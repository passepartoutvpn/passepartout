//
//  ReportIssueButton.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/18/24.
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

import CommonLibrary
import SwiftUI

struct ReportIssueButton {

    @Environment(\.distributionTarget)
    var distributionTarget: DistributionTarget

    let title: String

    var message: String?

    let tunnel: ExtendedTunnel

    let apiManager: APIManager

    let purchasedProducts: Set<AppProduct>

    @Binding
    var isUnableToEmail: Bool

    @State
    var isPending = false

    @State
    var modalRoute: ModalRoute?
}

extension ReportIssueButton {
    enum ModalRoute: Identifiable {
        case comment

        case submit(Issue)

        var id: Int {
            switch self {
            case .comment: return 1
            case .submit: return 2
            }
        }
    }

    func commentInputView() -> some View {
        ThemeTextInputView(
            Strings.Views.Diagnostics.ReportIssue.title,
            message: message,
            isPresented: Binding(presenting: $modalRoute) {
                switch $0 {
                case .comment:
                    return true
                default:
                    return false
                }
            },
            onValidate: {
                !$0.isEmpty
            },
            onSubmit: {
                sendEmail(comment: $0)
            }
        )
    }
}

@MainActor
extension ReportIssueButton {
    var providerLastUpdates: [ProviderID: Timestamp] {
        apiManager.cache.compactMapValues(\.lastUpdate)
    }
}
