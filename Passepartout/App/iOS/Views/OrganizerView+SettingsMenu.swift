//
//  OrganizerView+SettingsMenu.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/18/22.
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
import PassepartoutCore

extension OrganizerView {
    struct SettingsMenu: View {
        @ObservedObject private var productManager: ProductManager
        
        @Binding var modalType: ModalType?

        @Binding var alertType: AlertType?
        
        private let redditURL = Constants.URLs.subreddit
        
        private let alternativeToURL = Constants.URLs.alternativeTo

        private let shareMessage = L10n.Global.Messages.share

        private let appName = Unlocalized.appName

        init(modalType: Binding<ModalType?>, alertType: Binding<AlertType?>) {
            productManager = .shared
            _modalType = modalType
            _alertType = alertType
        }
        
        var body: some View {
            Menu {
                Menu(L10n.Menu.Support.title) {
                    supportMenu
                }
                // FIXME: l10n, refactor string id to "menu.share.title"
                Menu(L10n.About.Sections.Share.header) {
                    shareMenu
                }
                Divider()
                aboutButton
//                RemoveVPNSection()
//                betaSection
            } label: {
                themeSettingsMenuImage.asSystemImage
            }
        }

        private var supportMenu: some View {
            Group {
                Button {
                    modalType = .donate
                } label: {
                    Label(L10n.Organizer.Items.Donate.caption, systemImage: themeDonateImage)
                }.disabled(!productManager.canMakePayments())

                Button {
                    URL.openURL(redditURL)
                } label: {
                    Label(L10n.Organizer.Items.JoinCommunity.caption, systemImage: themeRedditImage)
                }
                Button(action: submitReview) {
                    Label(L10n.Organizer.Items.WriteReview.caption, systemImage: themeWriteReviewImage)
                }
            }
        }

        private var shareMenu: some View {
            Group {
                Button(L10n.About.Items.ShareTwitter.caption, action: shareOnTwitter)
                Button(L10n.About.Items.ShareGeneric.caption, action: shareWithFriend)
                Button(Unlocalized.About.alternativeTo, action: shareAlternativeTo)
            }
        }
        
        private var aboutButton: some View {
            Button(L10n.Organizer.Items.About.caption(appName)) {
                presentAbout()
            }
        }

        private func shareOnTwitter() {
            let url = Unlocalized.Social.twitterIntent(withMessage: shareMessage)
            URL.openURL(url)
        }

        private func shareWithFriend() {
            let shareMessage = "\(shareMessage) \(Constants.URLs.website)"
            modalType = .share([shareMessage])
        }

        private func shareAlternativeTo() {
            URL.openURL(alternativeToURL)
        }

        private func submitReview() {
            let reviewURL = Reviewer.urlForReview(withAppId: Constants.App.appStoreId)
            URL.openURL(reviewURL)
        }
        
        private func presentAbout() {
            modalType = .about
        }
    }
}
