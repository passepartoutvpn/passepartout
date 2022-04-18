//
//  AboutView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/7/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
    
    private let readmeURL = Constants.URLs.readme

    private let changelogURL = Constants.URLs.iOS.changelog

    private let homeURL = Constants.URLs.website

    private let faqURL = Constants.URLs.faq

    private let disclaimerURL = Constants.URLs.disclaimer

    private let privacyURL = Constants.URLs.privacyPolicy

    var body: some View {
        List {
            infoSubview
            githubSubview
            webSubview
        }.themeSecondaryView()
        .navigationTitle(L10n.About.title)
    }
    
    private var infoSubview: some View {
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

    private var githubSubview: some View {
        Section(
            header: Text(Unlocalized.About.github)
        ) {
            Button(Unlocalized.About.readme) {
                URL.openURL(readmeURL)
            }
            Button(Unlocalized.About.changelog) {
                URL.openURL(changelogURL)
            }
        }
    }

    private var webSubview: some View {
        Section(
            header: Text(L10n.About.Sections.Web.header)
        ) {
            Button(L10n.About.Items.Website.caption) {
                URL.openURL(readmeURL)
            }
            Button(Unlocalized.About.faq) {
                URL.openURL(faqURL)
            }
            Button(L10n.About.Items.Disclaimer.caption) {
                URL.openURL(disclaimerURL)
            }
            Button(L10n.About.Items.PrivacyPolicy.caption) {
                URL.openURL(privacyURL)
            }
        }
    }
}
