//
//  StatusMenu.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/14/19.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
import StoreKit
import PassepartoutCore
import Convenience

class StatusMenu: NSObject {
    static let didAddProfile = Notification.Name("didAddProfile")

    static let didRenameProfile = Notification.Name("didRenameProfile")

    static let didRemoveProfile = Notification.Name("didRemoveProfile")

    static let willDeactivateProfile = Notification.Name("willDeactivateProfile")

    static let didActivateProfile = Notification.Name("didActivateProfile")
    
    static let didUpdateProfile = Notification.Name("didUpdateProfile")

    static let shared = StatusMenu()

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    private let service = TransientStore.shared.service
    
    private var vpn: GracefulVPN {
        return GracefulVPN(service: service)
    }

    // MARK: Button images

    private let imageStatusActive = Asset.Assets.statusActive.image

    private let imageStatusPending = Asset.Assets.statusPending.image

    // MARK: Menu references
    
    private let menu = NSMenu()
    
    private let menuAllProfiles = NSMenu()

    private lazy var itemSwitchProfile = NSMenuItem(title: L10n.Menu.SwitchProfile.title, action: nil, keyEquivalent: "")
    
    private var itemsAllProfiles: [NSMenuItem] = []

    private lazy var itemProfileName = NSMenuItem(title: "", action: nil, keyEquivalent: "")

    private var itemsProfile: [NSMenuItem] = []
    
    private lazy var itemPool = NSMenuItem(title: "", action: nil, keyEquivalent: "")

    private lazy var itemToggleVPN = NSMenuItem(title: L10n.Service.Cells.Vpn.TurnOn.caption, action: nil, keyEquivalent: "")

    private lazy var itemReconnectVPN = NSMenuItem(title: L10n.Service.Cells.Reconnect.caption, action: #selector(reconnectVPN), keyEquivalent: "")
    
    private override init() {
        super.init()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(vpnDidUpdate), name: VPN.didChangeStatus, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func install() {
        guard let _ = statusItem.button else {
            return
        }
        setStatusImage(for: .inactive)
        
        VPN.shared.prepare {
            self.rebuild()
            self.statusItem.menu = self.menu
            self.service.delegate = self
            self.reloadVpnStatus()
        }
    }
    
    private func rebuild() {
        menu.removeAllItems()

        // main actions

        let itemShow = NSMenuItem(title: L10n.Menu.Show.title, action: #selector(showOrganizer), keyEquivalent: "")
        let itemPreferences = NSMenuItem(title: L10n.Menu.Preferences.title.asContinuation, action: #selector(showPreferences), keyEquivalent: ",")
        itemShow.target = self
        itemPreferences.target = self
        menu.addItem(itemShow)
        menu.addItem(itemPreferences)
        menu.addItem(itemSwitchProfile)
        reloadProfiles()
        menu.addItem(.separator())

        // active profile
        
        menu.addItem(itemProfileName)
        setActiveProfile(service.activeProfile)
        menu.addItem(.separator())

        // support
        
        let menuSupport = NSMenu()
        let itemCommunity = NSMenuItem(title: L10n.Organizer.Cells.JoinCommunity.caption.asContinuation, action: #selector(joinCommunity), keyEquivalent: "")
        let itemDonate = NSMenuItem(title: L10n.Organizer.Cells.Donate.caption, action: nil, keyEquivalent: "")
//        let itemGitHubSponsors = NSMenuItem(title: L10n.Organizer.Cells.GithubSponsors.caption.asContinuation, action: #selector(seeGitHubSponsors), keyEquivalent: "")
//        let itemTranslate = NSMenuItem(title: L10n.Organizer.Cells.Translate.caption.asContinuation, action: #selector(offerToTranslate), keyEquivalent: "")

        let menuDonate = NSMenu()
        ProductManager.shared.listProducts { [weak self] products, error in
            self?.addDonations(fromProducts: products ?? [], to: menuDonate)
        }

        menuSupport.setSubmenu(menuDonate, for: itemDonate)
        let itemFAQ = NSMenuItem(title: L10n.About.Cells.Faq.caption.asContinuation, action: #selector(visitFAQ), keyEquivalent: "")
        itemCommunity.target = self
//        itemDonate.target = self
//        itemGitHubSponsors.target = self
//        itemTranslate.target = self
        itemFAQ.target = self
        menuSupport.addItem(itemDonate)
        menuSupport.addItem(itemCommunity)
//        menuSupport.addItem(.separator())
//        menuSupport.addItem(itemGitHubSponsors)
//        menuSupport.addItem(itemTranslate)
        if ProductManager.shared.isEligibleForFeedback() {
            let itemReview = NSMenuItem(title: L10n.Organizer.Cells.WriteReview.caption.asContinuation, action: #selector(writeReview), keyEquivalent: "")
            itemReview.target = self
            menuSupport.addItem(itemReview)
        }
        menuSupport.addItem(.separator())
        menuSupport.addItem(itemFAQ)
        if ProductManager.shared.isEligibleForFeedback() {
            let itemReport = NSMenuItem(title: L10n.Service.Cells.ReportIssue.caption.asContinuation, action: #selector(reportConnectivityIssue), keyEquivalent: "")
            itemReport.target = self
            menuSupport.addItem(itemReport)
        }
        let itemSupport = NSMenuItem(title: L10n.Menu.Support.title, action: nil, keyEquivalent: "")
        menu.setSubmenu(menuSupport, for: itemSupport)
        menu.addItem(itemSupport)
        
        // share

        let menuShare = NSMenu()
        let itemTweet = NSMenuItem(title: L10n.About.Cells.ShareTwitter.caption, action: #selector(shareTwitter), keyEquivalent: "")
        let itemInvite = NSMenuItem(title: L10n.About.Cells.ShareGeneric.caption.asContinuation, action: #selector(shareGeneric), keyEquivalent: "")
        let itemAlternativeTo = NSMenuItem(title: "AlternativeTo".asContinuation, action: #selector(visitAlternativeTo), keyEquivalent: "")
        itemTweet.target = self
        itemInvite.target = self
        itemAlternativeTo.target = self
        menuShare.addItem(itemTweet)
        menuShare.addItem(itemInvite)
        menuShare.addItem(itemAlternativeTo)
        let itemShare = NSMenuItem(title: L10n.About.Sections.Share.header, action: nil, keyEquivalent: "")
        menu.setSubmenu(menuShare, for: itemShare)
        menu.addItem(itemShare)
        menu.addItem(.separator())

        // secondary
        
        let itemAbout = NSMenuItem(title: L10n.Organizer.Cells.About.caption(GroupConstants.App.name), action: #selector(showAbout), keyEquivalent: "")
        let itemQuit = NSMenuItem(title: L10n.Menu.Quit.title(GroupConstants.App.name), action: #selector(quit), keyEquivalent: "q")
        itemAbout.target = self
        itemQuit.target = self
        menu.addItem(itemAbout)
        menu.addItem(itemQuit)
    }
    
    private func reloadProfiles() {
        for item in itemsAllProfiles {
            menuAllProfiles.removeItem(item)
        }
        itemsAllProfiles.removeAll()

        let sortedProfileKeys = service.allProfileKeys().sorted {
            service.screenTitle($0).lowercased() < service.screenTitle($1).lowercased()
        }

        for profileKey in sortedProfileKeys {
            let title = service.screenTitle(profileKey)
            let item = NSMenuItem(title: title, action: #selector(switchActiveProfile(_:)), keyEquivalent: "")
            item.representedObject = profileKey
            item.target = self
            item.state = service.isActiveProfile(profileKey) ? .on : .off
            menuAllProfiles.addItem(item)
            itemsAllProfiles.append(item)
        }
        menu.setSubmenu(menuAllProfiles, for: itemSwitchProfile)
    }
    
    func refreshWithCurrentProfile() {
        setActiveProfile(service.activeProfile)
    }

    func setActiveProfile(_ profile: ConnectionProfile?) {
        let startIndex = menu.index(of: itemProfileName)
        var i = startIndex + 1
        
        for item in itemsProfile {
            menu.removeItem(item)
        }
        itemsProfile.removeAll()

        guard let profile = profile else {
            itemProfileName.title = L10n.Menu.ActiveProfile.Title.none
//            itemProfileName.image = nil
            setStatusImage(for: .inactive)
            statusItem.button?.toolTip = nil
            return
        }
        let profileTitle = service.screenTitle(ProfileKey(profile))
        itemProfileName.title = profileTitle
//        itemProfileName.image = profile.image
        
        let needsCredentials = service.needsCredentials(for: profile)
        if !needsCredentials {
            itemToggleVPN.indentationLevel = 1
            itemReconnectVPN.indentationLevel = 1
            itemToggleVPN.target = self
            itemReconnectVPN.target = self
            menu.insertItem(itemToggleVPN, at: i)
            i += 1
            menu.insertItem(itemReconnectVPN, at: i)
            i += 1

            itemsProfile.append(itemToggleVPN)
            itemsProfile.append(itemReconnectVPN)
        } else {
            let itemMissingCredentials = NSMenuItem(title: L10n.Menu.ActiveProfile.Messages.missingCredentials, action: nil, keyEquivalent: "")
            itemMissingCredentials.indentationLevel = 1
            menu.insertItem(itemMissingCredentials, at: i)
            i += 1
            itemsProfile.append(itemMissingCredentials)
        }

        reloadVpnStatus()

        if !needsCredentials, let providerProfile = profile as? ProviderConnectionProfile {

            // endpoint (port only)
            let itemEndpoint = NSMenuItem(title: L10n.Endpoint.title, action: nil, keyEquivalent: "")
            itemEndpoint.indentationLevel = 1
            let menuEndpoint = NSMenu()
            
            // automatic
            let itemEndpointAutomatic = NSMenuItem(title: L10n.Endpoint.Cells.AnyProtocol.caption, action: #selector(connectToEndpoint(_:)), keyEquivalent: "")
            itemEndpointAutomatic.target = self
            if providerProfile.customProtocol == nil {
                itemEndpointAutomatic.state = .on
            }
            menuEndpoint.addItem(itemEndpointAutomatic)
            
            for proto in profile.protocols {
                let item = NSMenuItem(title: proto.description, action: #selector(connectToEndpoint(_:)), keyEquivalent: "")
                item.representedObject = proto
                item.target = self
                if providerProfile.customProtocol == proto {
                    item.state = .on
                }
                menuEndpoint.addItem(item)
            }
            menu.setSubmenu(menuEndpoint, for: itemEndpoint)
            menu.insertItem(itemEndpoint, at: i)
            i += 1
            itemsProfile.append(itemEndpoint)

            // account
            let itemAccount = NSMenuItem(title: L10n.Account.title.asContinuation, action: #selector(editAccountCredentials(_:)), keyEquivalent: "")
            menu.insertItem(itemAccount, at: i)
            i += 1
            itemAccount.target = self
            itemAccount.indentationLevel = 1
            itemsProfile.append(itemAccount)

            // customize
            let itemCustomize = NSMenuItem(title: L10n.Menu.ActiveProfile.Items.Customize.title, action: #selector(customizeProfile(_:)), keyEquivalent: "")
            menu.insertItem(itemCustomize, at: i)
            i += 1
            itemCustomize.target = self
            itemCustomize.indentationLevel = 1
            itemsProfile.append(itemCustomize)

            let itemSep1: NSMenuItem = .separator()
            menu.insertItem(itemSep1, at: i)
            i += 1
            itemsProfile.append(itemSep1)

//            guard poolDescription = providerProfile.pool?.localizedId else {
//                fatalError("No pool selected?")
//            }
            itemPool.title = providerProfile.pool?.localizedId ?? ""
            menu.insertItem(itemPool, at: i)
            i += 1
            itemsProfile.append(itemPool)
            
            let infrastructure = providerProfile.infrastructure
            for category in infrastructure.categories {
                let title = category.name.isEmpty ? L10n.Global.Values.default : category.name.capitalized
                let submenu = NSMenu()
                let itemCategory = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                itemCategory.indentationLevel = 1
                
                for group in category.groups.sorted() {
                    let title = group.localizedCountry

                    let itemGroup = NSMenuItem(title: title, action: #selector(connectToGroup(_:)), keyEquivalent: "")
                    itemGroup.image = group.logo
                    itemGroup.target = self
                    itemGroup.representedObject = group
                    
                    let submenuGroup = NSMenu()
                    for pool in group.pools.sortedPools() {
                        let title = !pool.secondaryId.isEmpty ? pool.secondaryId : L10n.Global.Values.default
                        let item = NSMenuItem(title: title, action: #selector(connectToPool(_:)), keyEquivalent: "")
                        if let extraCountry = pool.extraCountries?.first {
                            item.image = extraCountry.image
                        }
                        item.target = self
                        item.representedObject = pool
                        submenuGroup.addItem(item)

                        if pool.id == providerProfile.poolId {
                            itemCategory.state = .on
                            itemGroup.state = .on
                            item.state = .on
                        }
                    }
                    if submenuGroup.numberOfItems > 1 {
                        itemGroup.action = nil
                        itemGroup.submenu = submenuGroup
                    }

                    submenu.addItem(itemGroup)
                }
                menu.setSubmenu(submenu, for: itemCategory)
                menu.insertItem(itemCategory, at: i)
                i += 1
                itemsProfile.append(itemCategory)
            }
        } else {

            // account
            let itemAccount = NSMenuItem(title: L10n.Account.title.asContinuation, action: #selector(editAccountCredentials(_:)), keyEquivalent: "")
            menu.insertItem(itemAccount, at: i)
            i += 1
            itemAccount.target = self
            itemAccount.indentationLevel = 1
            itemsProfile.append(itemAccount)

            // customize
            let itemCustomize = NSMenuItem(title: L10n.Menu.ActiveProfile.Items.Customize.title, action: #selector(customizeProfile(_:)), keyEquivalent: "")
            menu.insertItem(itemCustomize, at: i)
            i += 1
            itemCustomize.target = self
            itemCustomize.indentationLevel = 1
            itemsProfile.append(itemCustomize)

            let itemSep1: NSMenuItem = .separator()
            menu.insertItem(itemSep1, at: i)
            i += 1
            itemsProfile.append(itemSep1)
        }
    }
    
    // MARK: Actions

    @objc private func showAbout() {
        WindowManager.shared.showAbout()
    }

    @objc private func showOrganizer() {
        WindowManager.shared.showOrganizer()
    }
    
    @objc private func showPreferences() {
        WindowManager.shared.showPreferences()
    }

    @objc private func switchActiveProfile(_ sender: Any?) {
        guard let item = sender as? NSMenuItem else {
            return
        }
        guard let profileKey = item.representedObject as? ProfileKey, let profile = service.profile(withKey: profileKey) else {
            return
        }
        
        let wasConnected = (vpn.status == .connected) || (vpn.status == .connecting)

        // XXX: copy/paste from ServiceViewController.activateProfile()
        service.activateProfile(profile)
        vpn.disconnect(completionHandler: nil)
        if wasConnected {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
                self?.vpn.reconnect(completionHandler: nil)
            }
        }
    }

    @objc private func enableVPN() {
        vpn.reconnect { _ in
            self.reloadVpnStatus()
        }
    }

    @objc private func disableVPN() {
        vpn.disconnect { _ in
            self.reloadVpnStatus()
        }
    }
    
    @objc private func reconnectVPN() {
        vpn.reconnect(completionHandler: nil)
    }
    
    @objc private func connectToGroup(_ sender: Any?) {
        guard let item = sender as? NSMenuItem else {
            return
        }
        guard let group = item.representedObject as? PoolGroup else {
            return
        }
        guard let profile = service.activeProfile as? ProviderConnectionProfile else {
            return
        }
        assert(!group.pools.isEmpty)
        profile.poolId = group.pools.randomElement()!.id
        vpn.reconnect(completionHandler: nil)
        
        // update menu
        setActiveProfile(profile)
    }
    
    @objc private func connectToPool(_ sender: Any?) {
        guard let item = sender as? NSMenuItem else {
            return
        }
        guard let pool = item.representedObject as? Pool else {
            return
        }
        guard let profile = service.activeProfile as? ProviderConnectionProfile else {
            return
        }
        profile.poolId = pool.id
        vpn.reconnect(completionHandler: nil)
        
        // update menu
        setActiveProfile(profile)
    }

    @objc private func connectToEndpoint(_ sender: Any?) {
        guard let item = sender as? NSMenuItem else {
            return
        }
        guard let profile = service.activeProfile as? ProviderConnectionProfile else {
            return
        }
        profile.customProtocol = item.representedObject as? EndpointProtocol
        vpn.reconnect(completionHandler: nil)

        // update menu
        setActiveProfile(profile)
    }
    
    @objc private func editAccountCredentials(_ sender: Any?) {
        let organizer = WindowManager.shared.showOrganizer()
        guard organizer?.contentViewController?.presentedViewControllers?.isEmpty ?? true else {
            return
        }
        let accountController = StoryboardScene.Service.accountViewController.instantiate()
        accountController.profile = service.activeProfile
        organizer?.contentViewController?.presentAsSheet(accountController)
    }

    @objc private func customizeProfile(_ sender: Any?) {
        let organizer = WindowManager.shared.showOrganizer()
        guard organizer?.contentViewController?.presentedViewControllers?.isEmpty ?? true else {
            return
        }
        let profileCustomization = StoryboardScene.Service.profileCustomizationContainerViewController.instantiate()
        profileCustomization.profile = service.activeProfile
        organizer?.contentViewController?.presentAsSheet(profileCustomization)
    }

    @objc private func joinCommunity() {
        NSWorkspace.shared.open(AppConstants.URLs.subreddit)
    }

    @objc private func writeReview() {
        let url = Reviewer.urlForReview(withAppId: AppConstants.App.appStoreId)
        NSWorkspace.shared.open(url)
    }
    
    @objc private func showDonations() {
        NSWorkspace.shared.open(AppConstants.URLs.donate)
    }

    @objc private func seeGitHubSponsors() {
        NSWorkspace.shared.open(AppConstants.URLs.githubSponsors)
    }

    @objc private func offerToTranslate() {
        let V = AppConstants.Translations.Email.self
        let recipient = V.recipient
        let subject = V.subject
        let body = V.body(V.template)

        guard let url = URL.mailto(to: recipient, subject: subject, body: body) else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    @objc private func visitFAQ() {
        NSWorkspace.shared.open(AppConstants.URLs.faq)
    }
    
    @objc private func reportConnectivityIssue() {
        let issue = Issue(debugLog: true, profile: TransientStore.shared.service.activeProfile)
        IssueReporter.shared.present(withIssue: issue)
    }
    
    @objc private func shareTwitter() {
        NSWorkspace.shared.open(AppConstants.URLs.twitterIntent(withMessage: L10n.Share.message))
    }
    
    @objc private func shareGeneric() {
        guard let source = statusItem.button else {
            return
        }
        let message = "\(L10n.Share.message) \(AppConstants.URLs.website)"
        let picker = NSSharingServicePicker(items: [message])
        picker.show(relativeTo: source.bounds, of: source, preferredEdge: .minY)
    }
    
    @objc private func visitAlternativeTo() {
        NSWorkspace.shared.open(AppConstants.URLs.alternativeTo)
    }
    
    @objc private func quit() {
        NSApp.terminate(self)
    }

    // MARK: Notifications
    
    @objc private func vpnDidUpdate() {
        reloadVpnStatus()
    }
    
    // MARK: Helpers
    
    private func addDonations(fromProducts products: [SKProduct], to menu: NSMenu) {
        products.sorted { $0.price.decimalValue < $1.price.decimalValue }.forEach {
            guard let p = LocalProduct(rawValue: $0.productIdentifier), p.isDonation, let price = $0.localizedPrice else {
                return
            }
            let title = "\($0.localizedTitle) (\(price))"
            let item = NSMenuItem(title: title, action: #selector(performDonation(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = $0
            menu.addItem(item)
        }
    }
    
    @objc private func performDonation(_ item: NSMenuItem) {
        guard let product = item.representedObject as? SKProduct else {
            return
        }
        ProductManager.shared.purchase(product) { _, _ in
        }
    }
    
    private func reloadVpnStatus() {
        if vpn.isEnabled {
            itemToggleVPN.title = L10n.Service.Cells.Vpn.TurnOff.caption
            itemToggleVPN.action = #selector(disableVPN)
        } else {
            itemToggleVPN.title = L10n.Service.Cells.Vpn.TurnOn.caption
            itemToggleVPN.action = #selector(enableVPN)
        }
        if let profile = service.activeProfile {
            let profileTitle = service.screenTitle(ProfileKey(profile))
            statusItem.button?.toolTip = "\(GroupConstants.App.name)\n\(profileTitle)\n\((vpn.status ?? .disconnected).uiDescription)"
        } else {
            statusItem.button?.toolTip = nil
        }

        switch vpn.status ?? .disconnected {
        case .connected:
            setStatusImage(for: .active)
            
            Reviewer.shared.reportEvent()

        case .connecting:
            setStatusImage(for: .pending)

        case .disconnected:
            setStatusImage(for: .inactive)

        case .disconnecting:
            setStatusImage(for: .pending)
        }
    }
}

extension StatusMenu: ConnectionServiceDelegate {
    func connectionService(didAdd profile: ConnectionProfile) {
        TransientStore.shared.serialize(withProfiles: false) // add
        reloadProfiles()

        NotificationCenter.default.post(name: StatusMenu.didAddProfile, object: profile)
    }
    
    func connectionService(didRename profile: ConnectionProfile, to newTitle: String) {
        TransientStore.shared.serialize(withProfiles: false) // rename
        reloadProfiles()

        NotificationCenter.default.post(name: StatusMenu.didRenameProfile, object: profile)
    }
    
    func connectionService(didRemoveProfileWithKey key: ProfileKey) {
        TransientStore.shared.serialize(withProfiles: false) // delete
        reloadProfiles()

        NotificationCenter.default.post(name: StatusMenu.didRemoveProfile, object: key)
    }
    
    func connectionService(willDeactivate profile: ConnectionProfile) {
        TransientStore.shared.serialize(withProfiles: false) // deactivate
        reloadProfiles()
        setActiveProfile(nil)

        NotificationCenter.default.post(name: StatusMenu.willDeactivateProfile, object: profile)
    }
    
    func connectionService(didActivate profile: ConnectionProfile) {
        TransientStore.shared.serialize(withProfiles: false) // activate
        reloadProfiles()
        setActiveProfile(profile)

        NotificationCenter.default.post(name: StatusMenu.didActivateProfile, object: profile)
    }
    
    func connectionService(didUpdate profile: ConnectionProfile) {
        guard let providerProfile = profile as? ProviderConnectionProfile else {
            return
        }
        itemPool.title = providerProfile.pool?.localizedId ?? ""
        
        NotificationCenter.default.post(name: StatusMenu.didUpdateProfile, object: profile)
    }
}

extension StatusMenu {
    fileprivate enum ImageStatus {
        case active
        
        case pending
        
        case inactive
    }

    fileprivate func setStatusImage(for imageStatus: ImageStatus) {
        switch imageStatus {
        case .active:
            statusItem.button?.image = imageStatusActive
            statusItem.button?.alphaValue = 1.0

        case .pending:
            statusItem.button?.image = imageStatusPending
            statusItem.button?.alphaValue = 1.0

        case .inactive:
            statusItem.button?.image = imageStatusActive
            statusItem.button?.alphaValue = 0.5
        }
    }
}
