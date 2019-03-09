//
//  OrganizerViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/2/18.
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

// XXX: convoluted due to the separation of provider/host profiles

class OrganizerViewController: UITableViewController, TableModelHost {
    private let service = TransientStore.shared.service
    
    private var providers: [String] = []

    private var hosts: [String] = []
    
    private var availableProviderNames: [Infrastructure.Name]?

    private var didShowSubreddit = false

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
        if AppConstants.Flags.isBeta {
            model.add(.test)
            model.setHeader("Beta", for: .test)
            model.set([.testDisplayLog, .testTermination], in: .test)
        }
        return model
    }()
    
    func reloadModel() {
        providers = service.ids(forContext: .provider).sorted()
        hosts = service.ids(forContext: .host).sortedCaseInsensitive()
        
        var providerRows = [RowType](repeating: .profile, count: providers.count)
        var hostRows = [RowType](repeating: .profile, count: hosts.count)
        providerRows.append(.addProvider)
        hostRows.append(.addHost)
        
        model.set(providerRows, in: .providers)
        model.set(hostRows, in: .hosts)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !didShowSubreddit && !TransientStore.shared.didHandleSubreddit {
            didShowSubreddit = true
            
            let alert = Macros.alert(L10n.Reddit.title, L10n.Reddit.message)
            alert.addDefaultAction(L10n.Reddit.Buttons.subscribe) {
                TransientStore.shared.didHandleSubreddit = true
                self.subscribeSubreddit()
            }
            alert.addAction(L10n.Reddit.Buttons.never) {
                TransientStore.shared.didHandleSubreddit = true
            }
            alert.addCancelAction(L10n.Reddit.Buttons.remind)
            present(alert, animated: true, completion: nil)
        }
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

            vc.setProfile(selectedProfile)
        } else if let providerVC = destination as? WizardProviderViewController {
            providerVC.availableNames = availableProviderNames ?? []
        }
    }

    // MARK: Actions
    
    @IBAction private func about() {
        perform(segue: StoryboardSegue.Organizer.aboutSegueIdentifier, sender: nil)
    }
    
    private func addNewProvider() {
        var names = Set(InfrastructureFactory.shared.allNames)
        var createdNames: [Infrastructure.Name] = []
        providers.forEach {
            guard let name = Infrastructure.Name(rawValue: $0) else {
                return
            }
            createdNames.append(name)
        }
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

        availableProviderNames = names.sorted()
        perform(segue: StoryboardSegue.Organizer.addProviderSegueIdentifier)
    }

    private func addNewHost() {
        perform(segue: StoryboardSegue.Organizer.showImportedHostsSegueIdentifier)
    }

    private func removeProfile(at indexPath: IndexPath) {
        let sectionObject = model.section(for: indexPath.section)
        let rowProfile = profileKey(at: indexPath)
        switch sectionObject {
        case .providers:
            providers.remove(at: indexPath.row)
            
        case .hosts:
            hosts.remove(at: indexPath.row)
            
        default:
            return
        }
        
//        var fallbackSection: SectionType?
        
        let total = providers.count + hosts.count
        
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
        
        service.removeProfile(rowProfile)
        if #available(iOS 12, *) {
            InteractionsHandler.forgetProfile(withKey: rowProfile)
        }
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
    
    private func subscribeSubreddit() {
        UIApplication.shared.open(AppConstants.URLs.subreddit, options: [:], completionHandler: nil)
    }
    
    //
    
    private func testDisplayLog() {
        guard let log = try? String(contentsOf: AppConstants.Log.fileURL) else {
            return
        }
        let alert = Macros.alert("Debug log", log)
        alert.addCancelAction(L10n.Global.ok)
        present(alert, animated: true, completion: nil)
    }
    
    private func testTermination() {
        exit(0)
    }
}

// MARK: -

extension OrganizerViewController {
    enum SectionType: Int {
        case providers
        
        case hosts
        
        case about
        
        case destruction

        case test
    }
    
    enum RowType: Int {
        case profile
        
        case addProvider
        
        case addHost
        
        case openAbout
        
        case uninstall
        
        case testDisplayLog

        case testTermination
    }
    
    private var selectedIndexPath: IndexPath? {
        guard let active = service.activeProfileKey else {
            return nil
        }
        switch active.context {
        case .provider:
            if let row = providers.index(where: { $0 == active.id }) {
                return IndexPath(row: row, section: 0)
            }

        case .host:
            if let row = hosts.index(where: { $0 == active.id }) {
                return IndexPath(row: row, section: 1)
            }
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
            let rowProfile = profileKey(at: indexPath)
            cell.leftText = rowProfile.id
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
            
        case .testDisplayLog:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = "Display current log"
            return cell

        case .testTermination:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = "Terminate app"
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
            
        case .testDisplayLog:
            testDisplayLog()
            
        case .testTermination:
            testTermination()
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
    
    private func sectionProfiles(at indexPath: IndexPath) -> [String] {
        let ids: [String]
        let sectionObject = model.section(for: indexPath.section)
        switch sectionObject {
        case .providers:
            ids = providers
            
        case .hosts:
            ids = hosts
            
        default:
            fatalError("Unexpected section: \(sectionObject)")
        }
        guard indexPath.row < ids.count else {
            fatalError("No profile found at \(indexPath), is it an add cell?")
        }
        return ids
    }
    
    private func profileKey(at indexPath: IndexPath) -> ProfileKey {
        let section = model.section(for: indexPath.section)
        switch section {
        case .providers:
            return ProfileKey(.provider, providers[indexPath.row])
            
        case .hosts:
            return ProfileKey(.host, hosts[indexPath.row])
            
        default:
            fatalError("Profile found in unexpected section: \(section)")
        }
    }

    private func profile(at indexPath: IndexPath) -> ConnectionProfile {
        let id = sectionProfiles(at: indexPath)[indexPath.row]
        let section = model.section(for: indexPath.section)
        let context: Context
        switch section {
        case .providers:
            context = .provider
            
        case .hosts:
            context = .host
            
        default:
            fatalError("Profile found in unexpected section: \(section)")
        }
        guard let found = service.profile(withContext: context, id: id) else {
            fatalError("Profile (\(context), \(id)) could not be found, why was it returned?")
        }
        return found
    }
}

// MARK: -

extension OrganizerViewController: ConnectionServiceDelegate {
    func connectionService(didAdd profile: ConnectionProfile) {
        TransientStore.shared.serialize(withProfiles: false) // add
        
        reloadModel()
        tableView.reloadData()

        if #available(iOS 12, *) {
            InteractionsHandler.donateConnectVPN(with: profile)
        }

        // XXX: hack around bad replace when detail presented in compact view
        if let detailNav = navigationController?.viewControllers.last as? UINavigationController {
            var existingServiceVC: ServiceViewController?
            for vc in detailNav.viewControllers {
                if let found = vc as? ServiceViewController {
                    existingServiceVC = found
                    break
                }
            }
            let serviceVC = existingServiceVC ?? (StoryboardScene.Main.serviceIdentifier.instantiate().topViewController as! ServiceViewController)
            serviceVC.setProfile(profile)
            detailNav.setViewControllers([serviceVC], animated: true)
            return
        }
        perform(segue: StoryboardSegue.Organizer.selectProfileSegueIdentifier, sender: profile)
    }
    
    func connectionService(didRename oldProfile: ConnectionProfile, to newProfile: ConnectionProfile) {
        TransientStore.shared.serialize(withProfiles: false) // rename

        reloadModel()
        tableView.reloadData()
    }
    
    func connectionService(didRemoveProfileWithKey key: ProfileKey) {
        TransientStore.shared.serialize(withProfiles: false) // delete

        splitViewController?.serviceViewController?.hideProfileIfDeleted()
    }
    
    // XXX: deactivate + activate leads to a redundant serialization
    
    func connectionService(willDeactivate profile: ConnectionProfile) {
        TransientStore.shared.serialize(withProfiles: false) // deactivate

        tableView.reloadData()
    }
    
    func connectionService(didActivate profile: ConnectionProfile) {
        TransientStore.shared.serialize(withProfiles: false) // activate

        tableView.reloadData()

        if #available(iOS 12, *) {
            InteractionsHandler.donateConnectVPN(with: profile)
        }
    }
}
