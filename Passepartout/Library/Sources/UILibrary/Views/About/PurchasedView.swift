//
//  PurchasedView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/25/24.
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
import SwiftUI

public struct PurchasedView: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    @State
    private var products: [InAppProduct] = []

    public init() {
    }

    public var body: some View {
        listView
            .themeEmpty(if: isEmpty, message: Strings.Views.Purchased.noPurchases)
            .onLoad {
                Task {
                    products = try await iapManager
                        .purchasableProducts(for: Array(iapManager.purchasedProducts))
                        .sorted {
                            $0.localizedTitle < $1.localizedTitle
                        }
                }
            }
    }
}

private extension PurchasedView {
    var isEmpty: Bool {
        iapManager.purchasedAppBuild == nil && iapManager.purchasedProducts.isEmpty && iapManager.eligibleFeatures.isEmpty
    }

    var features: [String] {
        iapManager
            .eligibleFeatures
            .map(\.localizedDescription)
            .sorted()
    }
}

private extension PurchasedView {
    var listView: some View {
        List {
            downloadSection
            productsSection
            featuresSection
        }
    }

    var downloadSection: some View {
        iapManager.purchasedAppBuild.map { build in
            Group {
                Text(Strings.Views.Purchased.Rows.buildNumber)
                    .themeTrailingValue(build.description)
            }
            .themeSection(header: Strings.Views.Purchased.Sections.Download.header)
        }
    }

    var productsSection: some View {
        Group {
            ForEach(products, id: \.productIdentifier) {
                Text($0.localizedTitle)
                    .themeTrailingValue($0.localizedPrice)
            }
        }
        .themeSection(header: Strings.Views.Purchased.Sections.Products.header)
    }

    var featuresSection: some View {
        Group {
            ForEach(features, id: \.self) {
                Text($0)
            }
        }
        .themeSection(header: Strings.Views.Purchased.Sections.Features.header)
    }
}

#Preview {
    PurchasedView()
        .withMockEnvironment()
}
