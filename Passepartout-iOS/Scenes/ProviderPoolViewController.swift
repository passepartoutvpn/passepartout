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
import Passepartout_Core

private class PoolModel {
    let title: String
    
    var poolsByGroup: [PoolGroup: [Pool]] = [:]
    
    private(set) var sortedGroups: [PoolGroup] = []
    
    var isEmpty: Bool {
        return sortedGroups.isEmpty
    }
    
    init(title: String) {
        self.title = title
    }
    
    func addPool(_ p: Pool) {
        let group = p.group()
        if var existingPools = poolsByGroup[group] {
            existingPools.append(p)
            poolsByGroup[group] = existingPools
        } else {
            poolsByGroup[group] = [p]
        }
    }
    
    func sort() {
        sortedGroups = poolsByGroup.keys.sorted()
    }
}

protocol ProviderPoolViewControllerDelegate: class {
    func providerPoolController(_: ProviderPoolViewController, didSelectPool pool: Pool)
}

class ProviderPoolViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private var models: [PoolModel] = []

    private var currentPool: Pool?
    
    weak var delegate: ProviderPoolViewControllerDelegate?

    func setPools(_ pools: [Pool], currentPoolId: String?) {
        let freeModel = PoolModel(title: L10n.Provider.Pool.Sections.Free.header)
        let paidModel = PoolModel(title: L10n.Provider.Pool.Sections.Paid.header)
        for p in pools {
            if p.isFree ?? false {
                freeModel.addPool(p)
            } else {
                paidModel.addPool(p)
            }
            if p.id == currentPoolId {
                currentPool = p
            }
        }
        freeModel.sort()
        paidModel.sort()

        models = []
        if !freeModel.isEmpty {
            models.append(freeModel)
        }
        if !paidModel.isEmpty {
            models.append(paidModel)
        }
    }
    
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
            tableView.selectRowAsync(at: ip)
        }
    }
}

// MARK: -

extension ProviderPoolViewController: UITableViewDataSource, UITableViewDelegate {
    private var selectedIndexPath: IndexPath? {
        for (i, model) in models.enumerated() {
            for entries in model.poolsByGroup.enumerated() {
                guard let _ = entries.element.value.index(where: { $0.id == currentPool?.id }) else {
                    continue
                }
                guard let row = model.sortedGroups.index(of: entries.element.key) else {
                    continue
                }
                return IndexPath(row: row, section: i)
            }
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard models.count > 1 else {
            return nil
        }
        let model = models[section]
        return model.title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let model = models[section]
        return model.sortedGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section]
        let group = model.sortedGroups[indexPath.row]
        let groupPools = model.poolsByGroup[group]!
        guard let pool = groupPools.first else {
            fatalError("Empty pools in group \(group)")
        }

        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        cell.imageView?.image = pool.logo
        cell.leftText = pool.localizedCountry
        if groupPools.count > 1 {
            cell.rightText = pool.area?.uppercased()
            cell.accessoryType = .detailDisclosureButton // no checkmark!
        } else {
            cell.rightText = pool.areaId?.uppercased()
        }
        cell.isTappable = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = models[indexPath.section]
        let group = model.sortedGroups[indexPath.row]
        let groupPools = model.poolsByGroup[group]!
        guard let pool = groupPools.first else {
            fatalError("Empty pools in group \(group)")
        }
        currentPool = pool
        delegate?.providerPoolController(self, didSelectPool: pool)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let model = models[indexPath.section]
        let group = model.sortedGroups[indexPath.row]
        let groupPools = model.poolsByGroup[group]!
        guard let pool = groupPools.first else {
            fatalError("Empty pools in group \(group)")
        }
        guard groupPools.count > 1 else {
            return
        }
        let vc = OptionViewController<Pool>()
        vc.title = pool.localizedCountry
        vc.options = groupPools
        vc.selectedOption = currentPool
        vc.descriptionBlock = { $0.areaId ?? "" } // XXX: fail gracefully
        vc.selectionBlock = {
            self.currentPool = $0
            self.delegate?.providerPoolController(self, didSelectPool: $0)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
