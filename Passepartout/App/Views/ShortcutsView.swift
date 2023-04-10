//
//  ShortcutsView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/8/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
import Intents
import PassepartoutLibrary

struct ShortcutsView: View {
    enum ModalType: Identifiable {
        case edit(shortcut: Shortcut)

        case add(shortcut: INShortcut)

        // XXX: alert ids
        var id: Int {
            switch self {
            case .edit: return 1

            case .add: return 2
            }
        }
    }

    @StateObject private var intentsManager = IntentsManager()

    @Environment(\.presentationMode) private var presentationMode

    private let target: Profile

    @State private var modalType: ModalType?

    @State private var isNavigationPresented = false

    @State private var pendingShortcut: INShortcut?

    init(target: Profile) {
        self.target = target
    }

    var body: some View {
        List {
            if !intentsManager.shortcuts.isEmpty {
                shortcutsSection
            }
            addSection
        }.toolbar {
            themeCloseItem(presentationMode: presentationMode)
        }.sheet(item: $modalType, content: presentedModal)
        .themeAnimation(on: intentsManager.isReloadingShortcuts)

        // IntentsUI
        .onReceive(intentsManager.shouldDismissIntentView) { _ in
            modalType = nil
        }

        .navigationTitle(Unlocalized.Other.siri)
        .themeSecondaryView()
    }

    private var shortcutsSection: some View {
        Section {
            ForEach(relevantShortcuts, content: rowView)
        } header: {
            Text(L10n.Shortcuts.Edit.Sections.All.header)
        }
    }

    private var relevantShortcuts: [Shortcut] {
        intentsManager.shortcuts.values.filter {
            $0.isRelevant(to: target)
        }.sorted()
    }

    private var addSection: some View {
        Section {
            NavigationLink(isActive: $isNavigationPresented) {
                AddView(
                    target: target,
                    pendingShortcut: delegatingPendingShortcut
                )
            } label: {
                Text(L10n.Shortcuts.Edit.Items.AddShortcut.caption)
            }
        } footer: {
            Text(L10n.Shortcuts.Edit.Sections.Add.footer)
        }
    }

    @ViewBuilder
    private func presentedModal(_ modalType: ModalType) -> some View {
        switch modalType {
        case .edit(let shortcut):
            IntentEditView(
                shortcut: shortcut,
                delegate: intentsManager
            )

        case .add(let shortcut):
            IntentAddView(
                shortcut: shortcut,
                delegate: intentsManager
            )
        }
    }

    private func rowView(forShortcut vs: Shortcut) -> some View {
        Button {
            presentEditShortcut(vs)
        } label: {
            Label(vs.native.invocationPhrase, systemImage: themeShortcutsImage)
        }
    }

    private var delegatingPendingShortcut: Binding<INShortcut?> {
        .init {
            pendingShortcut
        } set: {
            guard let pendingShortcut = $0 else {
                return
            }
            presentAddShortcut(pendingShortcut)
        }
    }

    private func presentEditShortcut(_ shortcut: Shortcut) {
        modalType = .edit(shortcut: shortcut)
    }

    private func presentAddShortcut(_ shortcut: INShortcut) {
        isNavigationPresented = false
        modalType = .add(shortcut: shortcut)
    }
}

private extension Shortcut {
    func isRelevant(to profile: Profile) -> Bool {
        guard let intent = native.shortcut.intent else {
            return true
        }
        if let connectIntent = intent as? ConnectVPNIntent {
            return connectIntent.profileId == profile.id.uuidString
        }
        if let moveToIntent = intent as? MoveToLocationIntent {
            return moveToIntent.profileId == profile.id.uuidString
        }
        return true
    }
}
