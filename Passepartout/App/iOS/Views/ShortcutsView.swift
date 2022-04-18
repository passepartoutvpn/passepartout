//
//  ShortcutsView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/8/22.
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
import Intents
import PassepartoutCore

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

    @ObservedObject private var intentsManager: IntentsManager

    @State private var modalType: ModalType?
    
    @State private var isNavigationPresented = false
    
    @State private var pendingShortcut: INShortcut?
    
    init() {
        intentsManager = .shared
    }
    
    var body: some View {
        List {
            if !intentsManager.shortcuts.isEmpty {
                shortcutsSection
            }
            addSection
        }.themeSecondaryView()
        .navigationTitle(L10n.Organizer.Items.SiriShortcuts.caption)
        .sheet(item: $modalType, content: presentedModal)
        .onAppear {
            intentsManager.reloadShortcuts()
        }.onReceive(intentsManager.shouldDismissIntentView) { _ in
            modalType = nil
        }
    }
    
    private var shortcutsSection: some View {
        Section(
            header: Text(L10n.Shortcuts.Edit.Sections.All.header)
        ) {
            ForEach(intentsManager.shortcuts.values.sorted(), content: rowView)
        }
    }
    
    private var addSection: some View {
        Section(
            // FIXME: l10n, string id
            footer: Text(L10n.Organizer.Sections.Siri.footer)
        ) {
            NavigationLink(isActive: $isNavigationPresented) {
                AddView(
                    pendingShortcut: delegatingPendingShortcut
                )
            } label: {
                Text(L10n.Shortcuts.Edit.Items.AddShortcut.caption)
            }
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
    
    @available(iOS 12, macOS 12, *)
    private func presentEditShortcut(_ shortcut: Shortcut) {
        modalType = .edit(shortcut: shortcut)
    }

    @available(iOS 12, macOS 12, *)
    private func presentAddShortcut(_ shortcut: INShortcut) {
        isNavigationPresented = false
        modalType = .add(shortcut: shortcut)
    }
}
