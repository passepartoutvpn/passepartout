//
//  CreditsViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 11/26/18.
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

class CreditsViewController: UITableViewController, TableModelHost {
    private let licenses = AppConstants.License.all
    
    private let notices = AppConstants.Notice.all

    private let languages = AppConstants.Translations.authorByLanguage.keys.sorted {
        return Utils.localizedLanguage($0) < Utils.localizedLanguage($1)
    }

    // MARK: TableModelHost
    
    var model: TableModel<SectionType, RowType> = TableModel()
    
    func reloadModel() {
        model.add(.licenses)
        model.add(.notices)
        model.add(.translations)
        
        model.setHeader(L10n.Core.Credits.Sections.Licenses.header, for: .licenses)
        model.setHeader(L10n.Core.Credits.Sections.Notices.header, for: .notices)
        model.setHeader(L10n.Core.Credits.Sections.Translations.header, for: .translations)

        model.set(.license, count: licenses.count, in: .licenses)
        model.set(.notice, count: notices.count, in: .notices)
        model.set(.translation, count: languages.count, in: .translations)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Core.Credits.title
        reloadModel()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let cell = sender as? SettingTableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            return false
        }
        return model.row(at: indexPath) != .translation
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? LabelViewController else {
            return
        }
        guard let cell = sender as? SettingTableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        vc.title = cell.leftText
        switch model.row(at: indexPath) {
        case .license:
            vc.license = licenses[indexPath.row]

        case .notice:
            vc.text = notices[indexPath.row].statement
            
        default:
            break
        }
    }
}

extension CreditsViewController {
    enum SectionType: Int {
        case licenses
        
        case notices

        case translations
    }

    enum RowType: Int {
        case license
        
        case notice

        case translation
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(for: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count(for: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        switch model.row(at: indexPath) {
        case .license:
            let obj = licenses[indexPath.row]
            cell.leftText = obj.name
            cell.rightText = obj.type

        case .notice:
            let obj = notices[indexPath.row]
            cell.leftText = obj.name
            cell.rightText = nil
            
        case .translation:
            let lang = languages[indexPath.row]
            guard let author = AppConstants.Translations.authorByLanguage[lang] else {
                fatalError("Author not found for language \(lang)")
            }
            cell.leftText = Utils.localizedLanguage(lang)
            cell.rightText = author
            cell.accessoryType = .none
            cell.isTappable = false
        }
        return cell
    }
}
