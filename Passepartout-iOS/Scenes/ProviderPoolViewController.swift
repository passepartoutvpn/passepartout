//
//  ProviderPoolViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 6/12/18.
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

protocol ProviderPoolViewControllerDelegate: class {
    func providerPoolController(_: ProviderPoolViewController, didSelectPool pool: Pool)
}

class ProviderPoolViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    var pools: [Pool] = []
    
    var currentPoolId: String?
    
    weak var delegate: ProviderPoolViewControllerDelegate?

    // MARK: UIViewController

    override func awakeFromNib() {
        super.awakeFromNib()

        applyDetailTitle(Theme.current)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Service.Cells.Provider.Pool.caption
        tableView.reloadData()
        if let ip = selectedIndexPath {
            tableView.scrollToRow(at: ip, at: .middle, animated: false)
        }
    }
}

// MARK: -

extension ProviderPoolViewController: UITableViewDataSource, UITableViewDelegate {
    private var selectedIndexPath: IndexPath? {
        guard let row = pools.index(where: { $0.id == currentPoolId }) else {
            return nil
        }
        return IndexPath(row: row, section: 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pools.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pool = pools[indexPath.row]
        
        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        cell.leftText = pool.name
//        cell.rightText = pool.country
        cell.applyChecked(pool.id == currentPoolId, Theme.current)
        cell.isTappable = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pool = pools[indexPath.row]
        currentPoolId = pool.id
        delegate?.providerPoolController(self, didSelectPool: pool)
    }
}
