//
//  AboutViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/28/18.
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

class AboutViewController: UITableViewController, TableModelHost {

    // MARK: TableModelHost
    
    let model: TableModel<SectionType, RowType> = {
        let model: TableModel<SectionType, RowType> = TableModel()
        model.add(.info)
        model.add(.github)
        model.add(.web)
        model.add(.share)
        model.setHeader("", for: .info)
        model.setHeader("GitHub", for: .github)
        model.setHeader(L10n.About.Sections.Web.header, for: .web)
        model.setHeader(L10n.About.Sections.Share.header, for: .share)
        model.set([.version, .credits], in: .info)
        model.set([.readme, .changelog], in: .github)
        model.set([.website, .faq, .disclaimer, .privacyPolicy], in: .web)
        model.set([.shareTwitter, .shareGeneric], in: .share)
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

        title = L10n.About.title
    }
    
    // MARK: Actions

    private func showVersion() {
        perform(segue: StoryboardSegue.About.versionSegueIdentifier)
    }
    
    private func openCredits() {
        perform(segue: StoryboardSegue.About.creditsSegueIdentifier)
    }
    
    private func visit(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func inviteFriend(sender: UITableViewCell?) {
        let message = "\(L10n.Share.message) \(AppConstants.URLs.website)"
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = sender
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction private func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: -

extension AboutViewController {
    enum SectionType: Int {
        case info
        
        case github
        
        case web

        case share
    }
    
    enum RowType: Int {
        case version
        
        case credits
        
        case readme
        
        case changelog
        
        case website
        
        case faq
        
        case disclaimer
        
        case privacyPolicy
        
        case shareTwitter
        
        case shareGeneric
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return model.headerHeight(for: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return model.footerHeight(for: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count(for: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        switch model.row(at: indexPath) {
        case .version:
            cell.leftText = L10n.Version.title
            cell.rightText = Utils.versionString()
            
        case .credits:
            cell.leftText = L10n.About.Cells.Credits.caption

        case .readme:
            cell.leftText = "README"
            
        case .changelog:
            cell.leftText = "CHANGELOG"
            
        case .website:
            cell.leftText = L10n.About.Cells.Website.caption
            
        case .faq:
            cell.leftText = L10n.About.Cells.Faq.caption

        case .disclaimer:
            cell.leftText = L10n.About.Cells.Disclaimer.caption
            
        case .privacyPolicy:
            cell.leftText = L10n.About.Cells.PrivacyPolicy.caption
            
        case .shareTwitter:
            cell.leftText = L10n.About.Cells.ShareTwitter.caption
            
        case .shareGeneric:
            cell.leftText = L10n.About.Cells.ShareGeneric.caption
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch model.row(at: indexPath) {
        case .version:
            showVersion()
            
        case .credits:
            openCredits()
            
        case .readme:
            visit(AppConstants.URLs.readme)
            
        case .changelog:
            visit(AppConstants.URLs.changelog)
            
        case .website:
            visit(AppConstants.URLs.website)
            
        case .faq:
            visit(AppConstants.URLs.faq)

        case .disclaimer:
            visit(AppConstants.URLs.disclaimer)

        case .privacyPolicy:
            visit(AppConstants.URLs.privacyPolicy)

        case .shareTwitter:
            visit(AppConstants.URLs.twitterIntent)

        case .shareGeneric:
            inviteFriend(sender: tableView.cellForRow(at: indexPath))
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
