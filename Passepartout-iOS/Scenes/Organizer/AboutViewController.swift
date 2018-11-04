//
//  AboutViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/28/18.
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

class AboutViewController: UITableViewController, TableModelHost {

    // MARK: TableModelHost
    
    let model: TableModel<SectionType, RowType> = {
        let model: TableModel<SectionType, RowType> = TableModel()
        model.add(.info)
        model.add(.web)
        model.add(.share)
        model.add(.feedback)
        model.setHeader(L10n.About.Sections.Web.header, for: .web)
        model.setHeader(L10n.About.Sections.Share.header, for: .share)
        model.setHeader(L10n.About.Sections.Feedback.header, for: .feedback)
        model.set([.version], in: .info)
        model.set([.website, .disclaimer, .privacyPolicy], in: .web)
        model.set([.shareTwitter, .shareGeneric], in: .share)
        model.set([.joinCommunity, .writeReview], in: .feedback)
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
        perform(segue: StoryboardSegue.Organizer.versionSegueIdentifier)
    }
    
    private func visitWebsite() {
        UIApplication.shared.open(AppConstants.URLs.website, options: [:], completionHandler: nil)
    }
    
    private func visitDisclaimer() {
        UIApplication.shared.open(AppConstants.URLs.disclaimer, options: [:], completionHandler: nil)
    }
    
    private func visitPrivacyPolicy() {
        UIApplication.shared.open(AppConstants.URLs.privacyPolicy, options: [:], completionHandler: nil)
    }
    
    private func visitRepository(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func tweetAboutApp() {
        UIApplication.shared.open(AppConstants.URLs.twitterIntent, options: [:], completionHandler: nil)
    }
    
    private func inviteFriend(sender: UITableViewCell?) {
        let message = "\(L10n.Share.message) \(AppConstants.URLs.website)"
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = sender
        present(vc, animated: true, completion: nil)
    }
    
    private func postSupportRequest() {
        UIApplication.shared.open(AppConstants.URLs.subreddit, options: [:], completionHandler: nil)
    }
    
    private func writeReview() {
        let url = AppConstants.URLs.review(withId: GroupConstants.App.appId)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction private func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: -

extension AboutViewController {
    enum SectionType: Int {
        case info
        
        case web

        case share
        
        case feedback
    }
    
    enum RowType: Int {
        case version
        
        case website
        
        case disclaimer
        
        case privacyPolicy
        
        case shareTwitter
        
        case shareGeneric
        
        case joinCommunity
        
        case writeReview
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
        case .version:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.Version.title
            cell.rightText = Utils.versionString()
            return cell
            
        case .website:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.About.Cells.Website.caption
            return cell
            
        case .disclaimer:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.About.Cells.Disclaimer.caption
            return cell
            
        case .privacyPolicy:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.About.Cells.PrivacyPolicy.caption
            return cell
            
        case .shareTwitter:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.About.Cells.ShareTwitter.caption
            return cell
            
        case .shareGeneric:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.About.Cells.ShareGeneric.caption
            return cell
            
        case .joinCommunity:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.About.Cells.JoinCommunity.caption
            return cell
            
        case .writeReview:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.About.Cells.WriteReview.caption
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch model.row(at: indexPath) {
        case .version:
            showVersion()
            
        case .website:
            visitWebsite()
            
        case .disclaimer:
            visitDisclaimer()
            
        case .privacyPolicy:
            visitPrivacyPolicy()
            
        case .shareTwitter:
            tweetAboutApp()
            
        case .shareGeneric:
            inviteFriend(sender: tableView.cellForRow(at: indexPath))
            
        case .joinCommunity:
            postSupportRequest()
            
        case .writeReview:
            writeReview()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
