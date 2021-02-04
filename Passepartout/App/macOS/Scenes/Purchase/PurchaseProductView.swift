//
//  PurchaseProductView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/4/21.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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

import Cocoa
import StoreKit

class PurchaseProductView: NSView {
    @IBOutlet private weak var labelTitle: NSTextField?

    @IBOutlet private weak var labelPrice: NSTextField?

    @IBOutlet private weak var labelDescription: NSTextField?

    func fill(product: SKProduct, customDescription: String? = nil) {
        fill(
            title: product.localizedTitle,
            description: customDescription ?? "\(product.localizedDescription)."
        )
        labelPrice?.stringValue = product.localizedPrice ?? ""
    }

    func fill(title: String, description: String) {
        labelTitle?.stringValue = title
        labelDescription?.stringValue = description
        labelPrice?.stringValue = ""
    }
}
