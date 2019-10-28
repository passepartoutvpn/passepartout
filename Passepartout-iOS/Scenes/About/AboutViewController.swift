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
import PassepartoutCore
import Convenience

class AboutViewController: UITableViewController, StrongTableHost {

    // MARK: StrongTableHost
    
    let model: StrongTableModel<SectionType, RowType> = {
        let model: StrongTableModel<SectionType, RowType> = StrongTableModel()
        model.add(.info)
        model.add(.github)
        model.add(.web)
        model.add(.share)
        model.setHeader("", forSection: .info)
        model.setHeader("GitHub", forSection: .github)
        model.setHeader(L10n.Core.About.Sections.Web.header, forSection: .web)
        model.setHeader(L10n.Core.About.Sections.Share.header, forSection: .share)
        model.set([.version, .credits], forSection: .info)
        model.set([.readme, .changelog], forSection: .github)
        model.set([.website, .faq, .disclaimer, .privacyPolicy], forSection: .web)
        model.set([.shareTwitter, .shareGeneric], forSection: .share)
        return model
    }()
    
    func reloadModel() {
    }

    // MARK: UIViewController

    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyDetailTitle(.current)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Core.About.title
    }
    
    // MARK: Actions

    private func showVersion() {
        let vc = VersionViewController()
        vc.appIcon = Asset.Assets.logo.image
        vc.extraText = L10n.Core.Version.Labels.intro
        vc.backgroundColor = Theme.current.palette.primaryBackground
        vc.textColor = Theme.current.palette.primaryLightText
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openCredits() {
        perform(segue: StoryboardSegue.About.creditsSegueIdentifier)
    }
    
    private func visit(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func inviteFriend(sender: UITableViewCell?) {
        let message = "\(L10n.Core.Share.message) \(AppConstants.URLs.website)"
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
        return model.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.footer(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return model.headerHeight(for: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return model.footerHeight(for: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        switch model.row(at: indexPath) {
        case .version:
            cell.leftText = L10n.Core.Version.title
            cell.rightText = ApplicationInfo.appVersion
            
        case .credits:
            cell.leftText = L10n.Core.About.Cells.Credits.caption

        case .readme:
            cell.leftText = "README"
            
        case .changelog:
            cell.leftText = "CHANGELOG"
            
        case .website:
            cell.leftText = L10n.Core.About.Cells.Website.caption
            
        case .faq:
            cell.leftText = L10n.Core.About.Cells.Faq.caption

        case .disclaimer:
            cell.leftText = L10n.Core.About.Cells.Disclaimer.caption
            
        case .privacyPolicy:
            cell.leftText = L10n.Core.About.Cells.PrivacyPolicy.caption
            
        case .shareTwitter:
            cell.leftText = L10n.Core.About.Cells.ShareTwitter.caption
            
        case .shareGeneric:
            cell.leftText = L10n.Core.About.Cells.ShareGeneric.caption
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
            visit(AppConstants.URLs.iOS.readme)
            
        case .changelog:
            visit(AppConstants.URLs.iOS.changelog)
            
        case .website:
            visit(AppConstants.URLs.website)
            
        case .faq:
            visit(AppConstants.URLs.faq)

        case .disclaimer:
            visit(AppConstants.URLs.disclaimer)

        case .privacyPolicy:
            visit(AppConstants.URLs.privacyPolicy)

        case .shareTwitter:
            visit(AppConstants.URLs.twitterIntent(withMessage: L10n.Core.Share.message))

        case .shareGeneric:
            inviteFriend(sender: tableView.cellForRow(at: indexPath))
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
