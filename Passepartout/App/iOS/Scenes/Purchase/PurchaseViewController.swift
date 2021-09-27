//
//  PurchaseViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/27/19.
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

import UIKit
import StoreKit
import PassepartoutCore
import SwiftyBeaver
import Convenience

private let log = SwiftyBeaver.self

protocol PurchaseViewControllerDelegate: AnyObject {
    func purchaseController(_ purchaseController: PurchaseViewController, didPurchase product: LocalProduct?)
}

class PurchaseViewController: UITableViewController, StrongTableHost {
    private var isLoading = true

    var feature: LocalProduct?
    
    weak var delegate: PurchaseViewControllerDelegate?

    private var skFeature: SKProduct?
    
    private var skPlatformVersion: SKProduct?

    private var skFullVersion: SKProduct?
    
    private var platformVersionExtra: String?

    private var fullVersionExtra: String?

    // MARK: StrongTableHost
    
    var model: StrongTableModel<SectionType, RowType> = StrongTableModel()
    
    func reloadModel() {
        model.clear()
        model.add(.products)
        model.setFooter(L10n.Purchase.Sections.Products.footer, forSection: .products)

        var rows: [RowType] = []
        let pm = ProductManager.shared
        if let skPlatformVersion = pm.product(withIdentifier: .fullVersion_iOS) {
            self.skPlatformVersion = skPlatformVersion
            rows.append(.platformVersion)

            let bullets: [String] = ProductManager.shared.featureProducts(excluding: [.fullVersion, .fullVersion_iOS, .fullVersion_macOS]).map {
                return $0.localizedTitle
            }.sortedCaseInsensitive()
            platformVersionExtra = bullets.joined(separator: "\n")
        }
        if !pm.hasPurchased(.fullVersion_macOS), let skFullVersion = pm.product(withIdentifier: .fullVersion) {
            self.skFullVersion = skFullVersion
            rows.append(.fullVersion)

            let bullets: [String] = ProductManager.shared.featureProducts(including: [.fullVersion_iOS, .fullVersion_macOS]).map {
                return $0.localizedTitle
            }.sortedCaseInsensitive()
            fullVersionExtra = bullets.joined(separator: "\n")
        }
        if let feature = feature, let skFeature = pm.product(withIdentifier: feature) {
            self.skFeature = skFeature
            rows.append(.feature)
        }
        rows.append(.restore)
        model.set(rows, forSection: .products)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Purchase.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(close))

        isLoading = true
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let hud = HUD(view: view)
        ProductManager.shared.listProducts { [weak self] (_, _) in
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
    
    private func purchasePlatformVersion() {
        guard let sk = skPlatformVersion else {
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

            self?.dismiss(animated: true) {
                guard let weakSelf = self else {
                    return
                }
                let product = LocalProduct(rawValue: skProduct.productIdentifier)
                weakSelf.delegate?.purchaseController(weakSelf, didPurchase: product)
            }
        }
    }
    
    private func reportPurchaseError(withProduct product: SKProduct, error: Error) {
        log.error("Unable to purchase \(product): \(error)")
        
        let alert = UIAlertController.asAlert(product.localizedTitle, error.localizedDescription)
        alert.addCancelAction(L10n.Global.ok)
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
        
        case platformVersion
        
        case fullVersion

        case restore
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.footer(forSection: section)
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
            
        case .platformVersion:
            guard let product = skPlatformVersion else {
                fatalError("Loaded platform version cell, yet no corresponding product?")
            }
            cell.fill(product: product, customDescription: platformVersionExtra)

        case .fullVersion:
            guard let product = skFullVersion else {
                fatalError("Loaded full version cell, yet no corresponding product?")
            }
            cell.fill(product: product, customDescription: fullVersionExtra)
            
        case .restore:
            cell.fill(
                title: L10n.Purchase.Cells.Restore.title,
                description: L10n.Purchase.Cells.Restore.description
            )
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch model.row(at: indexPath) {
        case .feature:
            purchaseFeature()
            
        case .platformVersion:
            purchasePlatformVersion()
            
        case .fullVersion:
            purchaseFullVersion()
            
        case .restore:
            restorePurchases()
        }
    }
}
