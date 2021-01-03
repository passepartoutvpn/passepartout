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

protocol ProviderServiceViewDelegate: class {
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
    
    var isEnabled: Bool = true {
        didSet {
            popupCategory.isEnabled = isEnabled
            popupLocation.isEnabled = isEnabled
            popupArea.isEnabled = isEnabled
        }
    }

    private var categories: [PoolCategory] = []
    
    private var sortedGroupsByCategory: [String: [PoolGroup]] = [:]
    
    private var currentCategoryIndex = -1
    
    private var currentLocationIndex = -1
    
    private var currentSortedPools: [Pool] = []

    var profile: ProviderConnectionProfile? {
        didSet {
            guard let profile = profile else {
                categories = []
                sortedGroupsByCategory = [:]
                currentSortedPools = []
                popupCategory.removeAllItems()
                popupLocation.removeAllItems()
                popupArea.removeAllItems()
                return
            }
            reloadData(withProfile: profile)
        }
    }

    var isRefreshingInfrastructure: Bool = false {
        didSet {
            buttonRefreshInfrastructure.isEnabled = !isRefreshingInfrastructure
        }
    }

    weak var delegate: ProviderServiceViewDelegate?
    
    override func viewWillMove(toSuperview newSuperview: NSView?) {
        super.viewWillMove(toSuperview: newSuperview)
        
        labelCategoryCaption.stringValue = L10n.App.Service.Cells.Category.caption.asCaption
        labelLocationCaption.stringValue = L10n.Core.Service.Cells.Provider.Pool.caption.asCaption
        buttonRefreshInfrastructure.image = NSImage(named: NSImage.refreshTemplateName)
    }
    
    // MARK: Actions

    @IBAction private func selectCategory(_ sender: Any?) {
        let index = popupCategory.indexOfSelectedItem
        guard index != currentCategoryIndex else {
            return
        }
        currentCategoryIndex = index
        
        loadLocations(withCategory: index)
        loadAreas(withLocation: 0)
        if let pool = currentSortedPools.first {
            delegate?.providerView(self, didSelectPool: pool)
        }
    }

    @IBAction private func selectLocation(_ sender: Any?) {
        let index = popupLocation.indexOfSelectedItem
        guard index != currentLocationIndex else {
            return
        }
        currentLocationIndex = index

        loadAreas(withLocation: index)
        if let pool = currentSortedPools.first {
            delegate?.providerView(self, didSelectPool: pool)
        }
    }
    
    @IBAction private func selectArea(_ sender: Any?) {
        let pool = currentSortedPools[popupArea.indexOfSelectedItem]
        delegate?.providerView(self, didSelectPool: pool)
    }
    
    @IBAction private func refreshInfrastructure(_ sender: Any?) {
        delegate?.providerViewDidRequestInfrastructureRefresh(self)
    }
    
    // MARK: Helpers

    func reloadData() {
        guard let profile = profile else {
            return
        }
        reloadData(withProfile: profile)
    }
    
    private func reloadData(withProfile profile: ProviderConnectionProfile) {
        categories = profile.infrastructure.categories.sorted { $0.name.lowercased() < $1.name.lowercased() }
        for c in categories {
            sortedGroupsByCategory[c.name] = c.groups.sorted()
        }
        
        popupCategory.removeAllItems()
        categories.forEach {
            let categoryTitle: String
            if $0.name.isEmpty {
                categoryTitle = L10n.App.Global.Values.default
            } else {
                categoryTitle = $0.name.capitalized
            }
            popupCategory.addItem(withTitle: categoryTitle)
        }

        let (a, b, c) = selectPopupsFromCurrentProfile()
        if popupCategory.numberOfItems > 0 {
            popupCategory.selectItem(at: a)
            loadLocations(withCategory: a)
            if popupLocation.numberOfItems > 0 {
                popupLocation.selectItem(at: b)
                loadAreas(withLocation: b)
                if popupArea.numberOfItems > 0 {
                    popupArea.selectItem(at: c)
                }
            }
        }

        currentCategoryIndex = a
        currentLocationIndex = b

        if let lastInfrastructureUpdate = InfrastructureFactory.shared.modificationDate(forName: profile.name) {
            labelLastInfrastructureUpdate.stringValue = L10n.Core.Service.Sections.ProviderInfrastructure.footer(lastInfrastructureUpdate.timestamp)
        }
    }
    
    private func selectPopupsFromCurrentProfile() -> (Int, Int, Int) {
        for (a, category) in categories.enumerated() {
            guard let groups = sortedGroupsByCategory[category.name] else {
                continue
            }
            for (b, group) in groups.enumerated() {

                // FIXME: inefficient, cache sorted pools
                for (c, pool) in group.pools.sortedPools().enumerated() {
                    if pool.id == profile?.poolId {
                        return (a, b, c)
                    }
                }
            }
        }
        return (0, 0, 0)
    }
    
    private func loadLocations(withCategory index: Int) {
        let category = categories[index]
        let menu = NSMenu()
        
        popupLocation.removeAllItems()
        sortedGroupsByCategory[category.name]?.forEach {
            let item = NSMenuItem(title: $0.localizedCountry, action: nil, keyEquivalent: "")
            item.image = $0.logo
            menu.addItem(item)
        }
        popupLocation.menu = menu
    }
    
    private func loadAreas(withLocation index: Int) {
        let categoryIndex = popupCategory.indexOfSelectedItem
        let category = categories[categoryIndex]
        guard let sortedGroups = sortedGroupsByCategory[category.name] else {
            fatalError("No groups in category \(category.name)")
        }
        let group = sortedGroups[index]
        let menu = NSMenu()
        
        popupArea.removeAllItems()
        // FIXME: inefficient, cache sorted pools
        currentSortedPools = group.pools.sortedPools()
        currentSortedPools.forEach {
            guard !$0.secondaryId.isEmpty || currentSortedPools.count > 1 else {
                return
            }
            let title = !$0.secondaryId.isEmpty ? $0.secondaryId : "Default"
            let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            if let extraCountry = $0.extraCountries?.first {
                item.image = extraCountry.image
            }
            menu.addItem(item)
        }
        popupArea.menu = menu
        popupArea.isHidden = menu.items.isEmpty
    }
}
