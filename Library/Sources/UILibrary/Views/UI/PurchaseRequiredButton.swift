//
//  PurchaseRequiredButton.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/17/24.
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

public struct PurchaseRequiredButton<Content>: View where Content: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    let features: Set<AppFeature>?

    @ViewBuilder
    let content: (_ isRestricted: Bool, _ action: @escaping () -> Void) -> Content

    public var body: some View {
        content(iapManager.isRestricted, onTap)
            .opaque(!isEligible)
    }
}

private extension PurchaseRequiredButton {
    func onTap() {
        //
    }

    var isEligible: Bool {
        if let features {
            return iapManager.isEligible(for: features)
        }
        return true
    }
}

// MARK: - Initializers

extension PurchaseRequiredButton where Content == Button<Text> {
    public init(
        _ title: String,
        features: Set<AppFeature>?
    ) {
        self.features = features
        content = { _, action in
            Button(title, action: action)
        }
    }
}

extension PurchaseRequiredButton where Content == PurchaseRequiredImageButtonContent {

    // FIXME: ###, only Profile/ProfileEditor
    public init(for requiring: AppFeatureRequiring?) {
        self.init(features: requiring?.features)
    }

    // FIXME: ###, only Profile/ProfileEditor
    public init(features: Set<AppFeature>?) {
        self.features = features
        content = {
            PurchaseRequiredImageButtonContent(isRestricted: $0, action: $1)
        }
    }
}

public struct PurchaseRequiredImageButtonContent: View {

    @EnvironmentObject
    private var theme: Theme

    let isRestricted: Bool

    let action: () -> Void

    public var body: some View {
        Button(action: action) {
            ThemeImage(isRestricted ? .warning : .upgrade)
                .foregroundStyle(theme.upgradeColor)
                .help(isRestricted ? Strings.Views.Ui.PurchaseRequired.Restricted.help : Strings.Views.Ui.PurchaseRequired.Purchase.help)
        }
        .buttonStyle(.plain)
#if os(macOS)
        .imageScale(.large)
#endif
    }
}
