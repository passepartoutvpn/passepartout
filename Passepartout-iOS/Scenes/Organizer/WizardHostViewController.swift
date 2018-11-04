//
//  WizardHostViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/4/18.
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
import TunnelKit
import SwiftyBeaver

private let log = SwiftyBeaver.self

class WizardHostViewController: UITableViewController, TableModelHost {
    @IBOutlet private weak var itemNext: UIBarButtonItem!
    
    private let existingHosts: [String] = {
        return TransientStore.shared.service.ids(forContext: .host).sortedCaseInsensitive()
    }()
    
    var parsedFile: ParsedFile? {
        didSet {
            useSuggestedTitle()
        }
    }
    
    var removesConfigurationOnCancel = false

    private var createdProfile: HostConnectionProfile?

    // MARK: TableModelHost

    lazy var model: TableModel<SectionType, RowType> = {
        let model: TableModel<SectionType, RowType> = TableModel()
        model.add(.meta)
        model.setFooter(L10n.Global.Host.TitleInput.message, for: .meta)
        if !existingHosts.isEmpty {
            model.add(.existing)
            model.setHeader(L10n.Wizards.Host.Sections.Existing.header, for: .existing)
        }
        model.set([.titleInput], in: .meta)
        model.set(.existingHost, count: existingHosts.count, in: .existing)
        return model
    }()
    
    func reloadModel() {
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Organizer.Sections.Hosts.header
        itemNext.title = L10n.Global.next
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
        cellTitle?.field.text = parsedFile?.url.normalizedFilename
    }
    
    @IBAction private func next() {
        guard let enteredTitle = cellTitle?.field.text?.trimmingCharacters(in: .whitespaces), !enteredTitle.isEmpty else {
            return
        }
        guard let file = parsedFile else {
            return
        }

        let profile = HostConnectionProfile(title: enteredTitle, hostname: file.hostname)
        profile.parameters = file.configuration

        let service = TransientStore.shared.service
        guard !service.containsProfile(profile) else {
            let replacedProfile = service.profile(withContext: profile.context, id: profile.id)
            let alert = Macros.alert(title, L10n.Wizards.Host.Alerts.Existing.message)
            alert.addDefaultAction(L10n.Global.ok) {
                self.next(withProfile: profile, replacedProfile: replacedProfile)
            }
            alert.addCancelAction(L10n.Global.cancel)
            present(alert, animated: true, completion: nil)
            return
        }
        next(withProfile: profile, replacedProfile: nil)
    }
    
    private func next(withProfile profile: HostConnectionProfile, replacedProfile: ConnectionProfile?) {
        createdProfile = profile

        let accountVC = StoryboardScene.Main.accountIdentifier.instantiate()
        if let replacedProfile = replacedProfile {
            accountVC.currentCredentials = TransientStore.shared.service.credentials(for: replacedProfile)
        }
        accountVC.delegate = self
        navigationController?.pushViewController(accountVC, animated: true)
    }
    
    private func finish(withCredentials credentials: Credentials) {
        guard let profile = createdProfile else {
            fatalError("No profile created?")
        }
        let service = TransientStore.shared.service
        if let url = parsedFile?.url {
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
            service.addOrReplaceProfile(profile, credentials: credentials)
        }
    }

    @IBAction private func close() {
        if removesConfigurationOnCancel, let url = parsedFile?.url {
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
        guard let ip = model.indexPath(row: .titleInput, section: .meta) else {
            return nil
        }
        return tableView.cellForRow(at: ip) as? FieldTableViewCell
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
        case .titleInput:
            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cell.caption = L10n.Wizards.Host.Cells.TitleInput.caption
            cell.captionWidth = 100.0
            cell.allowedCharset = .filename
            cell.field.applyProfileId(Theme.current)
            cell.delegate = self
            return cell
            
        case .existingHost:
            let hostTitle = existingHosts[indexPath.row]
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = hostTitle
            cell.accessoryType = .none
            cell.isTappable = true
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch model.row(at: indexPath) {
        case .existingHost:
            guard let titleIndexPath = model.indexPath(row: .titleInput, section: .meta) else {
                fatalError("Could not found title cell?")
            }
            let hostTitle = existingHosts[indexPath.row]
            let cellTitle = tableView.cellForRow(at: titleIndexPath) as? FieldTableViewCell
            cellTitle?.field.text = hostTitle
            tableView.deselectRow(at: indexPath, animated: true)
            
        default:
            break
        }
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
