//
//  ShortcutsViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 3/18/19.
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
import IntentsUI
import Passepartout_Core

class ShortcutsViewController: UITableViewController, TableModelHost {

    // MARK: TableModel
    
    let model: TableModel<SectionType, RowType> = {
        let model: TableModel<SectionType, RowType> = TableModel()
        model.add(.vpn)
        model.add(.trust)
        model.set([.connect, .enableVPN, .disableVPN], in: .vpn)
        model.set([.trustWiFi, .untrustWiFi, .trustCellular, .untrustCellular], in: .trust)
        model.setHeader(L10n.Shortcuts.Sections.Vpn.header, for: .vpn)
        model.setHeader(L10n.Shortcuts.Sections.Trust.header, for: .trust)
        return model
    }()
    
    func reloadModel() {
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Organizer.Cells.SiriShortcuts.caption
//        itemNext.title = L10n.Global.next
    }
}

extension ShortcutsViewController {
    enum SectionType {
        case vpn

        case trust
    }
    
    enum RowType {
        case connect // host or provider+location
        
        case enableVPN
        
        case disableVPN
        
        case trustWiFi
        
        case untrustWiFi
        
        case trustCellular
        
        case untrustCellular
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(for: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count(for: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        switch model.row(at: indexPath) {
        case .connect:
            cell.leftText = L10n.Shortcuts.Cells.Connect.caption
            
        case .enableVPN:
            cell.leftText = L10n.Shortcuts.Cells.EnableVpn.caption
            
        case .disableVPN:
            cell.leftText = L10n.Shortcuts.Cells.DisableVpn.caption
            
        case .trustWiFi:
            cell.leftText = L10n.Shortcuts.Cells.TrustWifi.caption
            
        case .untrustWiFi:
            cell.leftText = L10n.Shortcuts.Cells.UntrustWifi.caption
            
        case .trustCellular:
            cell.leftText = L10n.Shortcuts.Cells.TrustCellular.caption
            
        case .untrustCellular:
            cell.leftText = L10n.Shortcuts.Cells.UntrustCellular.caption
        }
        cell.apply(Theme.current)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard #available(iOS 12, *) else {
            return
        }
        switch model.row(at: indexPath) {
        case .connect:
            addConnect()
            
        case .enableVPN:
            addEnable()
            
        case .disableVPN:
            addDisable()
            
        case .trustWiFi:
            addTrustWiFi()
            
        case .untrustWiFi:
            addUntrustWiFi()
            
        case .trustCellular:
            addTrustCellular()
            
        case .untrustCellular:
            addUntrustCellular()
        }
    }
}

// MARK: Actions

@available(iOS 12, *)
extension ShortcutsViewController {
    private func addConnect() {
        guard TransientStore.shared.service.hasProfiles() else {
            let alert = Macros.alert(
                L10n.Shortcuts.Cells.Connect.caption,
                L10n.Shortcuts.Alerts.NoProfiles.message
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
        addShortcut(with: EnableVPNIntent())
    }

    private func addDisable() {
        addShortcut(with: DisableVPNIntent())
    }
    
    private func addTrustWiFi() {
        addShortcut(with: TrustCurrentNetworkIntent())
    }
    
    private func addUntrustWiFi() {
        addShortcut(with: UntrustCurrentNetworkIntent())
    }
    
    private func addTrustCellular() {
        addShortcut(with: TrustCellularNetworkIntent())
    }
    
    private func addUntrustCellular() {
        addShortcut(with: UntrustCellularNetworkIntent())
    }
    
    private func addShortcut(with intent: INIntent) {
        guard let shortcut = INShortcut(intent: intent) else {
            return
        }
        let vc = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }
}

@available(iOS 12, *)
extension ShortcutsViewController: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        dismiss(animated: true, completion: nil)
    }
}
