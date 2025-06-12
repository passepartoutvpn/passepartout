// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonIAP
import CommonLibrary
import Foundation

public typealias PaywallReason = PaywallModifier.Reason

extension PaywallModifier {
    public enum Action {
        case cancel

        case connect

        case purchase

        case save

        case sendToTV
    }

    public struct Reason: Hashable {
        public let profile: Profile?

        public let requiredFeatures: Set<AppFeature>

        @available(*, deprecated, message: "TODO: #1489, unused in new paywall")
        public let suggestedProducts: Set<AppProduct>?

        public let action: Action

        public init(
            _ profile: Profile?,
            requiredFeatures: Set<AppFeature>,
            suggestedProducts: Set<AppProduct>? = nil,
            action: Action
        ) {
            self.profile = profile
            self.requiredFeatures = requiredFeatures
            self.suggestedProducts = suggestedProducts
            self.action = action
        }

        public var needsConfirmation: Bool {
            action != .purchase
        }
    }
}
