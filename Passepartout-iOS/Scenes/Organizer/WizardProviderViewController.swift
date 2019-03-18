//
//  WizardProviderViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/4/18.
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

class WizardProviderViewController: UITableViewController {
    var availableNames: [Infrastructure.Name] = []
    
    private var createdProfile: ProviderConnectionProfile?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Organizer.Sections.Providers.header
    }
    
    private func next(withName name: Infrastructure.Name) {
        let profile = ProviderConnectionProfile(name: name)
        createdProfile = profile
        
        let accountVC = StoryboardScene.Main.accountIdentifier.instantiate()
        let infrastructure = InfrastructureFactory.shared.get(name)
        accountVC.usernamePlaceholder = infrastructure.defaults.username
        accountVC.infrastructureName = infrastructure.name
        accountVC.delegate = self
        navigationController?.pushViewController(accountVC, animated: true)
    }

    private func finish(withCredentials credentials: Credentials) {
        guard let profile = createdProfile else {
            fatalError("No profile created?")
        }
        let service = TransientStore.shared.service
        dismiss(animated: true) {
            service.addOrReplaceProfile(profile, credentials: credentials)
        }
    }

    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: -

extension WizardProviderViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = availableNames[indexPath.row]
        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        cell.leftText = name.rawValue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = availableNames[indexPath.row]
        next(withName: name)
    }
}

// MARK: -

extension WizardProviderViewController: AccountViewControllerDelegate {
    func accountController(_: AccountViewController, didEnterCredentials credentials: Credentials) {
    }
    
    func accountControllerDidComplete(_ vc: AccountViewController) {
        finish(withCredentials: vc.credentials)
    }
}
