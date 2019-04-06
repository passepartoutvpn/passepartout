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
        
        static func allIdentifiers() -> Set<String> {
            return Set<String>(all.map { $0.rawValue })
        }
    }
}

class InAppHelper: NSObject, SKProductsRequestDelegate {
    typealias Observer = ([SKProduct]) -> Void
    
    static let shared = InAppHelper()
    
    private(set) var products: [SKProduct]
    
    private var observers: [Observer]
    
    private override init() {
        products = []
        observers = []
    }
    
    func requestProducts(completionHandler: (([SKProduct]) -> Void)?) {
        let req = SKProductsRequest(productIdentifiers: InApp.Donation.allIdentifiers())
        req.delegate = self
        if let block = completionHandler {
            observers.append(block)
        }
        req.start()
    }
    
    private func receiveProducts(_ products: [SKProduct]) {
        self.products = products
        observers.forEach { $0(products) }
        observers.removeAll()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.receiveProducts(response.products)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        observers.removeAll()
    }
}
