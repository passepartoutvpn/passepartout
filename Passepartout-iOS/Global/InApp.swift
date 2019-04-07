//
//  InApp.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 4/6/19.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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

struct InApp {
    enum Donation: String {
        static let all: [Donation] = [
            .tiny,
            .small,
            .medium,
            .big,
            .huge,
            .maxi
        ]

        case tiny = "com.algoritmico.ios.Passepartout.donations.Tiny"

        case small = "com.algoritmico.ios.Passepartout.donations.Small"

        case medium = "com.algoritmico.ios.Passepartout.donations.Medium"

        case big = "com.algoritmico.ios.Passepartout.donations.Big"

        case huge = "com.algoritmico.ios.Passepartout.donations.Huge"

        case maxi = "com.algoritmico.ios.Passepartout.donations.Maxi"
    }

    static func allIdentifiers() -> Set<String> {
        return Set<String>(Donation.all.map { $0.rawValue })
    }
}

class InAppHelper: NSObject {
    enum PurchaseResult {
        case success
        
        case failure
        
        case cancelled
    }
    
    typealias ProductObserver = ([SKProduct]) -> Void
    
    typealias TransactionObserver = (PurchaseResult, Error?) -> Void
    
    static let shared = InAppHelper()
    
    private(set) var products: [SKProduct]
    
    private var productObservers: [ProductObserver]
    
    private var transactionObservers: [String: TransactionObserver]
    
    private override init() {
        products = []
        productObservers = []
        transactionObservers = [:]
        super.init()
        
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func requestProducts(completionHandler: ProductObserver?) {
        let req = SKProductsRequest(productIdentifiers: InApp.allIdentifiers())
        req.delegate = self
        if let observer = completionHandler {
            productObservers.append(observer)
        }
        req.start()
    }
    
    private func receiveProducts(_ products: [SKProduct]) {
        self.products = products
        productObservers.forEach { $0(products) }
        productObservers.removeAll()
    }
    
    func purchase(product: SKProduct, completionHandler: @escaping TransactionObserver) {
        let queue = SKPaymentQueue.default()
        let payment = SKPayment(product: product)
        transactionObservers[product.productIdentifier] = completionHandler
        queue.add(payment)
    }
}

extension InAppHelper: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.receiveProducts(response.products)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        transactionObservers.removeAll()
    }
}

extension InAppHelper: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for tx in transactions {
            let observer = transactionObservers[tx.payment.productIdentifier]

            switch tx.transactionState {
            case .purchased, .restored:
                queue.finishTransaction(tx)
                DispatchQueue.main.async {
                    observer?(.success, nil)
                }

            case .failed:
                queue.finishTransaction(tx)
                if let skError = tx.error as? SKError, skError.code == .paymentCancelled {
                    DispatchQueue.main.async {
                        observer?(.cancelled, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        observer?(.failure, tx.error)
                    }
                }
                
            default:
                break
            }
        }
    }
}
