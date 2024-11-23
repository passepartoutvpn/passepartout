//
//  DonateView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/24/24.
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

public struct DonateView: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var availableProducts: [InAppProduct] = []

    @State
    private var isFetchingProducts = true

    @State
    private var purchasingIdentifier: String?

    @State
    private var isThankYouPresented = false

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    public init() {
    }

    public var body: some View {
        donationsView
            .themeProgress(if: isFetchingProducts)
            .navigationTitle(title)
            .alert(
                title,
                isPresented: $isThankYouPresented,
                actions: thankYouActions,
                message: thankYouMessage
            )
            .task {
                await fetchAvailableProducts()
            }
            .withErrorHandler(errorHandler)
    }
}

private extension DonateView {
    var title: String {
        Strings.Views.Donate.title
    }

    var donationsView: some View {
        Form {
#if os(macOS)
            Section {
                Text(Strings.Views.Donate.Sections.Main.footer)
            }
#endif
            ForEach(availableProducts, id: \.productIdentifier) {
                PaywallProductView(
                    iapManager: iapManager,
                    style: .donation,
                    product: $0,
                    purchasingIdentifier: $purchasingIdentifier,
                    onComplete: onComplete,
                    onError: onError
                )
            }
            .themeSection(footer: Strings.Views.Donate.Sections.Main.footer)
        }
        .themeForm()
        .disabled(purchasingIdentifier != nil)
    }

    func thankYouActions() -> some View {
        Button(Strings.Global.Nouns.ok) {
            dismiss()
        }
    }

    func thankYouMessage() -> some View {
        Text(Strings.Views.Donate.Alerts.ThankYou.message)
    }
}

// MARK: -

private extension DonateView {
    func fetchAvailableProducts() async {
        isFetchingProducts = true
        defer {
            isFetchingProducts = false
        }
        do {
            availableProducts = try await iapManager.purchasableProducts(for: AppProduct.Donations.all)
            guard !availableProducts.isEmpty else {
                throw AppError.emptyProducts
            }
        } catch {
            onError(error, dismissing: true)
        }
    }

    func onComplete(_ productIdentifier: String, result: InAppPurchaseResult) {
        switch result {
        case .done:
            isThankYouPresented = true

        case .pending:
            dismiss()

        case .cancelled:
            break

        case .notFound:
            fatalError("Product not found: \(productIdentifier)")
        }
    }

    func onError(_ error: Error) {
        onError(error, dismissing: false)
    }

    func onError(_ error: Error, dismissing: Bool) {
        errorHandler.handle(error, title: title) {
            if dismissing {
                dismiss()
            }
        }
    }
}

// MARK: - Previews

#Preview {
    DonateView()
        .withMockEnvironment()
}
