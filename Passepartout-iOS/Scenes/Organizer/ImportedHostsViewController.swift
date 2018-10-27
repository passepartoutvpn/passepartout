//
//  ImportedHostsViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 10/27/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
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

private let log = SwiftyBeaver.self

class ImportedHostsViewController: UITableViewController {
    private lazy var pendingConfigurationURLs = TransientStore.shared.service.pendingConfigurationURLs().sorted { $0.normalizedFilename < $1.normalizedFilename }

    private var parsedFile: ParsedFile?
    
    weak var wizardDelegate: WizardDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.ImportedHosts.title
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !pendingConfigurationURLs.isEmpty else {
            let alert = Macros.alert(
                L10n.ImportedHosts.title,
                L10n.Organizer.Alerts.AddHost.message
            )
            alert.addCancelAction(L10n.Global.ok) {
                self.close()
            }
            present(alert, animated: true, completion: nil)
            return
        }
    }
    
    // MARK: Actions
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            return false
        }
        let url = pendingConfigurationURLs[indexPath.row]
        guard let parsedFile = ParsedFile.from(url, withErrorAlertIn: self) else {
            if let selectedIP = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIP, animated: true)
            }
            return false
        }
        self.parsedFile = parsedFile
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let wizard = segue.destination as? WizardHostViewController else {
            return
        }
        wizard.parsedFile = parsedFile
        wizard.delegate = wizardDelegate
    }
    
    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
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
}
