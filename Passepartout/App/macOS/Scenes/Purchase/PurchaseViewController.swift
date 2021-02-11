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
    func purchaseController(_ purchaseController: PurchaseViewController, didPurchase product: Product?)
}

class PurchaseViewController: NSViewController {
    private struct Columns {
        static let product = NSUserInterfaceItemIdentifier("ProductCellIdentifier")
    }

    private let legacyEmail = "issues+maclegacy@passepartoutvpn.app"
    
    private lazy var legacyEmailURL = URL(string: "mailto:\(legacyEmail)")!

    @IBOutlet private weak var tableView: NSTableView!
    
    @IBOutlet private weak var labelFooter: NSTextField!

    @IBOutlet private weak var labelRestore: NSTextField!

    @IBOutlet private weak var activityPurchase: NSProgressIndicator!

    @IBOutlet private weak var buttonPurchase: NSButton!

    @IBOutlet private weak var buttonRestore: NSButton!

    @IBOutlet private weak var labelLegacy: NSTextField!

    var feature: Product?
    
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

            let bullets: [String] = ProductManager.shared.featureProducts(excluding: [.fullVersion, .fullVersion_iOS, .fullVersion_macOS, .siriShortcuts]).map {
                return $0.localizedTitle
            }.sortedCaseInsensitive()
            platformVersionExtra = bullets.joined(separator: "\n")
        }
        if !pm.hasPurchased(.fullVersion_iOS), let skFullVersion = pm.product(withIdentifier: .fullVersion) {
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
    }
    
    // MARK: NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Core.Purchase.title
        labelFooter.stringValue = L10n.Core.Purchase.Sections.Products.footer
        labelRestore.stringValue = L10n.Core.Purchase.Cells.Restore.description
        buttonPurchase.title = L10n.Core.Purchase.title
        buttonRestore.title = L10n.Core.Purchase.Cells.Restore.title
        
        let legacyEmailLink = NSAttributedString(
            string: legacyEmail,
            attributes: [.link: legacyEmailURL]
        )
        let legacyText = NSMutableAttributedString()
        legacyText.append(NSAttributedString(string: L10n.App.Purchase.Sections.Products.Footer.macLegacy))
        legacyText.append(legacyEmailLink)
        labelLegacy.attributedStringValue = legacyText
        labelLegacy.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(sendLegacyEmail)))

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
    
    @objc private func sendLegacyEmail() {
        NSWorkspace.shared.open(legacyEmailURL)
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
            let product = Product(rawValue: skProduct.productIdentifier)
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
