//
//  OrganizerView+Scene.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/2/22.
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

extension OrganizerView {
    struct ShortcutsSection: View {
        @ObservedObject private var productManager: ProductManager
        
        private var isEligibleForSiri: Bool {
            productManager.isEligible(forFeature: .siriShortcuts)
        }
        
        @Binding private var modalType: ModalType?
        
        init(modalType: Binding<ModalType?>) {
            productManager = .shared
            _modalType = modalType
        }
        
        var body: some View {
            Section(
                header: Text(Unlocalized.Other.siri),
                footer: Text(L10n.Organizer.Sections.Siri.footer)
            ) {
                // eligibility: enter Siri shortcuts or present paywall
                if isEligibleForSiri {
                    NavigationLink {
                        ShortcutsView()
                    } label: {
                        shortcutsRow
                    }
                } else {
                    Button {
                        modalType = .presentPaywallShortcuts
                    } label: {
                        shortcutsRow
                    }
                }
            }
        }

        private var shortcutsRow: some View {
//            Text(L10n.Organizer.Items.SiriShortcuts.caption)
            Label(L10n.Organizer.Items.SiriShortcuts.caption, systemImage: themeShortcutsImage)
        }
    }
}
