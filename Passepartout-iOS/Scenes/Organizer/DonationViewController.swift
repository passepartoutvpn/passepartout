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
import PassepartoutCore

class DonationViewController: UITableViewController, TableModelHost {
    private var donationList: [InApp.Donation] = []

    private var productsByIdentifier: [String: SKProduct] = [:]
    
    private var isLoading = true
    
    private var isPurchasing = false

    private func setProducts(_ products: [SKProduct]) {
        for p in products {
            productsByIdentifier[p.productIdentifier] = p
        }
        reloadModel()
        tableView.reloadData()
    }
    
    // MARK: TableModel
    
    var model: TableModel<SectionType, RowType> = TableModel()

    func reloadModel() {
        donationList = []
        model.clear()
        
        model.add(.oneTime)
        model.setHeader(L10n.Donation.Sections.OneTime.header, for: .oneTime)
        model.setFooter(L10n.Donation.Sections.OneTime.footer, for: .oneTime)

        guard !isLoading else {
            model.set([.loading], in: .oneTime)
            return
        }
        
        let completeList: [InApp.Donation] = [.tiny, .small, .medium, .big, .huge, .maxi]
        for row in completeList {
            guard let _ = productsByIdentifier[row.rawValue] else {
                continue
            }
            donationList.append(row)
        }
        model.set(.donation, count: donationList.count, in: .oneTime)

        if isPurchasing {
            model.add(.activity)
            model.set([.purchasing], in: .activity)
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Donation.title
        reloadModel()

        let inApp = InAppHelper.shared
        if inApp.products.isEmpty {
            inApp.requestProducts {
                self.isLoading = false
                self.setProducts($0)
            }
        } else {
            isLoading = false
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(for: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.footer(for: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count(for: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch model.row(at: indexPath) {
        case .loading:
            let cell = Cells.activity.dequeue(from: tableView, for: indexPath)
            cell.textLabel?.text = L10n.Donation.Cells.Loading.caption
            return cell

        case .purchasing:
            let cell = Cells.activity.dequeue(from: tableView, for: indexPath)
            cell.textLabel?.text = L10n.Donation.Cells.Purchasing.caption
            return cell

        case .donation:
            let productId = productIdentifier(at: indexPath)
            guard let product = productsByIdentifier[productId] else {
                fatalError("Row with no associated product")
            }
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = product.localizedTitle
            cell.rightText = product.localizedPrice
            cell.isTappable = !isPurchasing
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch model.row(at: indexPath) {
        case .donation:
            guard !isPurchasing else {
                return
            }
            tableView.deselectRow(at: indexPath, animated: true)
            let productId = productIdentifier(at: indexPath)
            guard let product = productsByIdentifier[productId] else {
                fatalError("Row with no associated product")
            }

            isPurchasing = true
            reloadModel()
            tableView.reloadData()
            
            InAppHelper.shared.purchase(product: product) {
                self.handlePurchase(result: $0, error: $1)
            }
            
        default:
            break
        }
    }

    private func handlePurchase(result: InAppHelper.PurchaseResult, error: Error?) {
        let alert: UIAlertController
        switch result {
        case .cancelled:
            isPurchasing = false
            reloadModel()
            tableView.reloadData()
            return

        case .success:
            alert = Macros.alert(L10n.Donation.Alerts.Purchase.Success.title, L10n.Donation.Alerts.Purchase.Success.message)

        case .failure:
            alert = Macros.alert(title, L10n.Donation.Alerts.Purchase.Failure.message(error?.localizedDescription ?? ""))
        }
        alert.addCancelAction(L10n.Global.ok) {
            self.isPurchasing = false
            self.reloadModel()
            self.tableView.reloadData()
        }
        present(alert, animated: true)
    }
}

extension DonationViewController {
    enum SectionType {
        case oneTime

        case activity
    }
    
    enum RowType {
        case loading
        
        case purchasing

        case donation
    }
    
    private func productIdentifier(at indexPath: IndexPath) -> String {
        guard model.row(at: indexPath) == .donation else {
            fatalError("Not a donation row")
        }
        return donationList[indexPath.row].rawValue
    }
}
