//
//  PurchaseViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/2/21.
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
import PassepartoutCore
import SwiftyBeaver
import Convenience

private let log = SwiftyBeaver.self

protocol PurchaseViewControllerDelegate: class {
    func purchaseController(_ purchaseController: PurchaseViewController, didPurchase product: Product)
}

class PurchaseViewController: NSViewController {
    private struct Columns {
        static let product = NSUserInterfaceItemIdentifier("ProductCellIdentifier")
    }

    @IBOutlet private weak var tableView: NSTableView!
    
    @IBOutlet private weak var labelFooter: NSTextField!

    @IBOutlet private weak var labelRestore: NSTextField!

    @IBOutlet private weak var activityPurchase: NSProgressIndicator!

    @IBOutlet private weak var buttonPurchase: NSButton!

    @IBOutlet private weak var buttonRestore: NSButton!

    var feature: Product!
    
    weak var delegate: PurchaseViewControllerDelegate?

    private var skFeature: SKProduct?
    
    private var skPlatformVersion: SKProduct?

    private var skFullVersion: SKProduct?
    
    private var platformVersionExtra: String?

    private var fullVersionExtra: String?

    var rows: [RowType] = []
    
    func reloadModel() {
        rows = []
        let pm = ProductManager.shared
        if let skPlatformVersion = pm.product(withIdentifier: .fullVersion_macOS) {
            self.skPlatformVersion = skPlatformVersion
            rows.append(.platformVersion)
        }
        if let skFullVersion = pm.product(withIdentifier: .fullVersion) {
            self.skFullVersion = skFullVersion
            rows.append(.fullVersion)
        }
        if let skFeature = pm.product(withIdentifier: feature) {
            self.skFeature = skFeature
            rows.append(.feature)
        }

        let platformBulletsList: [String] = ProductManager.shared.featureProducts(excluding: [.fullVersion, .fullVersion_iOS, .fullVersion_macOS]).map {
            return $0.localizedTitle
        }.sortedCaseInsensitive()
        let platformBullets = platformBulletsList.joined(separator: "\n")
        platformVersionExtra = L10n.Core.Purchase.Cells.FullVersion.extraDescription(platformBullets)

        let fullBulletsList: [String] = ProductManager.shared.featureProducts(excluding: [.fullVersion, .fullVersion_macOS]).map {
            return $0.localizedTitle
        }.sortedCaseInsensitive()
        let fullBullets = fullBulletsList.joined(separator: "\n")
        fullVersionExtra = L10n.Core.Purchase.Cells.FullVersion.extraDescription(fullBullets)
    }
    
    // MARK: NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Core.Purchase.title
        labelFooter.stringValue = L10n.Core.Purchase.Sections.Products.footer
        labelRestore.stringValue = L10n.Core.Purchase.Cells.Restore.description
        buttonPurchase.title = L10n.Core.Purchase.title
        buttonRestore.title = L10n.Core.Purchase.Cells.Restore.title

        guard let _ = feature else {
            fatalError("No feature set for purchase")
        }

        tableView.usesAutomaticRowHeights = true
        tableView.reloadData()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()

        view.window?.styleMask = [.closable, .titled]
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()

        startWaiting()
        ProductManager.shared.listProducts { [weak self] (_, _) in
            self?.reloadModel()
            self?.tableView.reloadData()
            self?.stopWaiting()
        }
    }
    
    // MARK: Actions
    
    @IBAction private func doPurchase(_ sender: Any) {
        guard tableView.selectedRow != -1 else {
            return
        }
        switch rows[tableView.selectedRow] {
        case .feature:
            purchaseFeature()

        case .platformVersion:
            purchasePlatformVersion()

        case .fullVersion:
            purchaseFullVersion()
        }
    }

    @IBAction private func doRestorePurchases(_ sender: Any) {
        startWaiting()
        ProductManager.shared.restorePurchases { [weak self] in
            self?.stopWaiting()
            guard $0 == nil else {
                return
            }
            self?.dismiss(nil)
        }
    }

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

    private func purchase(_ skProduct: SKProduct) {
        startWaiting()
        ProductManager.shared.purchase(skProduct) { [weak self] in
            self?.stopWaiting()
            guard $0 == .success else {
                if let error = $1 {
                    self?.reportPurchaseError(withProduct: skProduct, error: error)
                }
                return
            }

            guard let weakSelf = self else {
                return
            }
            let product = weakSelf.feature.matchesStoreKitProduct(skProduct) ? weakSelf.feature! : .fullVersion
            weakSelf.delegate?.purchaseController(weakSelf, didPurchase: product)

            self?.dismiss(nil)
        }
    }
    
    private func reportPurchaseError(withProduct product: SKProduct, error: Error) {
        log.error("Unable to purchase \(product): \(error)")
        
        let alert = Macros.warning(product.localizedTitle, error.localizedDescription)
        _ = alert.presentModally(withOK: L10n.Core.Global.ok, cancel: nil)
    }

    @objc private func close() {
        dismiss(nil)
    }

    // MARK: Helpers
    
    private func startWaiting() {
        tableView.isEnabled = false
        buttonPurchase.isEnabled = false
        buttonRestore.isEnabled = false
        activityPurchase.isHidden = false
        activityPurchase.startAnimation(nil)
    }
    
    private func stopWaiting() {
        activityPurchase.stopAnimation(nil)
        tableView.isEnabled = true
        buttonPurchase.isEnabled = true
        buttonRestore.isEnabled = true
    }
}

extension PurchaseViewController: NSTableViewDataSource, NSTableViewDelegate {
    enum RowType {
        case feature
        
        case platformVersion
        
        case fullVersion
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let view = tableView.makeView(withIdentifier: Columns.product, owner: nil) as? PurchaseProductView else {
            return nil
        }
        switch rows[row] {
        case .feature:
            guard let product = skFeature else {
                fatalError("Loaded feature cell, yet no corresponding product?")
            }
            view.fill(product: product)

        case .platformVersion:
            guard let product = skPlatformVersion else {
                fatalError("Loaded platform version cell, yet no corresponding product?")
            }
            view.fill(product: product, customDescription: platformVersionExtra)

        case .fullVersion:
            guard let product = skFullVersion else {
                fatalError("Loaded full version cell, yet no corresponding product?")
            }
            view.fill(product: product, customDescription: fullVersionExtra)
        }
        return view
    }
}
