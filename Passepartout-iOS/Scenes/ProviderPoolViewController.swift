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
import Convenience

protocol ProviderPoolViewControllerDelegate: class {
    func providerPoolController(_: ProviderPoolViewController, didSelectPool pool: Pool)
    
    func providerPoolController(_: ProviderPoolViewController, didUpdateFavoriteGroups favoriteGroupIds: [String])
}

class ProviderPoolViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private var allCategories: [PoolCategory] = []

    private var favoriteCategories: [PoolCategory] = []

    private var currentPool: Pool?
    
    private var isShowingFavorites = false

    var favoriteGroupIds: [String] = []
    
    var isReadonly = false
    
    weak var delegate: ProviderPoolViewControllerDelegate?

    func setInfrastructure(_ infrastructure: Infrastructure, currentPoolId: String?) {
        let sortedCategories = infrastructure.categories.sorted { $0.name.lowercased() < $1.name.lowercased() }
        allCategories = []
        for c in sortedCategories {
            allCategories.append(PoolCategory(
                name: c.name,
                groups: c.groups.sorted(),
                presets: c.presets
            ))
        }

        // XXX: uglyyy
        for cat in allCategories {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Core.Service.Cells.Provider.Pool.caption
        tableView.reloadData()
        if let ip = selectedIndexPath {
            tableView.selectRowAsync(at: ip)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(toggleFavorites))
    }
    
    // MARK: Actions
    
    @objc private func toggleFavorites() {
        isShowingFavorites = !isShowingFavorites
        if isShowingFavorites {
            reloadFavorites()
            navigationItem.rightBarButtonItem?.applyAccent(.current)
        } else {
            navigationItem.rightBarButtonItem?.apply(.current)
        }
        tableView.reloadData()
    }

    private func favoriteGroup(withId groupId: String) {
        favoriteGroupIds.append(groupId)
        delegate?.providerPoolController(self, didUpdateFavoriteGroups: favoriteGroupIds)
    }
    
    private func unfavoriteGroup(in category: PoolCategory, withId groupId: String, deletingRowAt indexPath: IndexPath?) {
        favoriteGroupIds.removeAll(where: { $0 == groupId })
        if let indexPath = indexPath {
            reloadFavorites()
            if category.groups.count == 1 {
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        delegate?.providerPoolController(self, didUpdateFavoriteGroups: favoriteGroupIds)
    }

    private func reloadFavorites() {
        favoriteCategories = []
        for c in allCategories {
            let favoriteGroups = c.groups.filter {
                return favoriteGroupIds.contains($0.uniqueId(in: c))
            }
            guard !favoriteGroups.isEmpty else {
                continue
            }
            favoriteCategories.append(PoolCategory(
                name: c.name,
                groups: favoriteGroups,
                presets: c.presets
            ))
        }
    }
}

// MARK: -

extension ProviderPoolViewController: UITableViewDataSource, UITableViewDelegate {
    private var selectedIndexPath: IndexPath? {
        for (i, cat) in categories.enumerated() {
            for (j, group) in cat.groups.enumerated() {
                guard let _ = group.pools.firstIndex(where: { $0.id == currentPool?.id }) else {
                    continue
                }
                return IndexPath(row: j, section: i)
            }
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isShowingEmptyFavorites {
            return 1
        }
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isShowingEmptyFavorites {
            return nil
        }
        if categories.count == 1 && categories.first?.name == "" {
            return nil
        }
        let model = categories[section]
        return model.name
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if isShowingEmptyFavorites {
            return L10n.App.Provider.Pool.Sections.EmptyFavorites.footer
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowingEmptyFavorites {
            return 0
        }
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
            cell.rightText = pool.area
            cell.accessoryType = .detailDisclosureButton // no checkmark!
        } else {
            cell.rightText = pool.secondaryId
        }
        cell.rightText = cell.rightText?.uppercased()
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
        let vc = SingleOptionViewController<Pool>()
        vc.applyTint(.current)
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isReadonly
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let category = categories[indexPath.section]
        let group = poolGroup(at: indexPath)
        let groupId = group.uniqueId(in: category)

        let action: UIContextualAction
        if favoriteGroupIds.contains(groupId) {
            action = UIContextualAction(style: .destructive, title: L10n.App.Provider.Pool.Actions.unfavorite) {
                self.unfavoriteGroup(in: category, withId: groupId, deletingRowAt: self.isShowingFavorites ? indexPath : nil)
                $2(true)
            }
        } else if !isShowingFavorites {
            action = UIContextualAction(style: .normal, title: L10n.App.Provider.Pool.Actions.favorite) {
                self.favoriteGroup(withId: groupId)
                $2(true)
            }
            action.applyNormal(.current)
        } else {
            return nil
        }

        let cfg = UISwipeActionsConfiguration(actions: [action])
        cfg.performsFirstActionWithFullSwipe = false
        return cfg
    }
    
    // MARK: Helpers
    
    private func poolGroup(at indexPath: IndexPath) -> PoolGroup {
        let model = categories[indexPath.section]
        return model.groups[indexPath.row]
    }
    
    private var categories: [PoolCategory] {
        return isShowingFavorites ? favoriteCategories : allCategories
    }
    
    private var isShowingEmptyFavorites: Bool {
        return isShowingFavorites && favoriteGroupIds.isEmpty
    }
}
