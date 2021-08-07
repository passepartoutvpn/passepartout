//
//  ShortcutsAddViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/18/19.
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
import Intents
import PassepartoutCore
import Convenience

@available(iOS 12, *)
class ShortcutsAddViewController: UITableViewController, StrongTableHost {
    weak var delegate: ShortcutsIntentDelegate?

    // MARK: StrongTableModel
    
    let model: StrongTableModel<SectionType, RowType> = {
        let model: StrongTableModel<SectionType, RowType> = StrongTableModel()
        model.add(.vpn)
        model.add(.wifi)
        model.add(.cellular)
        model.set([.connect, .enableVPN, .disableVPN], forSection: .vpn)
        model.set([.trustCurrentWiFi, .untrustCurrentWiFi], forSection: .wifi)
        model.set([.trustCellular, .untrustCellular], forSection: .cellular)
        model.setHeader(L10n.Shortcuts.Add.Sections.Vpn.header, forSection: .vpn)
        model.setHeader(L10n.Shortcuts.Add.Sections.Wifi.header, forSection: .wifi)
        model.setHeader(L10n.Shortcuts.Add.Sections.Cellular.header, forSection: .cellular)
        return model
    }()
    
    func reloadModel() {
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Shortcuts.Add.title
    }

    // MARK: UITableViewController
    
    enum SectionType {
        case vpn

        case wifi

        case cellular
    }
    
    enum RowType {
        case connect // host or provider+location
        
        case enableVPN
        
        case disableVPN
        
        case trustCurrentWiFi
        
        case untrustCurrentWiFi
        
        case trustCellular
        
        case untrustCellular
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        switch model.row(at: indexPath) {
        case .connect:
            cell.leftText = L10n.Shortcuts.Add.Cells.Connect.caption
            
        case .enableVPN:
            cell.leftText = L10n.Shortcuts.Add.Cells.EnableVpn.caption
            
        case .disableVPN:
            cell.leftText = L10n.Shortcuts.Add.Cells.DisableVpn.caption
            
        case .trustCurrentWiFi:
            cell.leftText = L10n.Shortcuts.Add.Cells.TrustCurrentWifi.caption
            
        case .untrustCurrentWiFi:
            cell.leftText = L10n.Shortcuts.Add.Cells.UntrustCurrentWifi.caption
            
        case .trustCellular:
            cell.leftText = L10n.Shortcuts.Add.Cells.TrustCellular.caption
            
        case .untrustCellular:
            cell.leftText = L10n.Shortcuts.Add.Cells.UntrustCellular.caption
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch model.row(at: indexPath) {
        case .connect:
            addConnect()
            
        case .enableVPN:
            addEnable()
            
        case .disableVPN:
            addDisable()
            
        case .trustCurrentWiFi:
            addTrustWiFi()
            
        case .untrustCurrentWiFi:
            addUntrustWiFi()
            
        case .trustCellular:
            addTrustCellular()
            
        case .untrustCellular:
            addUntrustCellular()
        }
    }

    // MARK: Actions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShortcutsConnectToViewController {
            vc.delegate = delegate
        }
    }

    private func addConnect() {
        guard TransientStore.shared.service.hasProfiles() else {
            let alert = UIAlertController.asAlert(
                L10n.Shortcuts.Add.Cells.Connect.caption,
                L10n.Shortcuts.Add.Alerts.NoProfiles.message
            )
            alert.addAction(L10n.Global.ok) {
                if let ip = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: ip, animated: true)
                }
            }
            present(alert, animated: true, completion: nil)
            return
        }
        perform(segue: StoryboardSegue.Shortcuts.connectToSegueIdentifier)
    }
    
    private func addEnable() {
        addShortcut(with: IntentDispatcher.intentEnable())
    }

    private func addDisable() {
        addShortcut(with: IntentDispatcher.intentDisable())
    }
    
    private func addTrustWiFi() {
        addShortcut(with: IntentDispatcher.intentTrustWiFi())
    }
    
    private func addUntrustWiFi() {
        addShortcut(with: IntentDispatcher.intentUntrustWiFi())
    }
    
    private func addTrustCellular() {
        addShortcut(with: IntentDispatcher.intentTrustCellular())
    }
    
    private func addUntrustCellular() {
        addShortcut(with: IntentDispatcher.intentUntrustCellular())
    }
    
    private func addShortcut(with intent: INIntent) {
        delegate?.shortcutsDidSelectIntent(intent: intent)
    }

    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }
}
