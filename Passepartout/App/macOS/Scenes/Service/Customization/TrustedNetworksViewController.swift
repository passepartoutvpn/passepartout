//
//  TrustedNetworksViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/29/18.
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
import PassepartoutCore

class TrustedNetworksViewController: NSViewController, ProfileCustomization {
    private struct Columns {
        static let ssid = NSUserInterfaceItemIdentifier("SSID")

        static let trust = NSUserInterfaceItemIdentifier("Trust")
    }
    
    @IBOutlet private weak var labelTitle: NSTextField!

    @IBOutlet private weak var tableView: NSTableView!
    
    @IBOutlet private weak var buttonAdd: NSButton!

    @IBOutlet private weak var buttonRemove: NSButton!
    
    @IBOutlet private weak var checkTrustEthernet: NSButton!
    
    @IBOutlet private weak var labelTrustEthernetDescription: NSTextField!

    @IBOutlet private weak var checkDisableConnection: NSButton!
    
    @IBOutlet private weak var labelDisableConnectionDescription: NSTextField!

    private let service = TransientStore.shared.service

    private let model = TrustedNetworksUI()
    
    // MARK: ProfileCustomization
    
    var profile: ConnectionProfile?
    
    private lazy var trustedNetworks = profile?.trustedNetworks ?? TrustedNetworks()

    weak var delegate: ProfileCustomizationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelTitle.stringValue = L10n.Core.Service.Sections.Trusted.header.asCaption
        buttonAdd.image = NSImage(named: NSImage.addTemplateName)
        buttonRemove.image = NSImage(named: NSImage.removeTemplateName)
        checkTrustEthernet.title = L10n.Core.Trusted.Ethernet.title
        labelTrustEthernetDescription.stringValue = L10n.Core.Trusted.Ethernet.description
        checkDisableConnection.title = L10n.Core.Service.Cells.TrustedPolicy.caption
        labelDisableConnectionDescription.stringValue = L10n.Core.Service.Sections.Trusted.footer

        checkTrustEthernet.state = trustedNetworks.includesEthernet ? .on : .off
        checkDisableConnection.state = (trustedNetworks.policy == .disconnect) ? .on : .off
        model.delegate = self
        model.load(from: trustedNetworks)
        updateButtons()

        tableView.reloadData()
        for column in tableView.tableColumns {
            switch column.identifier {
            case Columns.ssid:
                column.title = "SSID"
                column.isEditable = false

            case Columns.trust:
                column.title = L10n.Core.Trusted.Columns.Trust.title
                
            default:
                break
            }
        }
        if tableView.numberOfRows > 0 {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
    }
    
    // MARK: Actions
    
    @IBAction private func remove(_ sender: Any?) {
        let index = tableView.selectedRow
        guard index != -1 else {
            return
        }
        model.removeWifi(at: index)
    }

    @IBAction private func toggleTrustEthernet(_ sender: Any?) {
        do {
            try ProductManager.shared.verifyEligible(forFeature: .trustedNetworks)
        } catch {
            checkTrustEthernet.state = .off
            presentPurchaseScreen(forProduct: .trustedNetworks)
            return
        }
        trustedNetworks.includesEthernet = (checkTrustEthernet.state == .on)

        delegate?.profileCustomization(self, didUpdateTrustedNetworks: trustedNetworks)
    }

    @IBAction private func toggleRetainConnection(_ sender: Any?) {
        let isOn = (checkDisableConnection.state == .on)
        let completionHandler: () -> Void = {
            self.trustedNetworks.policy = isOn ? .disconnect : .ignore
        }
        completionHandler()

        delegate?.profileCustomization(self, didUpdateTrustedNetworks: trustedNetworks)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
        if identifier == StoryboardSegue.Service.trustedNetworkAddSegueIdentifier.rawValue {
            do {
                try ProductManager.shared.verifyEligible(forFeature: .trustedNetworks)
            } catch {
                presentPurchaseScreen(forProduct: .trustedNetworks)
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let addVC = segue.destinationController as? TrustedNetworksAddViewController {
            addVC.delegate = self
        }
    }

    // MARK: Helpers
    
    private func updateButtons() {
        buttonRemove.isEnabled = !model.sortedWifis.isEmpty && (tableView.selectedRow != -1)
    }
}

extension TrustedNetworksViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return model.sortedWifis.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < model.sortedWifis.count else { // XXX
            return nil
        }
        
        let wifi = model.sortedWifis[row]
        switch tableColumn?.identifier {
        case Columns.ssid:
            return wifi
            
        case Columns.trust:
            return model.isTrusted(wifi: wifi)
            
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard row < model.sortedWifis.count else { // XXX
            return
        }
        switch tableColumn?.identifier {
//        case Columns.ssid:
//            guard let ssidName = object as? String else {
//                fatalError("Expected a String for trust SSID")
//            }
//            model.renameWifi(at: row, to: ssidName)
            
        case Columns.trust:
            guard let checkTrust = object as? Bool else {
                fatalError("Expected a Bool for trust checkbox state")
            }
            if checkTrust {
                model.enableWifi(at: row)
            } else {
                model.disableWifi(at: row)
            }

        default:
            break
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateButtons()
    }
}

extension TrustedNetworksViewController: TrustedNetworksUIDelegate {
    func trustedNetworksCouldDisconnect(_: TrustedNetworksUI) -> Bool {

        // VPN untouched
        return false
    }

    func trustedNetworksShouldConfirmDisconnection(_: TrustedNetworksUI, triggeredAt rowIndex: Int, completionHandler: @escaping () -> Void) {
        let alert = Macros.warning(
            L10n.Core.Service.Sections.Trusted.header,
            L10n.Core.Service.Alerts.Trusted.WillDisconnectTrusted.message
        )
        alert.present(in: view.window, withOK: L10n.Core.Global.ok, cancel: L10n.Core.Global.cancel, handler: completionHandler, cancelHandler: nil)
    }
    
    func trustedNetworks(_: TrustedNetworksUI, shouldInsertWifiAt rowIndex: Int) {
//        tableView.beginUpdates()
//        tableView.insertRows(at: IndexSet(integer: rowIndex), withAnimation: .slideDown)
//        tableView.endUpdates()
        tableView.reloadData()

        updateButtons()
    }
    
    func trustedNetworks(_: TrustedNetworksUI, shouldReloadWifiAt rowIndex: Int, isTrusted: Bool) {
        //
    }
    
    func trustedNetworks(_: TrustedNetworksUI, shouldDeleteWifiAt rowIndex: Int) {
//        tableView.beginUpdates()
//        tableView.removeRows(at: IndexSet(integer: rowIndex), withAnimation: .slideUp)
//        tableView.endUpdates()
        tableView.reloadData()

        updateButtons()
    }
    
    func trustedNetworksShouldReinstall(_: TrustedNetworksUI) {
        trustedNetworks.includedWiFis = model.trustedWifis
        
        delegate?.profileCustomization(self, didUpdateTrustedNetworks: trustedNetworks)
    }
}

extension TrustedNetworksViewController: TrustedNetworksAddViewControllerDelegate {
    func trustedController(_ trustedController: TrustedNetworksAddViewController, didEnterSSID ssid: String) {
        model.addWifi(ssid)
    }
}
