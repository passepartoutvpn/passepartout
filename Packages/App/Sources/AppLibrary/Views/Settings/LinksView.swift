//
//  LinksView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/27/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

public struct LinksView: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    @Environment(\.distributionTarget)
    private var distributionTarget

    public init() {
    }

    public var body: some View {
        Form {
            supportSection
            webSection
            policySection
        }
        .themeForm()
    }
}

private extension LinksView {
    var constants: Constants {
        .shared
    }

    var appStoreId: String {
        BundleConfiguration.mainString(for: .appStoreId)
    }

    var supportSection: some View {
        Group {
            Link(Strings.Views.Settings.Links.Rows.joinCommunity, destination: constants.websites.subreddit)
            Link(Strings.Views.Settings.Links.Rows.openDiscussion, destination: constants.github.discussions)
            if distributionTarget.supportsIAP && iapManager.isPayingUser {
                Link(Strings.Views.Settings.Links.Rows.writeReview, destination: BundleConfiguration.urlForReview)
            }
            if !distributionTarget.supportsIAP && !iapManager.isBeta {
                WebDonationLink()
            }
        }
        .themeSection(header: Strings.Views.Settings.Links.Sections.support)
    }

    var webSection: some View {
        Group {
            Link(Strings.Views.Settings.Links.Rows.homePage, destination: constants.websites.home)
            Link(Strings.Views.Settings.Links.Rows.blog, destination: constants.websites.blog)
        }
        .themeSection(header: Strings.Views.Settings.Links.Sections.web)
    }

    var policySection: some View {
        Section {
            Link(Strings.Views.Settings.Links.Rows.disclaimer, destination: constants.websites.disclaimer)
            Link(Strings.Views.Settings.Links.Rows.privacyPolicy, destination: constants.websites.privacyPolicy)
        }
    }
}

#Preview {
    LinksView()
}
