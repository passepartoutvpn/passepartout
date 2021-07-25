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
    
    private var categories: [PoolCategory] = []

    weak var delegate: ProviderServiceViewDelegate?
    
    override func viewWillMove(toSuperview newSuperview: NSView?) {
        super.viewWillMove(toSuperview: newSuperview)
        
        labelCategoryCaption.stringValue = L10n.App.Service.Cells.Category.caption.asCaption
        labelLocationCaption.stringValue = L10n.Core.Service.Cells.Provider.Pool.caption.asCaption
        buttonRefreshInfrastructure.image = NSImage(named: NSImage.refreshTemplateName)
        buttonFavorite.image = NSImage(named: NSImage.bookmarksTemplateName)

        updateFavoriteState()
    }
    
    // MARK: Actions

    @IBAction private func selectCategory(_ sender: Any?) {
        loadLocations()
        loadAreas()
        if let pool = selectedPool() {
            delegate?.providerView(self, didSelectPool: pool)
        }
    }

    @IBAction private func selectLocation(_ sender: Any?) {
        loadAreas()
        if let pool = selectedPool() {
            updateFavoriteState()
            delegate?.providerView(self, didSelectPool: pool)
        }
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
        let isFavorite = buttonFavorite.state == .on
        if isFavorite {
            profile?.favoriteGroupIds = profile?.favoriteGroupIds ?? []
            profile?.favoriteGroupIds?.append(groupId)
        } else {
            profile?.favoriteGroupIds?.removeAll { $0 == groupId }
        }
    }

    // MARK: Helpers

    func reloadData() {
    }
    
    private func reloadHierarchy(withProfile profile: ProviderConnectionProfile) {
        categories = profile.infrastructure.categories.sorted { $0.name.lowercased() < $1.name.lowercased() }
        popupCategory.removeAllItems()

        let menu = NSMenu()
        categories.forEach {
            let item = NSMenuItem()
            item.title = !$0.name.isEmpty ? $0.name.capitalized : L10n.Core.Global.Values.default
            item.representedObject = $0 // category
            menu.addItem(item)
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
            labelLastInfrastructureUpdate.stringValue = L10n.Core.Service.Sections.ProviderInfrastructure.footer(lastInfrastructureUpdate.timestamp)
        }
    }

    // FIXME: inefficient, cache sorted pools
    private func selectPopupsFromCurrentProfile() -> (Int, Int, Int) {
        var a = 0, b = 0, c = 0
        for category in categories {
            b = 0
            for group in category.groups {
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
        category.groups.sorted().forEach {
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
            let title = !$0.secondaryId.isEmpty ? $0.secondaryId : L10n.Core.Global.Values.default
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
    }
}
