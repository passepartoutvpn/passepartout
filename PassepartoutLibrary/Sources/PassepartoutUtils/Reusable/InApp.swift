//
//  InApp.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/9/19.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

public enum InAppPurchaseResult {
    case done

    case cancelled
}

public enum InAppError: Error {
    case unknown
}

public class InApp<PID: Hashable & RawRepresentable>: NSObject,
        SKProductsRequestDelegate, SKPaymentTransactionObserver
        where PID.RawValue == String {

    public typealias ProductObserver = ([PID: SKProduct]) -> Void

    public typealias TransactionObserver = (Result<InAppPurchaseResult, Error>) -> Void

    public typealias RestoreObserver = (Bool, PID?, Error?) -> Void

    public typealias FailureObserver = (Error) -> Void

    private var productsMap: [PID: SKProduct]

    public var products: [SKProduct] {
        [SKProduct](productsMap.values)
    }

    private var productObservers: [ProductObserver]

    private var productFailureObserver: FailureObserver?

    private var transactionObservers: [String: TransactionObserver]

    private var restoreObservers: [RestoreObserver]

    public override init() {
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

    public func requestProducts(withIdentifiers identifiers: [PID], completionHandler: ProductObserver?, failureHandler: FailureObserver?) {
        let req = SKProductsRequest(productIdentifiers: Set(identifiers.map { $0.rawValue }))
        req.delegate = self
        if let observer = completionHandler {
            productObservers.append(observer)
        }
        productFailureObserver = failureHandler
        req.start()
    }

    @discardableResult
    public func purchase(productWithIdentifier productIdentifier: PID, completionHandler: @escaping TransactionObserver) -> Bool {
        guard let product = productsMap[productIdentifier] else {
            return false
        }
        purchase(product: product, completionHandler: completionHandler)
        return true
    }

    public func purchase(product: SKProduct, completionHandler: @escaping TransactionObserver) {
        let queue = SKPaymentQueue.default()
        let payment = SKPayment(product: product)
        transactionObservers[product.productIdentifier] = completionHandler
        queue.add(payment)
    }

    public func restorePurchases(completionHandler: @escaping RestoreObserver) {
        let queue = SKPaymentQueue.default()
        restoreObservers.append(completionHandler)
        queue.restoreCompletedTransactions()
    }

    public func product(withIdentifier productIdentifier: PID) -> SKProduct? {
        productsMap[productIdentifier]
    }

    // MARK: SKProductsRequestDelegate

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.receiveProducts(response.products)
        }
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
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

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async {
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
        }
    }

    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        DispatchQueue.main.async {
            for r in self.restoreObservers {
                r(true, nil, nil)
            }
            self.restoreObservers.removeAll()
        }
    }

    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async {
            for r in self.restoreObservers {
                r(true, nil, error)
            }
            self.restoreObservers.removeAll()
        }
    }
}

extension SKProduct {
    private var localizedCurrencyFormatter: NumberFormatter {
        let fmt = NumberFormatter()
        fmt.locale = priceLocale
        fmt.numberStyle = .currency
        return fmt
    }

    public var localizedPrice: String? {
        localizedCurrencyFormatter.string(from: price)
    }
}
