//
//  ImportedHostsViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 10/27/18.
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
import TunnelKit
import SwiftyBeaver
import PassepartoutCore

private let log = SwiftyBeaver.self

class ImportedHostsViewController: UITableViewController {
    private lazy var pendingConfigurationURLs = TransientStore.shared.service.pendingConfigurationURLs().sortedCaseInsensitive()

    private var parsingResult: OpenVPN.ConfigurationParser.Result?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.ImportedHosts.title
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        parsingResult = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !pendingConfigurationURLs.isEmpty else {
            let alert = Macros.alert(
                title,
                L10n.Organizer.Alerts.AddHost.message
            )
            alert.addCancelAction(L10n.Global.ok) {
                self.close()
            }
            present(alert, animated: true, completion: nil)
            return
        }
        if let selectedIP = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIP, animated: true)
        }
    }
    
    // MARK: Actions
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {

        // segue parses configuration file if not yet
        if parsingResult == nil {
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
                return false
            }
            let url = pendingConfigurationURLs[indexPath.row]
            return tryParseURL(url, passphrase: nil, cell: cell)
        }
        return true
    }
    
    private func tryParseURL(_ url: URL, passphrase: String?, cell: UITableViewCell) -> Bool {
        let passphraseBlock: (String) -> Void = { (passphrase) in
            guard self.tryParseURL(url, passphrase: passphrase, cell: cell) else {
                return
            }
            self.perform(segue: StoryboardSegue.Organizer.importHostSegueIdentifier, sender: cell)
        }
        guard let parsingResult = OpenVPN.ConfigurationParser.Result.from(url, withErrorAlertIn: self, passphrase: passphrase, passphraseBlock: passphraseBlock, passphraseCancelBlock: nil) else {
            deselectSelectedRow()
            return false
        }
        self.parsingResult = parsingResult
        
        // postpone segue until alert dismissal
        if let warning = parsingResult.warning {
            OpenVPN.ConfigurationParser.Result.alertImportWarning(url: url, in: self, withWarning: warning) {
                self.deselectSelectedRow()
                if $0 {
                    self.perform(segue: StoryboardSegue.Organizer.importHostSegueIdentifier)
                } else {
                    self.parsingResult = nil
                }
            }
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let wizard = segue.destination as? WizardHostViewController else {
            return
        }
        wizard.parsingResult = parsingResult

        // retain back button
        wizard.navigationItem.leftBarButtonItem = nil
    }
    
    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    private func deselectSelectedRow() {
        if let selectedIP = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIP, animated: true)
        }
    }
}

extension ImportedHostsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingConfigurationURLs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let url = pendingConfigurationURLs[indexPath.row]
        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        cell.leftText = url.normalizedFilename
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let url = pendingConfigurationURLs[indexPath.row]
        try? FileManager.default.removeItem(at: url)
        pendingConfigurationURLs.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .top)
    }
}
