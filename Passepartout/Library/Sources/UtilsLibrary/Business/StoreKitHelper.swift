//
//  StoreKitHelper.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/9/24.
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

import Combine
import Foundation
import StoreKit

@MainActor
public final class StoreKitHelper<PID>: InAppHelper where PID: RawRepresentable & Hashable & InAppIdentifierProviding,
                                                          PID.RawValue == String {

    private let identifiers: [PID]

    @Published
    public private(set) var products: [PID: InAppProduct]

    @Published
    public private(set) var purchasedIdentifiers: Set<String>

    private var activeTransactions: Set<Transaction>

    private var observer: Task<Void, Never>?

    public init(identifiers: [PID]) {
        self.identifiers = identifiers
        products = [:]
        purchasedIdentifiers = []
        activeTransactions = []

        observer = transactionsObserverTask()
    }

    deinit {
        observer?.cancel()
    }

    public nonisolated var canMakePurchases: Bool {
        AppStore.canMakePayments
    }

    public func fetchProducts() async throws {
        guard products.isEmpty else {
            return
        }
        do {
            let skProducts = try await Product.products(for: identifiers.map(\.rawValue))
            products = skProducts.reduce(into: [:]) {
                guard let pid = PID(rawValue: $1.id) else {
                    return
                }
                $0[pid] = InAppProduct(
                    productIdentifier: $1.id,
                    localizedTitle: $1.displayName,
                    localizedPrice: $1.displayPrice,
                    native: $1
                )
            }
        } catch {
            products = [:]
            throw error
        }
    }

    // TODO: #424, implement purchase
    public func purchase(productWithIdentifier productIdentifier: ProductIdentifier) async throws -> InAppPurchaseResult {
        fatalError("purchase")
    }

    // TODO: #424, implement restore purchases
    public func restorePurchases() async throws {
        fatalError("restorePurchases")
    }
}

private extension StoreKitHelper {
    nonisolated func transactionsObserverTask() -> Task<Void, Never> {
        Task {
            await refreshTransactions()

            for await update in Transaction.updates {
                guard let transaction = try? update.payloadValue else {
                    continue
                }
                await fetchActiveTransactions()
                await transaction.finish()
            }
        }
    }

    func refreshTransactions() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            guard transaction.revocationDate == nil else {
                purchasedIdentifiers.remove(transaction.productID)
                continue
            }
            purchasedIdentifiers.insert(transaction.productID)
        }
    }

    func fetchActiveTransactions() async {
        var activeTransactions: Set<Transaction> = []
        for await entitlement in Transaction.currentEntitlements {
            if let transaction = try? entitlement.payloadValue {
                activeTransactions.insert(transaction)
            }
        }
        self.activeTransactions = activeTransactions
    }
}
