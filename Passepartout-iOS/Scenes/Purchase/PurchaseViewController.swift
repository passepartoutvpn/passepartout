//
//  PurchaseViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 10/27/19.
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
import SwiftyBeaver
import Convenience

private let log = SwiftyBeaver.self

class PurchaseViewController: UITableViewController, StrongTableHost {
    private var isLoading = true

    var feature: Product!

    private var skFeature: SKProduct?

    private var skFullVersion: SKProduct?

    // MARK: StrongTableHost
    
    var model: StrongTableModel<SectionType, RowType> = StrongTableModel()
    
    func reloadModel() {
        model.clear()
        model.add(.products)
        
        var rows: [RowType] = []
        let pm = ProductManager.shared
        if let skFeature = pm.product(withIdentifier: feature) {
            self.skFeature = skFeature
            rows.append(.feature)
        }
        if let skFullVersion = pm.product(withIdentifier: .fullVersion) {
            self.skFullVersion = skFullVersion
            rows.append(.fullVersion)
        }
        rows.append(.restore)
        model.set(rows, forSection: .products)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let _ = feature else {
            fatalError("No feature set for purchase")
        }

        title = L10n.App.Purchase.title

        // enforce pre iOS 13 behavior
        if #available(iOS 13, *) {
            isModalInPresentation = true
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(close))

        isLoading = true
        tableView.reloadData()

        let hud = HUD(view: view)
        ProductManager.shared.listProducts { [weak self] _ in
            self?.reloadModel()
            self?.isLoading = false
            self?.tableView.reloadData()
            hud.hide()
        }
    }
    
    // MARK: Actions
    
    private func purchaseFeature() {
        guard let sk = skFeature else {
            return
        }
        purchase(sk)
    }

    private func purchaseFullVersion() {
        guard let sk = skFullVersion else {
            return
        }
        purchase(sk)
    }

    private func restorePurchases() {
        let hud = HUD(view: view)
        ProductManager.shared.restorePurchases { [weak self] in
            hud.hide()
            guard $0 == nil else {
                return
            }
            self?.dismiss(animated: true, completion: nil)
        }
    }

    private func purchase(_ skProduct: SKProduct) {
        let hud = HUD(view: view)
        ProductManager.shared.purchase(skProduct) { [weak self] in
            hud.hide()
            guard $0 == .success else {
                if let error = $1 {
                    self?.reportPurchaseError(withProduct: skProduct, error: error)
                }
                return
            }
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func reportPurchaseError(withProduct product: SKProduct, error: Error) {
        log.error("Unable to purchase \(product): \(error)")
        
        let alert = UIAlertController.asAlert(product.localizedTitle, error.localizedDescription)
        alert.addCancelAction(L10n.Core.Global.ok)
        present(alert, animated: true, completion: nil)
    }

    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension PurchaseViewController {
    enum SectionType {
        case products
    }
    
    enum RowType {
        case feature
        
        case fullVersion
        
        case restore
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !isLoading else {
            return 0
        }
        return model.numberOfRows(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaseTableViewCell", for: indexPath) as! PurchaseTableViewCell
        switch model.row(at: indexPath) {
        case .feature:
            guard let product = skFeature else {
                fatalError("Loaded feature cell, yet no corresponding product?")
            }
            cell.fill(product: product)
            
        case .fullVersion:
            guard let product = skFullVersion else {
                fatalError("Loaded full version cell, yet no corresponding product?")
            }
            cell.fill(product: product)
            
        case .restore:
            cell.fill(
                title: L10n.App.Purchase.Cells.Restore.title,
                description: L10n.App.Purchase.Cells.Restore.description
            )
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch model.row(at: indexPath) {
        case .feature:
            purchaseFeature()
            
        case .fullVersion:
            purchaseFullVersion()
            
        case .restore:
            restorePurchases()
        }
    }
}
