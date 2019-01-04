//
//  AccountViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 6/12/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
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

protocol AccountViewControllerDelegate: class {
    func accountController(_: AccountViewController, didEnterCredentials credentials: Credentials)
    
    func accountControllerDidComplete(_: AccountViewController)
}

class AccountViewController: UIViewController, TableModelHost {
    @IBOutlet private weak var tableView: UITableView?
    
    private weak var cellUsername: FieldTableViewCell?
    
    private weak var cellPassword: FieldTableViewCell?
    
    var currentCredentials: Credentials?
    
    var usernamePlaceholder: String?
    
    var infrastructureName: Infrastructure.Name? {
        didSet {
            guard let name = infrastructureName else {
                model.removeFooter(for: .credentials)
                return
            }

            let V = L10n.Account.SuggestionFooter.self

            var guidance: String?
            switch name {
            case .pia:
                guidance = V.Infrastructure.pia
                
            case .tunnelBear:
                guidance = V.Infrastructure.tunnelbear
            }

            if guidance != nil {
                let footer: String
                if let _ = referralURL {
                    footer = "\(guidance!)\n\n\(V.referral)"
                } else {
                    footer = guidance!
                }
                model.setFooter(footer, for: .credentials)
                tableView?.reloadData()
            }
        }
    }

    var credentials: Credentials {
        let username = cellUsername?.field.text ?? ""
        let password = cellPassword?.field.text ?? ""
        return Credentials(username, password).trimmed()
    }
    
    private var referralURL: String? {
        guard let name = infrastructureName else {
            return nil
        }
        return AppConstants.URLs.referrals[name]
    }

    weak var delegate: AccountViewControllerDelegate?

    // MARK: TableModelHost
    
    let model: TableModel<SectionType, RowType> = {
        let model: TableModel<SectionType, RowType> = TableModel()
        model.add(.credentials)
        model.set([.username, .password], in: .credentials)
        return model
    }()
    
    func reloadModel() {
    }
    
    // MARK: UIViewController
    
    override func awakeFromNib() {
        super.awakeFromNib()

        applyDetailTitle(Theme.current)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Service.Cells.Account.caption
        cellUsername?.field.text = currentCredentials?.username
        cellPassword?.field.text = currentCredentials?.password
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
    
    @IBAction private func done() {
        view.endEditing(true)
        delegate?.accountControllerDidComplete(self)
    }

    @objc private func footerTapped() {
        guard let url = referralURL else {
            return
        }
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
    }
}

// MARK: -

extension AccountViewController: UITableViewDataSource, UITableViewDelegate, FieldTableViewCellDelegate {
    enum SectionType: Int {
        case credentials
    }
    
    enum RowType: Int {
        case username
        
        case password
    }
    
    private static let footerButtonTag = 1000
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.footer(for: .credentials)
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        var optButton = view.viewWithTag(AccountViewController.footerButtonTag) as? UIButton
        if optButton == nil {
            let button = UIButton()
            button.frame = view.bounds
            view.addSubview(button)
            optButton = button
        }
        optButton?.addTarget(self, action: #selector(footerTapped), for: .touchUpInside)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Cells.field.dequeue(from: tableView, for: indexPath)
        switch model.row(at: indexPath) {
        case .username:
            cellUsername = cell
            cell.caption = L10n.Account.Cells.Username.caption
            cell.field.placeholder = usernamePlaceholder ?? L10n.Account.Cells.Username.placeholder
            cell.field.clearButtonMode = .always
            cell.field.isSecureTextEntry = false
            cell.field.text = currentCredentials?.username
            cell.field.keyboardType = .emailAddress
            cell.field.returnKeyType = .next

        case .password:
            cellPassword = cell
            cell.caption = L10n.Account.Cells.Password.caption
            cell.field.placeholder = L10n.Account.Cells.Password.placeholder
            cell.field.clearButtonMode = .always
            cell.field.isSecureTextEntry = true
            cell.field.text = currentCredentials?.password
            cell.field.returnKeyType = .done
        }
        cell.captionWidth = 120.0
        cell.delegate = self
        return cell
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
