//
//  AboutView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/7/22.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

import SwiftUI

struct AboutView: View {
    private let versionString = Constants.Global.appVersionString

    private let redditURL = Constants.URLs.subreddit

    private let shareMessage = L10n.Global.Messages.share

    private let readmeURL = Constants.URLs.readme

    private let changelogURL = Constants.URLs.changelog

    private let homeURL = Constants.URLs.website

    private let faqURL = Constants.URLs.faq

    private let disclaimerURL = Constants.URLs.disclaimer

    private let privacyURL = Constants.URLs.privacyPolicy

    var body: some View {
        List {
            infoSection
            supportSection
            webSection
            githubSection
        }.navigationTitle(L10n.About.title)
        .themeSecondaryView()
    }
}

// MARK: -

private extension AboutView {
    var infoSection: some View {
        Section {
            NavigationLink {
                VersionView()
            } label: {
                Text(L10n.Version.title)
                    .withTrailingText(versionString)
            }
            NavigationLink(L10n.Credits.title) {
                CreditsView()
            }
        }
    }

    var supportSection: some View {
        Section {
            Button(L10n.About.Items.JoinCommunity.caption) {
                URL.open(redditURL)
            }
            Button(L10n.About.Items.ShareTwitter.caption, action: shareOnTwitter)
            Button(L10n.About.Items.WriteReview.caption, action: submitReview)
        } header: {
            Text(L10n.Menu.All.Support.title)
        }
    }

    var webSection: some View {
        Section {
            Button(L10n.About.Items.Website.caption) {
                URL.open(homeURL)
            }
            Button(Unlocalized.About.faq) {
                URL.open(faqURL)
            }
            Button(L10n.About.Items.Disclaimer.caption) {
                URL.open(disclaimerURL)
            }
            Button(L10n.About.Items.PrivacyPolicy.caption) {
                URL.open(privacyURL)
            }
        } header: {
            Text(L10n.About.Sections.Web.header)
        }
    }

    var githubSection: some View {
        Section {
            Button(Unlocalized.About.readme) {
                URL.open(readmeURL)
            }
            Button(Unlocalized.About.changelog) {
                URL.open(changelogURL)
            }
        } header: {
            Text(Unlocalized.About.github)
        }
    }
}

// MARK: -

private extension AboutView {
    func shareOnTwitter() {
        let url = Unlocalized.Social.twitterIntent(withMessage: shareMessage)
        URL.open(url)
    }

    func submitReview() {
        let reviewURL = Reviewer.urlForReview(withAppId: Constants.App.appStoreId)
        URL.open(reviewURL)
    }
}
