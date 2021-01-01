//
//  ShortcutsConnectToViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 3/18/19.
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

import UIKit
import Intents
import IntentsUI
import PassepartoutCore
import Convenience

@available(iOS 12, *)
class ShortcutsConnectToViewController: UITableViewController, ProviderPoolViewControllerDelegate, StrongTableHost {
    private let service = TransientStore.shared.service

    private var providers: [Infrastructure.Name] = []
    
    private var hosts: [String] = []

    private var selectedProfile: ConnectionProfile?
    
    weak var delegate: ShortcutsIntentDelegate?
    
    // MARK: StrongTableHost
    
    let model: StrongTableModel<SectionType, RowType> = {
        let model: StrongTableModel<SectionType, RowType> = StrongTableModel()
        model.setHeader(L10n.Core.Organizer.Sections.Providers.header, forSection: .providers)
        model.setHeader(L10n.Core.Organizer.Sections.Hosts.header, forSection: .hosts)
        return model
    }()
    
    func reloadModel() {
        providers = service.sortedProviderNames()
        hosts = service.sortedHostIds()

        if !providers.isEmpty {
            model.add(.providers)
            model.set(.providerShortcut, count: providers.count, forSection: .providers)
        }
        if !hosts.isEmpty {
            model.add(.hosts)
            model.set(.hostShortcut, count: hosts.count, forSection: .hosts)
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Core.Shortcuts.Add.Cells.Connect.caption
        reloadModel()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier == StoryboardSegue.Shortcuts.pickLocationSegueIdentifier.rawValue else {
            return false
        }
        guard let _ = selectedProfile as? ProviderConnectionProfile else {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ProviderPoolViewController else {
            return
        }
        guard let provider = selectedProfile as? ProviderConnectionProfile else {
            return
        }
        vc.setInfrastructure(provider.infrastructure, currentPoolId: nil)
        vc.delegate = self
    }

    // MARK: UITableViewController
    
    enum SectionType {
        case providers

        case hosts
    }
    
    enum RowType {
        case providerShortcut

        case hostShortcut
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        switch model.row(at: indexPath) {
        case .providerShortcut:
            let name = providers[indexPath.row]
            if let metadata = InfrastructureFactory.shared.metadata(forName: name) {
                cell.leftText = metadata.description
            } else {
                cell.leftText = name
            }
            
        case .hostShortcut:
            let id = hosts[indexPath.row]
            cell.leftText = service.screenTitle(forHostId: id)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch model.row(at: indexPath) {
        case .providerShortcut:
            selectedProfile = service.profile(withContext: .provider, id: providers[indexPath.row])
            pickProviderLocation()

        case .hostShortcut:
            selectedProfile = service.profile(withContext: .host, id: hosts[indexPath.row])
            addConnect()
        }
    }

    // MARK: Actions

    private func addConnect() {
        guard let host = selectedProfile as? HostConnectionProfile else {
            fatalError("Not a HostConnectionProfile")
        }
        let title = service.screenTitle(forHostId: host.id)
        addShortcut(with: IntentDispatcher.intentConnect(profile: host, title: title))
    }
    
    private func addMoveToLocation(pool: Pool) {
        guard let provider = selectedProfile as? ProviderConnectionProfile else {
            fatalError("Not a ProviderConnectionProfile")
        }
        addShortcut(with: IntentDispatcher.intentMoveTo(profile: provider, pool: pool))
    }
    
    private func addShortcut(with intent: INIntent) {
        delegate?.shortcutsDidSelectIntent(intent: intent)
    }
    
    private func pickProviderLocation() {
        perform(segue: StoryboardSegue.Shortcuts.pickLocationSegueIdentifier)
    }
    
    // MARK: ProviderPoolViewControllerDelegate

    func providerPoolController(_: ProviderPoolViewController, didSelectPool pool: Pool) {
        addMoveToLocation(pool: pool)
    }

    func providerPoolController(_: ProviderPoolViewController, didUpdateFavoriteGroups favoriteGroupIds: [String]) {
    }
}
