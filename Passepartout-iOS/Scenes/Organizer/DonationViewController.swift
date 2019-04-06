//
//  DonationViewController.swift
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

import UIKit
import StoreKit
import Passepartout_Core

class DonationViewController: UITableViewController, TableModelHost {
    private var productsByIdentifier: [String: SKProduct] = [:]
    
    private func setProducts(_ products: [SKProduct]) {
        for p in products {
            productsByIdentifier[p.productIdentifier] = p
        }
        reloadModel()
        tableView.reloadData()
    }
    
    // MARK: TableModel
    
    var model: TableModel<SectionType, InApp.Donation> = TableModel()
    
    func reloadModel() {
        model.clear()
        
        let completeList: [InApp.Donation] = [.tiny, .small, .medium, .big, .huge, .maxi]
        var list: [InApp.Donation] = []
        for row in completeList {
            guard let _ = productsByIdentifier[row.rawValue] else {
                continue
            }
            list.append(row)
        }
        model.add(.oneTime)
//        model.add(.recurring)
        model.set(list, in: .oneTime)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Donation.title

        let inApp = InAppHelper.shared
        if inApp.products.isEmpty {
            inApp.requestProducts { self.setProducts($0) }
        } else {
            setProducts(inApp.products)
        }
    }
    
    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITableViewController
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count(for: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let productId = productIdentifier(at: indexPath)
        guard let product = productsByIdentifier[productId] else {
            fatalError("Row with no associated product")
        }
        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        cell.leftText = product.localizedTitle
        cell.rightText = product.localizedPrice
        return cell
    }
}

extension DonationViewController {
    enum SectionType {
        case oneTime
        
        case recurring
    }
    
    private func productIdentifier(at indexPath: IndexPath) -> String {
        return model.row(at: indexPath).rawValue
    }
}
