//
//  AboutViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/28/18.
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

class AboutViewController: UITableViewController, TableModelHost {

    // MARK: TableModelHost
    
    let model: TableModel<SectionType, RowType> = {
        let model: TableModel<SectionType, RowType> = TableModel()
        model.add(.info)
        model.add(.source)
        model.add(.feedback)
        model.setHeader(L10n.About.Sections.Info.header, for: .info)
        model.setHeader(L10n.About.Sections.Source.header, for: .source)
        model.setHeader(L10n.About.Sections.Feedback.header, for: .feedback)
        model.set([.version, .credits, .disclaimer, .website], in: .info)
        model.set([.sourcePassepartout, .sourceTunnelKit], in: .source)
        model.set([.shareTwitter, .requestSupport, .writeReview], in: .feedback)
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
    
    private func showCredits() {
        perform(segue: StoryboardSegue.Organizer.creditsSegueIdentifier)
    }
    
    private func showDisclaimer() {
        perform(segue: StoryboardSegue.Organizer.disclaimerSegueIdentifier)
    }
    
    private func visitWebsite() {
        UIApplication.shared.open(AppConstants.URLs.website, options: [:], completionHandler: nil)
    }
    
    private func visitRepository(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func postSupportRequest() {
        UIApplication.shared.open(AppConstants.URLs.subreddit, options: [:], completionHandler: nil)
    }
    
    private func tweetAboutApp() {
        UIApplication.shared.open(AppConstants.URLs.twitterIntent, options: [:], completionHandler: nil)
    }
    
    private func writeReview() {
        let url = AppConstants.URLs.review(withId: GroupConstants.App.appId)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction private func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sid = segue.identifier, let segueType = StoryboardSegue.Organizer(rawValue: sid) else {
            return
        }
        guard let vc = segue.destination as? LabelViewController else {
            return
        }

        switch segueType {
        case .creditsSegueIdentifier:
            var notices = AppConstants.Notices.all
            notices.insert(L10n.Credits.Labels.thirdParties, at: 0)
            vc.text = notices.joined(separator: "\n\n")

        case .disclaimerSegueIdentifier:
            vc.text = L10n.Disclaimer.Labels.text
            
        default:
            break
        }
    }
}

// MARK: -

extension AboutViewController {
    enum SectionType: Int {
        case info
        
        case source

        case feedback
    }
    
    enum RowType: Int {
        case version
        
        case credits
        
        case disclaimer
        
        case website
        
        case sourcePassepartout
        
        case sourceTunnelKit
        
        case shareTwitter
        
        case requestSupport
        
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
            cell.leftText = L10n.About.Cells.Version.caption
            cell.rightText = Utils.versionString()
            return cell
            
        case .credits:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.Credits.title
            return cell
            
        case .disclaimer:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.Disclaimer.title
            return cell

        case .website:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.About.Cells.Website.caption
            return cell
            
        case .sourcePassepartout:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = GroupConstants.App.name
            return cell

        case .sourceTunnelKit:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = GroupConstants.App.tunnelKitName
            return cell

        case .shareTwitter:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.About.Cells.ShareTwitter.caption
            return cell
            
        case .requestSupport:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.About.Cells.RequestSupport.caption
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
            
        case .credits:
            showCredits()
            
        case .disclaimer:
            showDisclaimer()
            
        case .website:
            visitWebsite()
            
        case .sourcePassepartout:
            visitRepository(AppConstants.Repos.passepartout)

        case .sourceTunnelKit:
            visitRepository(AppConstants.Repos.tunnelKit)
            
        case .shareTwitter:
            tweetAboutApp()
            
        case .requestSupport:
            postSupportRequest()
            
        case .writeReview:
            writeReview()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
