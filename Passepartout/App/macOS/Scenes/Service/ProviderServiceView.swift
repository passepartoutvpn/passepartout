//
//  ProviderServiceView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/13/19.
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

protocol ProviderServiceViewDelegate: AnyObject {
    func providerView(_ providerView: ProviderServiceView, didSelectPool pool: Pool)

    func providerViewDidRequestInfrastructureRefresh(_ providerView: ProviderServiceView)
}

class ProviderServiceView: NSView {
    @IBOutlet private weak var labelCategoryCaption: NSTextField!
    
    @IBOutlet private weak var popupCategory: NSPopUpButton!
    
    @IBOutlet private weak var labelLocationCaption: NSTextField!
    
    @IBOutlet private weak var popupLocation: NSPopUpButton!
    
    @IBOutlet private weak var popupArea: NSPopUpButton!
    
    @IBOutlet private weak var checkOnlyShowsFavorites: NSButton!
    
    @IBOutlet private weak var labelLastInfrastructureUpdate: NSTextField!
    
    @IBOutlet private weak var buttonRefreshInfrastructure: NSButton!
    
    @IBOutlet private weak var buttonFavorite: NSButton!
    
    var isEnabled: Bool = true {
        didSet {
            popupCategory.isEnabled = isEnabled
            popupLocation.isEnabled = isEnabled
            popupArea.isEnabled = isEnabled
        }
    }

    var profile: ProviderConnectionProfile? {
        didSet {
            guard let profile = profile else {
                popupCategory.removeAllItems()
                popupLocation.removeAllItems()
                popupArea.removeAllItems()
                return
            }
            reloadHierarchy(withProfile: profile)
        }
    }

    var isRefreshingInfrastructure: Bool = false {
        didSet {
            buttonRefreshInfrastructure.isEnabled = !isRefreshingInfrastructure
        }
    }
    
    private var onlyShowsFavorites: Bool = false {
        didSet {
            guard let profile = profile else {
                return
            }
            reloadHierarchy(withProfile: profile)
        }
    }
    
    private var categories: [PoolCategory] = []

    private var filteredGroupsByCategory: [String: [PoolGroup]] = [:]

    weak var delegate: ProviderServiceViewDelegate?
    
    override func viewWillMove(toSuperview newSuperview: NSView?) {
        super.viewWillMove(toSuperview: newSuperview)
        
        labelCategoryCaption.stringValue = L10n.Service.Cells.Category.caption.asCaption
        labelLocationCaption.stringValue = L10n.Service.Cells.Provider.Pool.caption.asCaption
        checkOnlyShowsFavorites.title = L10n.Service.Cells.OnlyShowsFavorites.caption
        checkOnlyShowsFavorites.state = .off
        buttonRefreshInfrastructure.image = NSImage(named: NSImage.refreshTemplateName)
        buttonRefreshInfrastructure.toolTip = L10n.Service.Cells.Provider.Refresh.caption
        buttonFavorite.image = NSImage(named: NSImage.bookmarksTemplateName)

        updateFavoriteState()
    }
    
    // MARK: Actions

    @IBAction private func selectCategory(_ sender: Any?) {
        loadLocations()
        loadAreas()
        delegateSelectedPool()
    }

    @IBAction private func selectLocation(_ sender: Any?) {
        loadAreas()
        delegateSelectedPool()
    }
    
    @IBAction private func selectArea(_ sender: Any?) {
        guard let pool = popupArea.selectedItem?.representedObject as? Pool else {
            return
        }
        delegate?.providerView(self, didSelectPool: pool)
    }
    
    @IBAction private func refreshInfrastructure(_ sender: Any?) {
        delegate?.providerViewDidRequestInfrastructureRefresh(self)
    }
    
    @IBAction private func toggleFavorite(_ sender: Any?) {
        guard let category = selectedCategory(), let group = selectedGroup() else {
            return
        }
        let groupId = group.uniqueId(in: category)
        let isFavorite = (buttonFavorite.state == .on)
        if isFavorite {
            profile?.favoriteGroupIds = profile?.favoriteGroupIds ?? []
            profile?.favoriteGroupIds?.append(groupId)
            buttonFavorite.toolTip = L10n.Provider.Pool.Actions.unfavorite
        } else {
            profile?.favoriteGroupIds?.removeAll { $0 == groupId }
            buttonFavorite.toolTip = L10n.Provider.Pool.Actions.favorite
        }

        // disable favorite while filtering favorites
        //
        // 1. reload list to select first
        // 2. if last, disable filter
        if onlyShowsFavorites, let profile = profile, buttonFavorite.state == .off {
            if popupLocation.numberOfItems == 1 {
                onlyShowsFavorites = false
                checkOnlyShowsFavorites.state = .off
            }
            reloadHierarchy(withProfile: profile)
            delegateSelectedPool()
        }
        if profile?.favoriteGroupIds?.isEmpty ?? true {
            checkOnlyShowsFavorites.state = .off
            checkOnlyShowsFavorites.isEnabled = false
        } else {
            checkOnlyShowsFavorites.isEnabled = true
        }
    }

    @IBAction private func toggleOnlyShowsFavorites(_ sender: Any?) {
        onlyShowsFavorites = (checkOnlyShowsFavorites.state == .on)
        delegateSelectedPool()
    }

    // MARK: Helpers

    func reloadData() {
    }
    
    private func reloadHierarchy(withProfile profile: ProviderConnectionProfile) {
        categories = profile.infrastructure.categories.sorted { $0.name.lowercased() < $1.name.lowercased() }
        popupCategory.removeAllItems()
        filteredGroupsByCategory.removeAll()

        let menu = NSMenu()
        categories.forEach { category in
            let item = NSMenuItem()
            item.title = !category.name.isEmpty ? category.name.capitalized : L10n.Global.Values.default
            item.representedObject = category
            menu.addItem(item)

            setFilteredGroups(category.groups, forCategory: category)
        }
        popupCategory.menu = menu

        let (a, b, c) = selectPopupsFromCurrentProfile()
        if popupCategory.numberOfItems > 0 {
            popupCategory.selectItem(at: a)
            loadLocations()
            if popupLocation.numberOfItems > 0 {
                popupLocation.selectItem(at: b)
                loadAreas()
                if popupArea.numberOfItems > 0 {
                    popupArea.selectItem(at: c)
                }
            }
        }

        if let lastInfrastructureUpdate = InfrastructureFactory.shared.modificationDate(forName: profile.name) {
            labelLastInfrastructureUpdate.stringValue = L10n.Service.Sections.ProviderInfrastructure.footer(lastInfrastructureUpdate.timestamp)
        }
        
        checkOnlyShowsFavorites.isEnabled = !(profile.favoriteGroupIds?.isEmpty ?? true)
    }

    // FIXME: inefficient, cache sorted pools
    private func selectPopupsFromCurrentProfile() -> (Int, Int, Int) {
        var a = 0, b = 0, c = 0
        for category in categories {
            b = 0
            for group in filteredGroups(forCategory: category) {
                c = 0
                for pool in group.pools.sortedPools() {
                    if pool.id == profile?.poolId {
                        return (a, b, c)
                    }
                    c += 1
                }
                b += 1
            }
            a += 1
        }
        return (0, 0, 0)
    }
    
    private func loadLocations() {
        guard let category = popupCategory.selectedItem?.representedObject as? PoolCategory else {
            return
        }
        popupLocation.removeAllItems()

        let menu = NSMenu()
        filteredGroups(forCategory: category).forEach {
            let item = NSMenuItem(title: $0.localizedCountry, action: nil, keyEquivalent: "")
            item.image = $0.logo
            item.representedObject = $0 // group
            menu.addItem(item)
        }
        popupLocation.menu = menu
    }
    
    private func loadAreas() {
        guard let group = popupLocation.selectedItem?.representedObject as? PoolGroup else {
            return
        }
        popupArea.removeAllItems()

        // FIXME: inefficient, cache sorted pools
        let menu = NSMenu()
        let pools = group.pools.sortedPools()
        pools.forEach {
            guard !$0.secondaryId.isEmpty || pools.count > 1 else {
                return
            }
            let title = !$0.secondaryId.isEmpty ? $0.secondaryId : L10n.Global.Values.default
            let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            if let extraCountry = $0.extraCountries?.first {
                item.image = extraCountry.image
            }
            item.representedObject = $0 // pool
            menu.addItem(item)
        }
        popupArea.menu = menu
        popupArea.isHidden = menu.items.isEmpty
    }
    
    private func selectedCategory() -> PoolCategory? {
        return popupCategory.selectedItem?.representedObject as? PoolCategory
    }

    private func selectedGroup() -> PoolGroup? {
        return popupLocation.selectedItem?.representedObject as? PoolGroup
    }

    private func selectedPool() -> Pool? {
        guard popupArea.numberOfItems > 0 else {
            guard let group = popupLocation.selectedItem?.representedObject as? PoolGroup else {
                return nil
            }
            return group.pools.first
        }
        return popupArea.itemArray.first?.representedObject as? Pool
    }
    
    private func updateFavoriteState() {
        guard let category = selectedCategory(), let group = selectedGroup() else {
            return
        }
        let groupId = group.uniqueId(in: category)
        let isFavorite = profile?.favoriteGroupIds?.contains(groupId) ?? false
        buttonFavorite.state = isFavorite ? .on : .off
        buttonFavorite.toolTip = (isFavorite ? L10n.Provider.Pool.Actions.unfavorite : L10n.Provider.Pool.Actions.favorite)
    }

    private func delegateSelectedPool() {
        if let pool = selectedPool() {
            updateFavoriteState()
            delegate?.providerView(self, didSelectPool: pool)
        }
    }

    private func filteredGroups(forCategory category: PoolCategory) -> [PoolGroup] {
        return filteredGroupsByCategory[category.name] ?? []
    }
    
    private func setFilteredGroups(_ groups: [PoolGroup], forCategory category: PoolCategory) {
        filteredGroupsByCategory[category.name] = category.groups.filter {
            guard !onlyShowsFavorites else {
                return profile?.favoriteGroupIds?.contains($0.uniqueId(in: category)) ?? false
            }
            return true
        }.sorted()
    }
}
