//
//  ImportedHostsViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/27/18.
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
import SwiftyBeaver
import PassepartoutCore

private let log = SwiftyBeaver.self

protocol ImportedHostsViewControllerDelegate: AnyObject {
    func importedHostsController(_: ImportedHostsViewController, didImport url: URL)
}

class ImportedHostsViewController: UITableViewController {
    private lazy var pendingConfigurationURLs = TransientStore.shared.service.pendingConfigurationURLs().sortedCaseInsensitive()
    
    weak var delegate: ImportedHostsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.ImportedHosts.title
    }

    private func selectHost(withUrl url: URL) {
        delegate?.importedHostsController(self, didImport: url)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = pendingConfigurationURLs[indexPath.row]
        selectHost(withUrl: url)
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
