//
//  LinksView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/27/24.
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

import CommonLibrary
import SwiftUI

struct LinksView: View {
    var body: some View {
        Form {
            supportSection
            webSection
        }
        .navigationTitle(Strings.Views.About.Links.title)
        .themeForm()
    }
}

private extension LinksView {
    var constants: Constants {
        .shared
    }

    var supportSection: some View {
        Section {
            Link(Strings.Views.About.Links.Rows.joinCommunity, destination: constants.websites.subreddit)
            Link(Strings.Views.About.Links.Rows.writeReview, destination: constants.urlForReview)
        } header: {
            Text(Strings.Views.About.Links.Sections.support)
        }
    }

    var webSection: some View {
        Section {
            Link(Strings.Views.About.Links.Rows.homePage, destination: constants.websites.home)
            Link(Strings.Unlocalized.faq, destination: constants.websites.faq)
            Link(Strings.Views.About.Links.Rows.disclaimer, destination: constants.websites.disclaimer)
            Link(Strings.Views.About.Links.Rows.privacyPolicy, destination: constants.websites.privacyPolicy)
        } header: {
            Text(Strings.Views.About.Links.Sections.web)
        }
    }
}

#Preview {
    LinksView()
}
