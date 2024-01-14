//
//  StoreKitInApp.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/19/23.
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

import Foundation
import StoreKit

@MainActor
public final class StoreKitInApp<PID>: InAppProtocol where PID: Hashable & RawRepresentable,
                                                           PID.RawValue == String {
    public typealias ProductIdentifier = PID

    private let impl: StoreKitInAppImpl<PID>

    public init() {
        impl = StoreKitInAppImpl()
    }

    public nonisolated func canMakePurchases() -> Bool {
        SKPaymentQueue.canMakePayments()
    }

    public func requestProducts(withIdentifiers identifiers: [PID]) async throws -> [PID: InAppProduct] {
        try await withCheckedThrowingContinuation { continuation in
            impl.requestProducts(withIdentifiers: identifiers) { products in
                continuation.resume(returning: products.reduce(into: [:]) { map, pidProduct in
                    map[pidProduct.key] = pidProduct.value.asInAppProduct
                })
            } failureHandler: { error in
                continuation.resume(throwing: error)
            }
        }
    }

    public func purchase(productWithIdentifier productIdentifier: PID) async throws -> InAppPurchaseResult {
        try await withCheckedThrowingContinuation { continuation in
            impl.purchase(productWithIdentifier: productIdentifier) { result in
                do {
                    let value = try result.get()
                    continuation.resume(returning: value)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func restorePurchases() async throws {
        try await withCheckedThrowingContinuation { continuation in
            impl.restorePurchases { finished, _, _ in
                if finished {
                    continuation.resume()
                }
            }
        }
    }

    public nonisolated func products() -> [InAppProduct] {
        impl.products.map(\.asInAppProduct)
    }

    public nonisolated func product(withIdentifier productIdentifier: PID) -> InAppProduct? {
        guard let skProduct = impl.product(withIdentifier: productIdentifier) else {
            return nil
        }
        return skProduct.asInAppProduct
    }

    public nonisolated func setTransactionsObserver(_ block: @escaping () -> Void) {
        impl.onTransactionsUpdated = block
    }
}

private final class StoreKitInAppImpl<PID: Hashable & RawRepresentable>: NSObject,
        SKProductsRequestDelegate, SKPaymentTransactionObserver
        where PID.RawValue == String {

    typealias ProductObserver = ([PID: SKProduct]) -> Void

    typealias TransactionObserver = (Result<InAppPurchaseResult, Error>) -> Void

    typealias RestoreObserver = (Bool, PID?, Error?) -> Void

    typealias FailureObserver = (Error) -> Void

    private var productsMap: [PID: SKProduct]

    var products: [SKProduct] {
        Array(productsMap.values)
    }

    private var productObservers: [ProductObserver]

    private var productFailureObserver: FailureObserver?

    private var transactionObservers: [String: TransactionObserver]

    private var restoreObservers: [RestoreObserver]

    var onTransactionsUpdated: (() -> Void)?

    override init() {
        productsMap = [:]
        productObservers = []
        productFailureObserver = nil
        transactionObservers = [:]
        restoreObservers = []
        super.init()

        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    func requestProducts(withIdentifiers identifiers: [PID], completionHandler: ProductObserver?, failureHandler: FailureObserver?) {
        let req = SKProductsRequest(productIdentifiers: Set(identifiers.map { $0.rawValue }))
        req.delegate = self
        if let observer = completionHandler {
            productObservers.append(observer)
        }
        productFailureObserver = failureHandler
        req.start()
    }

    @discardableResult
    func purchase(productWithIdentifier productIdentifier: PID, completionHandler: @escaping TransactionObserver) -> Bool {
        guard let product = productsMap[productIdentifier] else {
            return false
        }
        purchase(product: product, completionHandler: completionHandler)
        return true
    }

    func purchase(product: SKProduct, completionHandler: @escaping TransactionObserver) {
        let queue = SKPaymentQueue.default()
        let payment = SKPayment(product: product)
        transactionObservers[product.productIdentifier] = completionHandler
        queue.add(payment)
    }

    func restorePurchases(completionHandler: @escaping RestoreObserver) {
        let queue = SKPaymentQueue.default()
        restoreObservers.append(completionHandler)
        queue.restoreCompletedTransactions()
    }

    func product(withIdentifier productIdentifier: PID) -> SKProduct? {
        productsMap[productIdentifier]
    }

    // MARK: SKProductsRequestDelegate

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.receiveProducts(response.products)
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request as? SKProductsRequest != nil {
            DispatchQueue.main.async {
                self.productFailureObserver?(error)
            }
        }
        DispatchQueue.main.async {
            self.transactionObservers.removeAll()
        }
    }

    private func receiveProducts(_ products: [SKProduct]) {
        productsMap.removeAll()
        for p in products {
            guard let pid = PID(rawValue: p.productIdentifier) else {
                continue
            }
            productsMap[pid] = p
        }
        productObservers.forEach { $0(productsMap) }
        productObservers.removeAll()
    }

    // MARK: SKPaymentTransactionObserver

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }

            let currentRestoreObservers = self.restoreObservers

            for tx in transactions {
                let productIdentifier = tx.payment.productIdentifier
                let observer = self.transactionObservers[productIdentifier]

                switch tx.transactionState {
                case .purchased:
                    queue.finishTransaction(tx)
                    observer?(.success(.done))

                case .restored:
                    queue.finishTransaction(tx)
                    observer?(.success(.done))
                    for r in currentRestoreObservers {
                        guard let pid = PID(rawValue: productIdentifier) else {
                            continue
                        }
                        r(false, pid, nil)
                    }

                case .failed:
                    queue.finishTransaction(tx)
                    if let skError = tx.error as? SKError, skError.code == .paymentCancelled {
                        observer?(.success(.cancelled))
                    } else {
                        observer?(.failure(tx.error ?? InAppError.unknown))
                        for r in currentRestoreObservers {
                            guard let pid = PID(rawValue: productIdentifier) else {
                                continue
                            }
                            r(false, pid, tx.error)
                        }
                    }

                default:
                    break
                }
            }

            self.onTransactionsUpdated?()
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        DispatchQueue.main.async {
            for r in self.restoreObservers {
                r(true, nil, nil)
            }
            self.restoreObservers.removeAll()
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async {
            for r in self.restoreObservers {
                r(true, nil, error)
            }
            self.restoreObservers.removeAll()
        }
    }
}

extension SKProduct {
    public var asInAppProduct: InAppProduct {
        InAppProduct(productIdentifier: productIdentifier,
                     localizedTitle: localizedTitle,
                     localizedDescription: localizedDescription,
                     price: price,
                     localizedPrice: localizedPrice)
    }
}

private extension SKProduct {
    var localizedCurrencyFormatter: NumberFormatter {
        let fmt = NumberFormatter()
        fmt.locale = priceLocale
        fmt.numberStyle = .currency
        return fmt
    }

    var localizedPrice: String? {
        localizedCurrencyFormatter.string(from: price)
    }
}
