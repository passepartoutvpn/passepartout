//
//  OrganizerViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/6/18.
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
import SwiftyBeaver
import PassepartoutCore

private let log = SwiftyBeaver.self

class OrganizerViewController: NSViewController {
    @IBOutlet private weak var viewProfiles: NSView!

    private lazy var tableProfiles: OrganizerProfileTableView = .get()

    @IBOutlet private weak var buttonRemoveConfiguration: NSButton!

    @IBOutlet private weak var serviceController: ServiceViewController?

    private let service = TransientStore.shared.service

    private var profiles: [ConnectionProfile] = []
    
    private var importer: HostImporter?
    
    private var profilePendingRemoval: ConnectionProfile?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewProfiles.addSubview(tableProfiles)
        tableProfiles.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableProfiles.topAnchor.constraint(equalTo: viewProfiles.topAnchor),
            tableProfiles.bottomAnchor.constraint(equalTo: viewProfiles.bottomAnchor),
            tableProfiles.leftAnchor.constraint(equalTo: viewProfiles.leftAnchor),
            tableProfiles.rightAnchor.constraint(equalTo: viewProfiles.rightAnchor),
        ])

        buttonRemoveConfiguration.title = L10n.Organizer.Cells.Uninstall.caption

        tableProfiles.selectionBlock = { [weak self] in
            self?.serviceController?.setProfile($0)
        }
        tableProfiles.deselectionBlock = { [weak self] in
            self?.serviceController?.setProfile(nil)
        }
        tableProfiles.delegate = self
        reloadProfiles()
        tableProfiles.reloadData()

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(menuDidAddProfile(_:)), name: StatusMenu.didAddProfile, object: nil)
        nc.addObserver(self, selector: #selector(menuDidRenameProfile(_:)), name: StatusMenu.didRenameProfile, object: nil)
        nc.addObserver(self, selector: #selector(menuDidRemoveProfile(_:)), name: StatusMenu.didRemoveProfile, object: nil)
        nc.addObserver(self, selector: #selector(menuDidActivateProfile(_:)), name: StatusMenu.didActivateProfile, object: nil)
    }
    
    // MARK: Actions
    
    @objc private func addProvider(_ sender: Any?) {
        guard let item = sender as? NSMenuItem, let metadata = item.representedObject as? Infrastructure.Metadata else {
            return
        }
        do {
            try ProductManager.shared.verifyEligible(forProvider: metadata)
        } catch {
            presentPurchaseScreen(forProduct: metadata.product)
            return
        }
        // make sure that infrastructure exists locally
        guard let _ = InfrastructureFactory.shared.infrastructure(forName: metadata.name) else {
            _ = InfrastructureFactory.shared.update(metadata.name, notBeforeInterval: nil) { [weak self] in
                guard let _ = $0 else {
                    self?.alertMissingInfrastructure(forMetadata: metadata, error: $1)
                    return
                }
                self?.confirmAddProvider(withMetadata: metadata)
            }
            return
        }
        confirmAddProvider(withMetadata: metadata)
    }
    
    private func alertMissingInfrastructure(forMetadata metadata: Infrastructure.Metadata, error: Error?) {
        var message = L10n.Wizards.Provider.Alerts.Unavailable.message
        if let error = error {
            log.error("Unable to download missing \(metadata.description) infrastructure (network error): \(error.localizedDescription)")
            message.append(" \(error.localizedDescription)")
        } else {
            log.error("Unable to download missing \(metadata.description) infrastructure (API error)")
        }
        
        let alert = Macros.warning(metadata.description, message)
        _ = alert.presentModally(withOK: L10n.Global.ok, cancel: nil)
    }

    private func confirmAddProvider(withMetadata metadata: Infrastructure.Metadata) {
        perform(segue: StoryboardSegue.Main.enterAccountSegueIdentifier, sender: metadata.name)
    }

    @objc private func addHost() {
        let panel = NSOpenPanel()
        
        panel.title = L10n.Organizer.Alerts.OpenHostFile.title
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.canCreateDirectories = false
        panel.allowedFileTypes = ["ovpn"]
        
        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }

        importer = HostImporter(withConfigurationURL: url)
        importer?.importHost(withPassphrase: nil)
    }
    
    @objc private func updateProvidersList() {
        InfrastructureFactory.shared.updateIndex {
            if let error = $0 {
                log.error("Unable to update providers list: \(error)")
                return
            }
            
//            ProductManager.shared.listProducts { (products, error) in
//                if let error = error {
//                    log.error("Unable to list products: \(error)")
//                    return
//                }
//            }
        }
    }
    
    private func confirmRenameProfile(_ profile: ConnectionProfile, to newTitle: String) {
        
        // rename to existing title -> confirm overwrite existing
        if let existingProfile = service.hostProfile(withTitle: newTitle) {
            let alert = Macros.warning(
                L10n.Service.Alerts.Rename.title,
                L10n.Wizards.Host.Alerts.Existing.message
            )
            alert.present(in: view.window, withOK: L10n.Global.ok, cancel: L10n.Global.cancel, handler: {
                self.doReplaceProfile(profile, to: newTitle, existingProfile: existingProfile)
            }, cancelHandler: nil)
            return
        }

        // do nothing if same title
        if newTitle != service.screenTitle(forHostId: profile.id) {
            service.renameProfile(profile, to: newTitle)
        }
    }
    
    private func doReplaceProfile(_ profile: ConnectionProfile, to newTitle: String, existingProfile: ConnectionProfile) {
        let wasActive = service.isActiveProfile(existingProfile)
        service.removeProfile(ProfileKey(existingProfile))
        service.renameProfile(profile, to: newTitle)
        if wasActive {
            service.activateProfile(profile)
        }
        serviceController?.setProfile(profile)
    }

    @IBAction private func confirmVpnProfileDeletion(_ sender: Any?) {
        let alert = Macros.warning(
            L10n.Organizer.Cells.Uninstall.caption,
            L10n.Organizer.Alerts.DeleteVpnProfile.message
        )
        alert.present(in: view.window, withOK: L10n.Global.ok, cancel: L10n.Global.cancel, handler: {
            VPN.shared.uninstall(completionHandler: nil)
        }, cancelHandler: nil)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let vc = segue.destinationController as? ServiceViewController {
            serviceController = vc
        } else if let vc = segue.destinationController as? AccountViewController {

            // add provider -> account
            if let name = sender as? InfrastructureName {
                vc.profile = ProviderConnectionProfile(name: name)
            }
            // add host -> rename -> account
            else {
                vc.profile = sender as? ConnectionProfile
            }
            vc.delegate = self
        } else if let vc = segue.destinationController as? TextInputViewController {
            guard let profile = sender as? ConnectionProfile else {
                return
            }
            
            // rename host
            vc.caption = L10n.Service.Alerts.Rename.title.asCaption
            vc.text = service.screenTitle(forHostId: profile.id)
            vc.placeholder = L10n.Global.Host.TitleInput.placeholder
            vc.object = profile
            vc.delegate = self
        }
    }
    
    // MARK: Notifications
    
    @objc private func menuDidAddProfile(_ notification: Notification) {
        reloadProfiles()
        tableProfiles.reloadData()
    }
    
    @objc private func menuDidRenameProfile(_ notification: Notification) {
        reloadProfiles()
        tableProfiles.reloadData()
    }
    
    @objc private func menuDidRemoveProfile(_ notification: Notification) {
        reloadProfiles()
        tableProfiles.selectedRow = nil
        tableProfiles.reloadData()
    }
    
    @objc private func menuDidActivateProfile(_ notification: Notification) {
        guard let profile = notification.object as? ConnectionProfile else {
            return
        }
        for (i, p) in profiles.enumerated() {
            if p.id == profile.id {
                tableProfiles.selectedRow = i
                break
            }
        }
        tableProfiles.reloadData()
    }
    
    // MARK: Helpers
    
    private func removePendingProfile() {
        guard let profile = profilePendingRemoval else {
            return
        }

        service.removeProfile(ProfileKey(profile))
        profilePendingRemoval = nil

        if profiles.isEmpty || !service.hasActiveProfile() {
            serviceController?.setProfile(nil)
            VPN.shared.uninstall(completionHandler: nil)
        }
    }
    
    private func reloadProfiles() {
        let providerIds = service.ids(forContext: .provider)
        let hostIds = service.ids(forContext: .host)
        profiles.removeAll()
        for id in providerIds {
            guard let profile = service.profile(withContext: .provider, id: id) else {
                continue
            }
            profiles.append(profile)
        }
        for id in hostIds {
            guard let profile = service.profile(withContext: .host, id: id) else {
                continue
            }
            profiles.append(profile)
        }
        profiles.sort {
            service.screenTitle(ProfileKey($0)).lowercased() < service.screenTitle(ProfileKey($1)).lowercased()
        }

        tableProfiles.rows = profiles
        for (i, p) in profiles.enumerated() {
            if service.isActiveProfile(p) {
                tableProfiles.selectedRow = i
                break
            }
        }
    }
}

extension OrganizerViewController: OrganizerProfileTableViewDelegate {
    func profileTableViewDidRequestAdd(_ profileTableView: OrganizerProfileTableView, sender: NSView) {
        guard let event = NSApp.currentEvent else {
            return
        }

        let menu = NSMenu()

        let itemProvider = NSMenuItem(title: L10n.Organizer.Menus.provider, action: nil, keyEquivalent: "")
        let menuProvider = NSMenu()
        let availableMetadata = service.availableProviders()
        if !availableMetadata.isEmpty {
            for metadata in availableMetadata {
                let item = NSMenuItem(title: metadata.description, action: #selector(addProvider(_:)), keyEquivalent: "")
//                item.image = metadata.logo
                item.representedObject = metadata
                menuProvider.addItem(item)
            }
        } else {
            let item = NSMenuItem(title: L10n.Organizer.Menus.Provider.unavailable, action: nil, keyEquivalent: "")
            item.isEnabled = false
            menuProvider.addItem(item)
        }
        menuProvider.addItem(.separator())
        let itemProviderUpdateList = NSMenuItem(title: L10n.Wizards.Provider.Cells.UpdateList.caption, action: #selector(updateProvidersList), keyEquivalent: "")
        menuProvider.addItem(itemProviderUpdateList)
        menu.setSubmenu(menuProvider, for: itemProvider)
        menu.addItem(itemProvider)

        let menuHost = NSMenuItem(title: L10n.Organizer.Menus.host.asContinuation, action: #selector(addHost), keyEquivalent: "")
        menu.addItem(menuHost)

        NSMenu.popUpContextMenu(menu, with: event, for: sender)
    }
    
    func profileTableView(_ profileTableView: OrganizerProfileTableView, didRequestRemove profile: ConnectionProfile) {
        profilePendingRemoval = profile

        let alert = Macros.warning(
            L10n.Organizer.Alerts.RemoveProfile.title,
            L10n.Organizer.Alerts.RemoveProfile.message(service.screenTitle(ProfileKey(profile)))
        )
        alert.present(in: view.window, withOK: L10n.Global.ok, cancel: L10n.Global.cancel, handler: {
            self.removePendingProfile()
        }, cancelHandler: nil)
    }
    
    func profileTableView(_ profileTableView: OrganizerProfileTableView, didRequestRename profile: HostConnectionProfile) {
        perform(segue: StoryboardSegue.Main.renameProfileSegueIdentifier, sender: profile)
    }
}

extension OrganizerViewController: AccountViewControllerDelegate {
    func accountController(_ accountController: AccountViewController, shouldUpdateCredentials credentials: Credentials, forProfile profile: ConnectionProfile) -> Bool {
        guard profile.requiresCredentials else {
            return true
        }
        return credentials.isValid
    }
    
    func accountController(_ accountController: AccountViewController, didUpdateCredentials credentials: Credentials, forProfile profile: ConnectionProfile) {

        // finish adding provider (host adding is done by HostImporter)
        if profile.context == .provider {
            service.addOrReplaceProfile(profile, credentials: credentials)
        }
    }
    
    func accountControllerDidCancel(_ accountController: AccountViewController) {
    }
}

// rename existing host profile
extension OrganizerViewController: TextInputViewControllerDelegate {
    func textInputController(_ textInputController: TextInputViewController, shouldEnterText text: String) -> Bool {
        return true//text.rangeOfCharacter(from: CharacterSet.filename.inverted) == nil
    }
    
    func textInputController(_ textInputController: TextInputViewController, didEnterText text: String) {
        guard let profile = textInputController.object as? ConnectionProfile else {
            return
        }
        confirmRenameProfile(profile, to: text)
        dismiss(textInputController)
    }
}
