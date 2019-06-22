//
//  ProviderPoolViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 6/12/18.
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
import PassepartoutCore

protocol ProviderPoolViewControllerDelegate: class {
    func providerPoolController(_: ProviderPoolViewController, didSelectPool pool: Pool)
}

class ProviderPoolViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private var categories: [PoolCategory] = []

    private var sortedGroupsByCategory: [String: [PoolGroup]] = [:]

    private var currentPool: Pool?
    
    weak var delegate: ProviderPoolViewControllerDelegate?

    func setInfrastructure(_ infrastructure: Infrastructure, currentPoolId: String?) {
        categories = infrastructure.categories.sorted { $0.name.lowercased() < $1.name.lowercased() }
        
        for c in categories {
            sortedGroupsByCategory[c.name] = c.groups.sorted()
        }

        // XXX: uglyyy
        for cat in categories {
            for group in cat.groups {
                for p in group.pools {
                    if p.id == currentPoolId {
                        currentPool = p
                        return
                    }
                }
            }
        }
    }
    
    // MARK: UIViewController

    override func awakeFromNib() {
        super.awakeFromNib()

        applyDetailTitle(Theme.current)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Core.Service.Cells.Provider.Pool.caption
        tableView.reloadData()
        if let ip = selectedIndexPath {
            tableView.selectRowAsync(at: ip)
        }
    }
}

// MARK: -

extension ProviderPoolViewController: UITableViewDataSource, UITableViewDelegate {
    private var selectedIndexPath: IndexPath? {
        for (i, cat) in categories.enumerated() {
            guard let sortedGroups = sortedGroupsByCategory[cat.name] else {
                continue
            }
            for (j, group) in sortedGroups.enumerated() {
                guard let _ = group.pools.firstIndex(where: { $0.id == currentPool?.id }) else {
                    continue
                }
                return IndexPath(row: j, section: i)
            }
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard categories.count > 1 else {
            return nil
        }
        let model = categories[section]
        return model.name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let model = categories[section]
        return model.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let group = poolGroup(at: indexPath)
        guard let pool = group.pools.first else {
            fatalError("Empty pools in group \(group)")
        }

        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        cell.imageView?.image = group.logo
        cell.leftText = pool.localizedCountry
        if group.pools.count > 1 {
            cell.rightText = pool.area?.uppercased()
            cell.accessoryType = .detailDisclosureButton // no checkmark!
        } else {
            cell.rightText = pool.secondaryId
        }
        cell.isTappable = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = poolGroup(at: indexPath)
        guard let pool = group.pools.randomElement() else {
            fatalError("Empty pools in group \(group)")
        }
        currentPool = pool
        delegate?.providerPoolController(self, didSelectPool: pool)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let group = poolGroup(at: indexPath)
        guard group.pools.count > 1 else {
            return
        }
        let vc = OptionViewController<Pool>()
        vc.title = group.localizedCountry
        vc.options = group.pools.sorted {
            guard let lnum = $0.num else {
                return true
            }
            guard let rnum = $1.num else {
                return false
            }
            guard lnum != rnum else {
                return $0.secondaryId < $1.secondaryId
            }
            return lnum < rnum
        }
        vc.selectedOption = currentPool
        vc.descriptionBlock = { $0.secondaryId }
        vc.selectionBlock = {
            self.currentPool = $0
            self.delegate?.providerPoolController(self, didSelectPool: $0)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func poolGroup(at indexPath: IndexPath) -> PoolGroup {
        let model = categories[indexPath.section]
        guard let sortedGroups = sortedGroupsByCategory[model.name] else {
            fatalError("Missing sorted groups for category '\(model.name)'")
        }
        return sortedGroups[indexPath.row]
    }
}
