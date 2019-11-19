//
//  AccountViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 6/12/18.
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
import PassepartoutCore
import Convenience

protocol AccountViewControllerDelegate: class {
    func accountController(_: AccountViewController, didEnterCredentials credentials: Credentials)
    
    func accountControllerDidComplete(_: AccountViewController)
}

class AccountViewController: UIViewController, StrongTableHost {
    @IBOutlet private weak var tableView: UITableView?
    
    private weak var cellUsername: FieldTableViewCell?
    
    private weak var cellPassword: FieldTableViewCell?
    
    var currentCredentials: Credentials?
    
    var usernamePlaceholder: String?
    
    var infrastructureName: Infrastructure.Name? {
        didSet {
            reloadModel()
            tableView?.reloadData()
        }
    }

    var credentials: Credentials {
        let username = cellUsername?.field.text ?? ""
        let password = cellPassword?.field.text ?? ""
        return Credentials(username, password).trimmed()
    }
    
    private var guidanceString: String? {
        guard let name = infrastructureName else {
            return nil
        }
        let V = L10n.Core.Account.Sections.Guidance.Footer.Infrastructure.self
        switch name {
        case .mullvad:
            return V.mullvad(name.rawValue)
            
        case .nordVPN:
            return V.nordvpn(name.rawValue)
            
        case .pia:
            return V.pia(name.rawValue)
            
        case .protonVPN:
            return V.protonvpn(name.rawValue)

        case .tunnelBear:
            return V.tunnelbear(name.rawValue)
            
        case .vyprVPN:
            return V.vyprvpn(name.rawValue)
            
        case .windscribe:
            return V.windscribe(name.rawValue)
        }
    }
    
    private var guidanceURL: String? {
        guard let name = infrastructureName else {
            return nil
        }
        return AppConstants.URLs.guidances[name]
    }

    private var referralURL: String? {
        guard let name = infrastructureName else {
            return nil
        }
        return AppConstants.URLs.referrals[name]
    }

    weak var delegate: AccountViewControllerDelegate?

    // MARK: StrongTableHost
    
    var model: StrongTableModel<SectionType, RowType> = StrongTableModel()
    
    func reloadModel() {
        model.clear()
        
        model.add(.credentials)
        model.setHeader(L10n.App.Account.Sections.Credentials.header, forSection: .credentials)
        model.set([.username, .password], forSection: .credentials)

        if let _ = infrastructureName {
            if let guidanceString = guidanceString {
                if let _ = guidanceURL {
                    model.add(.guidance)
                    model.setFooter(guidanceString, forSection: .guidance)
                    model.set([.openGuide], forSection: .guidance)
                } else {
                    model.setFooter(guidanceString, forSection: .credentials)
                }
                model.setHeader("", forSection: .registration)
            }
//            if let _ = referralURL {
//                model.add(.registration)
//                model.setFooter(L10n.Core.Account.Sections.Registration.footer(name.rawValue), forSection: .registration)
//                model.set([.signUp], forSection: .registration)
//            }
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Core.Account.title
        cellUsername?.field.text = currentCredentials?.username
        cellPassword?.field.text = currentCredentials?.password
        
        reloadModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cellUsername?.field.becomeFirstResponder()
    }
    
    // MARK: Actions

    private func commit() {
        let newCredentials = credentials
//        guard !credentials.isEmpty else {
//            return
//        }
        currentCredentials = newCredentials
        delegate?.accountController(self, didEnterCredentials: newCredentials)
    }
    
    private func openGuidanceURL() {
        guard let urlString = guidanceURL else {
            return
        }
        UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
    }
    
    private func openReferralURL() {
        guard let urlString = referralURL else {
            return
        }
        UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
    }
    
    @IBAction private func done() {
        view.endEditing(true)
        delegate?.accountControllerDidComplete(self)
    }
}

// MARK: -

extension AccountViewController: UITableViewDataSource, UITableViewDelegate, FieldTableViewCellDelegate {
    enum SectionType: Int {
        case credentials

        case guidance

        case registration
    }
    
    enum RowType: Int {
        case username
        
        case password
        
        case openGuide

        case signUp
    }
    
    private static let footerButtonTag = 1000
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(forSection: section)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.footer(forSection: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return model.headerHeight(for: section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(forSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch model.row(at: indexPath) {
        case .username:
            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cellUsername = cell
            cell.caption = L10n.Core.Account.Cells.Username.caption
            cell.field.placeholder = usernamePlaceholder ?? L10n.Core.Account.Cells.Username.placeholder
            cell.field.clearButtonMode = .always
            cell.field.isSecureTextEntry = false
            cell.field.text = currentCredentials?.username
            cell.field.keyboardType = .emailAddress
            cell.field.returnKeyType = .next
            cell.field.textContentType = .username
            cell.captionWidth = 120.0
            cell.delegate = self
            return cell

        case .password:
            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cellPassword = cell
            cell.caption = L10n.Core.Account.Cells.Password.caption
            cell.field.placeholder = L10n.Core.Account.Cells.Password.placeholder
            cell.field.clearButtonMode = .always
            cell.field.isSecureTextEntry = true
            cell.field.text = currentCredentials?.password
            cell.field.returnKeyType = .done
            cell.field.textContentType = .password
            cell.captionWidth = 120.0
            cell.delegate = self
            return cell
            
        case .openGuide:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.Core.Account.Cells.OpenGuide.caption
            cell.applyAction(.current)
            return cell

        case .signUp:
            guard let name = infrastructureName else {
                fatalError("Sign-up shown when not a provider profile")
            }
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.Core.Account.Cells.Signup.caption(name.rawValue)
            cell.applyAction(.current)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch model.row(at: indexPath) {
        case .openGuide:
            openGuidanceURL()
            
        case .signUp:
            openReferralURL()
            
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func fieldCellDidEdit(_: FieldTableViewCell) {
        commit()
    }
    
    func fieldCellDidEnter(_ cell: FieldTableViewCell) {
        switch cell {
        case cellUsername:
            cellPassword?.field.becomeFirstResponder()
            
        case cellPassword:
            cellPassword?.field.resignFirstResponder()
            done()
            
        default:
            break
        }
    }
}
