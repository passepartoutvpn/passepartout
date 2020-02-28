//
//  WizardHostViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/4/18.
//  Copyright (c) 2020 Davide De Rosa. All rights reserved.
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
import TunnelKit
import SwiftyBeaver
import PassepartoutCore
import Convenience

private let log = SwiftyBeaver.self

class WizardHostViewController: UITableViewController, StrongTableHost {
    @IBOutlet private weak var itemNext: UIBarButtonItem!
    
    private let existingHostIds = TransientStore.shared.service.sortedHostIds()
    
    var parsingResult: OpenVPN.ConfigurationParser.Result? {
        didSet {
            useSuggestedTitle()
        }
    }
    
    var removesConfigurationOnCancel = false

    private var createdProfile: HostConnectionProfile?
    
    private var createdTitle: String?
    
    private var replacedProfile: ConnectionProfile?

    // MARK: StrongTableHost

    lazy var model: StrongTableModel<SectionType, RowType> = {
        let model: StrongTableModel<SectionType, RowType> = StrongTableModel()
        model.add(.meta)
//        model.setFooter(L10n.Core.Global.Host.TitleInput.message, forSection: .meta)
        if !existingHostIds.isEmpty {
            model.add(.existing)
            model.setHeader(L10n.App.Wizards.Host.Sections.Existing.header, forSection: .existing)
        }
        model.set([.titleInput], forSection: .meta)
        model.set(.existingHost, count: existingHostIds.count, forSection: .existing)
        return model
    }()
    
    func reloadModel() {
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Core.Organizer.Sections.Hosts.header
        itemNext.title = L10n.Core.Global.next
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        useSuggestedTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cellTitle?.field.becomeFirstResponder()
    }
    
    // MARK: Actions
    
    private func useSuggestedTitle() {
        cellTitle?.field.text = parsingResult?.url?.normalizedFilename
    }
    
    @IBAction private func next() {
        guard let enteredTitle = cellTitle?.field.text?.trimmingCharacters(in: .whitespaces), !enteredTitle.isEmpty else {
            return
        }
        guard let result = parsingResult else {
            return
        }
        guard let hostname = result.configuration.hostname else {
            return
        }

        let profile = HostConnectionProfile(hostname: hostname)
        let builder = OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: result.configuration)
        profile.parameters = builder.build()

        let service = TransientStore.shared.service
        replacedProfile = nil
        if let existingHostId = service.existingHostId(withTitle: enteredTitle) {
            replacedProfile = service.profile(withContext: profile.context, id: existingHostId)
            let alert = UIAlertController.asAlert(title, L10n.Core.Wizards.Host.Alerts.Existing.message)
            alert.addPreferredAction(L10n.Core.Global.ok) {
                self.next(withProfile: profile, title: enteredTitle)
            }
            alert.addCancelAction(L10n.Core.Global.cancel)
            present(alert, animated: true, completion: nil)
            return
        }
        next(withProfile: profile, title: enteredTitle)
    }
    
    private func next(withProfile profile: HostConnectionProfile, title: String) {
        createdProfile = profile
        createdTitle = title

        let accountVC = StoryboardScene.Main.accountIdentifier.instantiate()
        if let replacedProfile = replacedProfile {
            accountVC.currentCredentials = TransientStore.shared.service.credentials(for: replacedProfile)
        }
        accountVC.delegate = self
        navigationController?.pushViewController(accountVC, animated: true)
    }
    
    private func finish(withCredentials credentials: Credentials) {
        guard let profile = createdProfile, let title = createdTitle else {
            fatalError("No profile created?")
        }
        let service = TransientStore.shared.service
        if let url = parsingResult?.url {
            do {
                let savedURL = try service.save(configurationURL: url, for: profile)
                log.debug("Associated .ovpn configuration file to profile '\(profile.id)': \(savedURL)")

                // can now delete imported file
                try? FileManager.default.removeItem(at: url)
            } catch let e {
                log.error("Could not associate .ovpn configuration file to profile: \(e)")
            }
        }
        dismiss(animated: true) {
            if let replacedProfile = self.replacedProfile {
                service.removeProfile(ProfileKey(replacedProfile))
            }
            service.addOrReplaceProfile(profile, credentials: credentials, title: title)
        }
    }

    @IBAction private func close() {
        if removesConfigurationOnCancel, let url = parsingResult?.url {
            try? FileManager.default.removeItem(at: url)
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: -

extension WizardHostViewController {
    enum SectionType: Int {
        case meta
        
        case existing
    }
    
    enum RowType: Int {
        case titleInput
        
        case existingHost
    }
    
    private var cellTitle: FieldTableViewCell? {
        guard let ip = model.indexPath(forRow: .titleInput, ofSection: .meta) else {
            return nil
        }
        return tableView.cellForRow(at: ip) as? FieldTableViewCell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.footer(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch model.row(at: indexPath) {
        case .titleInput:
            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cell.caption = L10n.App.Wizards.Host.Cells.TitleInput.caption
            cell.captionWidth = 100.0
//            cell.allowedCharset = .filename
            cell.field.applyProfileId(.current)
            cell.delegate = self
            return cell
            
        case .existingHost:
            let existingTitle = hostTitle(at: indexPath.row)
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = existingTitle
            cell.accessoryType = .none
            cell.isTappable = true
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch model.row(at: indexPath) {
        case .existingHost:
            guard let titleIndexPath = model.indexPath(forRow: .titleInput, ofSection: .meta) else {
                fatalError("Could not found title cell?")
            }
            let existingTitle = hostTitle(at: indexPath.row)
            let cellTitle = tableView.cellForRow(at: titleIndexPath) as? FieldTableViewCell
            cellTitle?.field.text = existingTitle
            tableView.deselectRow(at: indexPath, animated: true)
            
        default:
            break
        }
    }
    
    private func hostTitle(at row: Int) -> String {
        return TransientStore.shared.service.screenTitle(forHostId: existingHostIds[row])
    }
}

// MARK: -

extension WizardHostViewController: FieldTableViewCellDelegate {
    func fieldCellDidEdit(_: FieldTableViewCell) {
    }

    func fieldCellDidEnter(_: FieldTableViewCell) {
        next()
    }
}

extension WizardHostViewController: AccountViewControllerDelegate {
    func accountController(_: AccountViewController, didEnterCredentials credentials: Credentials) {
    }
    
    func accountControllerDidComplete(_ vc: AccountViewController) {
        finish(withCredentials: vc.credentials)
    }
}
