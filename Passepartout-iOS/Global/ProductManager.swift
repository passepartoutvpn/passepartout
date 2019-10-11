//
//  ProductManager.swift
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
import Convenience

struct ProductManager {
    static let shared = ProductManager()
    
    private let inApp: InApp<Donation>
    
    private init() {
        inApp = InApp()
    }
    
    func listProducts(completionHandler: (([SKProduct]) -> Void)?) {
        guard inApp.products.isEmpty else {
            completionHandler?(inApp.products)
            return
        }
        inApp.requestProducts(withIdentifiers: Donation.all) { _ in
            completionHandler?(self.inApp.products)
        }
    }

    func purchase(_ product: SKProduct, completionHandler: @escaping (InAppPurchaseResult, Error?) -> Void) {
        inApp.purchase(product: product, completionHandler: completionHandler)
    }
}
