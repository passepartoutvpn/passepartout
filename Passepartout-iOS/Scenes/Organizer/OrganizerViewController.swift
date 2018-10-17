//
//  OrganizerViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/2/18.
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

// XXX: convoluted due to the separation of provider/host profiles

class OrganizerViewController: UITableViewController, TableModelHost {
    private let service = TransientStore.shared.service
    
    private var providerProfiles: [ProviderConnectionProfile] = []

    private var hostProfiles: [HostConnectionProfile] = []
    
    private var availableProviderNames: [Infrastructure.Name]?
    
    // MARK: TableModelHost

    let model: TableModel<SectionType, RowType> = {
        let model: TableModel<SectionType, RowType> = TableModel()
        model.add(.providers)
        model.add(.hosts)
        model.add(.about)
        model.add(.destruction)
        model.setHeader(L10n.Organizer.Sections.Providers.header, for: .providers)
        model.setHeader(L10n.Organizer.Sections.Hosts.header, for: .hosts)
        model.setFooter(L10n.Organizer.Sections.Providers.footer, for: .providers)
        model.setFooter(L10n.Organizer.Sections.Hosts.footer, for: .hosts)
        model.set([.openAbout], in: .about)
        model.set([.uninstall], in: .destruction)
        return model
    }()
    
    func reloadModel() {
        providerProfiles.removeAll()
        hostProfiles.removeAll()
        
        service.profileIds().forEach {
            let profile = service.profile(withId: $0)
            if let p = profile as? ProviderConnectionProfile {
                providerProfiles.append(p)
            } else if let p = profile as? HostConnectionProfile {
                hostProfiles.append(p)
            } else {
                fatalError("Unexpected profile type \(type(of: profile))")
            }
        }
        providerProfiles.sort { $0.name.rawValue < $1.name.rawValue }
        hostProfiles.sort { $0.title < $1.title }
        
        var providers = [RowType](repeating: .profile, count: providerProfiles.count)
        var hosts = [RowType](repeating: .profile, count: hostProfiles.count)
        providers.append(.addProvider)
        hosts.append(.addHost)
        
        model.set(providers, in: .providers)
        model.set(hosts, in: .hosts)
    }
    
    // MARK: UIViewController

    override func awakeFromNib() {
        super.awakeFromNib()

        applyMasterTitle(Theme.current)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = GroupConstants.App.title
        navigationItem.rightBarButtonItem = editButtonItem
        Cells.destructive.register(with: tableView)
        reloadModel()
        
        tableView.reloadData()
        if let ip = selectedIndexPath {
            tableView.scrollToRow(at: ip, at: .middle, animated: false)
        }

        service.delegate = self
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            return model.row(at: indexPath) == .profile
        }

        // fall back to active profile if no selection
        return service.hasActiveProfile()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = (segue.destination as? UINavigationController)?.topViewController

        if let vc = destination as? ServiceViewController {
            var selectedProfile: ConnectionProfile?

            // XXX: sender can be a cell or a profile
            selectedProfile = sender as? ConnectionProfile
            if selectedProfile == nil, let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                selectedProfile = profile(at: indexPath)
            }
            assert(selectedProfile != nil, "No selected profile")

            vc.profile = selectedProfile
        } else if let vc = destination as? Wizard {
            if let providerVC = vc as? WizardProviderViewController {
                providerVC.availableNames = availableProviderNames ?? []
            }
            vc.delegate = self
        }
    }

    // MARK: Actions
    
    @IBAction private func about() {
        perform(segue: StoryboardSegue.Organizer.aboutSegueIdentifier, sender: nil)
    }
    
    private func addNewProvider() {
        var names = Set(InfrastructureFactory.shared.allNames)
        let createdNames = providerProfiles.map { $0.name }
        names.formSymmetricDifference(createdNames)

        guard !names.isEmpty else {
            let alert = Macros.alert(
                L10n.Organizer.Sections.Providers.header,
                L10n.Organizer.Alerts.ExhaustedProviders.message
            )
            alert.addCancelAction(L10n.Global.ok)
            present(alert, animated: true, completion: nil)
            return
        }

        availableProviderNames = names.sorted { $0.rawValue < $1.rawValue }
        perform(segue: StoryboardSegue.Organizer.addProviderSegueIdentifier)
    }

    private func addNewHost() {
        let alert = Macros.alert(
            L10n.Organizer.Sections.Hosts.header,
            L10n.Organizer.Alerts.AddHost.message
        )
        alert.addCancelAction(L10n.Global.ok)
        present(alert, animated: true, completion: nil)
    }

    private func removeProfile(at indexPath: IndexPath) {
        let sectionObject = model.section(for: indexPath.section)
        let rowProfile = profile(at: indexPath)
        switch sectionObject {
        case .providers:
            providerProfiles.remove(at: indexPath.row)
            
        case .hosts:
            hostProfiles.remove(at: indexPath.row)
            
        default:
            return
        }
        
//        var fallbackSection: SectionType?
        
        let total = providerProfiles.count + hostProfiles.count
        
        // removed all profiles
        if total == 0 {
            VPN.shared.disconnect(completionHandler: nil)
        }
        // removed active profile
        else if service.isActiveProfile(rowProfile) {
//            let anyProvider = providerProfiles.first
//            let anyHost = hostProfiles.first
//            guard let anyProfile: ConnectionProfile = firstProvider ?? firstHost else {
//                fatalError("There must be one profile somewhere")
//            }
//            fallbackSection = (anyProvider != nil) ? .providers : .hosts
//            store.service.activateProfile(only)
            VPN.shared.disconnect(completionHandler: nil)
        }
        
        tableView.beginUpdates()
        model.deleteRow(in: sectionObject, at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
//        if let fallbackSection = fallbackSection {
//            let section = model.index(ofSection: fallbackSection)
//            tableView.reloadRows(at: [IndexPath(row: 0, section: section)], with: .none)
//        }
        tableView.endUpdates()
        
        let _ = service.removeProfile(rowProfile)
        splitViewController?.serviceViewController?.hideProfileIfDeleted()
        TransientStore.shared.serialize() // delete
    }

    private func confirmVpnProfileDeletion() {
        let alert = Macros.alert(
            L10n.Organizer.Cells.Uninstall.caption,
            L10n.Organizer.Alerts.DeleteVpnProfile.message
        )
        alert.addDefaultAction(L10n.Global.ok) {
            VPN.shared.uninstall(completionHandler: nil)
        }
        alert.addCancelAction(L10n.Global.cancel)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: -

extension OrganizerViewController {
    enum SectionType: Int {
        case providers
        
        case hosts
        
        case about
        
        case destruction
    }
    
    enum RowType: Int {
        case profile
        
        case addProvider
        
        case addHost
        
        case openAbout
        
        case uninstall
    }
    
    private var selectedIndexPath: IndexPath? {
        guard let active = service.activeProfile?.id else {
            return nil
        }
        if let row = providerProfiles.index(where: { $0.id == active }) {
            return IndexPath(row: row, section: 0)
        }
        if let row = hostProfiles.index(where: { $0.id == active }) {
            return IndexPath(row: row, section: 1)
        }
        return nil
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(for: section)
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.footer(for: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count(for: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch model.row(at: indexPath) {
        case .profile:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            let rowProfile = profile(at: indexPath)
            cell.leftText = rowProfile.title
            cell.rightText = service.isActiveProfile(rowProfile) ? L10n.Organizer.Cells.Profile.Value.current : nil
            return cell

        case .addProvider:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.applyAction(Theme.current)
            cell.leftText = L10n.Organizer.Cells.AddProvider.caption
            return cell

        case .addHost:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.applyAction(Theme.current)
            cell.leftText = L10n.Organizer.Cells.AddHost.caption
            return cell
            
        case .openAbout:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.Organizer.Cells.About.caption(GroupConstants.App.name)
            return cell

        case .uninstall:
            let cell = Cells.destructive.dequeue(from: tableView, for: indexPath)
            cell.caption = L10n.Organizer.Cells.Uninstall.caption
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch model.row(at: indexPath) {
        case .profile:
//            selectedProfileId = profile(at: indexPath).id
            break

        case .addProvider:
            addNewProvider()

        case .addHost:
            addNewHost()
            
        case .openAbout:
            about()
            
        case .uninstall:
            confirmVpnProfileDeletion()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard tableView.isEditing else {
            return false
        }
        return model.row(at: indexPath) == .profile
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        removeProfile(at: indexPath)
    }
    
    // MARK: Helpers
    
    private func sectionProfiles(at indexPath: IndexPath) -> [ConnectionProfile] {
        let sectionProfiles: [ConnectionProfile]
        let sectionObject = model.section(for: indexPath.section)
        switch sectionObject {
        case .providers:
            sectionProfiles = providerProfiles
            
        case .hosts:
            sectionProfiles = hostProfiles
            
        default:
            fatalError("Unexpected section: \(sectionObject)")
        }
        guard indexPath.row < sectionProfiles.count else {
            fatalError("No profile found at \(indexPath), is it an add cell?")
        }
        return sectionProfiles
    }
    
    private func profile(at indexPath: IndexPath) -> ConnectionProfile {
        return sectionProfiles(at: indexPath)[indexPath.row]
    }
}

// MARK: -

extension OrganizerViewController: ConnectionServiceDelegate {
    func connectionService(didDeactivate profile: ConnectionProfile) {
        tableView.reloadData()
    }
    
    func connectionService(didActivate profile: ConnectionProfile) {
        tableView.reloadData()
    }
}

extension OrganizerViewController: WizardDelegate {
    func wizard(didCreate profile: ConnectionProfile, withCredentials credentials: Credentials) {
        service.addOrReplaceProfile(profile, credentials: credentials)
        TransientStore.shared.serialize() // add

        reloadModel()
        tableView.reloadData()

        perform(segue: StoryboardSegue.Organizer.selectProfileSegueIdentifier, sender: profile)
    }
}
