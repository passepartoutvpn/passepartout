//
//  AddProfileMenu.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/18/22.
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
import PassepartoutLibrary

struct AddProfileMenu: View {
    enum ModalType: Identifiable {
        case addProvider

        case addHost(URL, Bool)

        // XXX: alert ids
        var id: Int {
            switch self {
            case .addProvider: return 1

            case .addHost: return 2
            }
        }
    }

    @Binding private var modalType: ModalType?

    @Binding private var isHostFileImporterPresented: Bool

    init(modalType: Binding<ModalType?>, isHostFileImporterPresented: Binding<Bool>) {
        _modalType = modalType
        _isHostFileImporterPresented = isHostFileImporterPresented
    }

    var body: some View {
        Menu {
            Button {
                modalType = .addProvider
            } label: {
                Label(L10n.Global.Strings.provider, systemImage: themeProviderImage)
            }
            Button(action: presentHostFileImporter) {
                Label(L10n.Menu.Contextual.AddProfile.fromFiles, systemImage: themeHostFilesImage)
            }
//                Button {
//                    // TODO: add profile from text
//                } label: {
//                    Label(L10n.Organizer.Menus.AddProfile.fromText, systemImage: themeHostTextImage)
//                }
            if let urls = importedURLs, !urls.isEmpty {
                Divider()
                ForEach(urls, id: \.absoluteString, content: importedURLRow)
            }
        } label: {
            themeAddMenuImage.asSystemImage
        }.sheet(item: $modalType, content: presentedModal)
    }

    @ViewBuilder
    private func presentedModal(_ modalType: ModalType) -> some View {
        switch modalType {
        case .addProvider:
            NavigationView {
                AddProviderView(
                    bindings: .init(
                        isPresented: isModalPresented
                    )
                )
            }.themeGlobal()

        case .addHost(let url, let deletingURLOnSuccess):
            NavigationView {
                AddHostView.NameView(
                    url: url,
                    deletingURLOnSuccess: deletingURLOnSuccess,
                    bindings: .init(
                        isPresented: isModalPresented
                    )
                )
            }.themeGlobal()
        }
    }

    private var isModalPresented: Binding<Bool> {
        .init {
            modalType != nil
        } set: {
            if !$0 {
                modalType = nil
            }
        }
    }

    private func importedURLRow(_ url: URL) -> some View {
        Button(L10n.Menu.Contextual.AddProfile.imported(url.lastPathComponent)) {
            presentAddHost(withURL: url, deletingURLOnSuccess: true)
        }
    }

    private var importedURLs: [URL]? {
        do {
            let url = FileManager.default.userURL(for: .documentDirectory, appending: nil)
            let list = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            return list.filter {
                VPNProtocolType.knownFileExtensions.contains($0.pathExtension)
            }
        } catch {
            return nil
        }
    }
}

extension AddProfileMenu {
    private func presentAddProvider() {
        modalType = .addProvider
    }

    private func presentAddHost(withURL url: URL, deletingURLOnSuccess: Bool) {
        modalType = .addHost(url, deletingURLOnSuccess)
    }

    private func presentHostFileImporter() {

        // XXX: iOS bug, hack around crappy bug when dismissing by swiping down
        //
        // https://stackoverflow.com/questions/66965471/swiftui-fileimporter-modifier-not-updating-binding-when-dismissed-by-tapping
        isHostFileImporterPresented = false
        Task { @MainActor in
            await Task.maybeWait(forMilliseconds: Constants.Delays.xxxPresentFileImporter)
            isHostFileImporterPresented = true
        }
//        isHostFileImporterPresented = true
//
//        // use this to test hardcoded bundle file
//        let url = Bundle.main.url(forResource: "pia", withExtension: "ovpn")!
//        importedProfileName = "pia.ovpn"
//        modalType = .addHost(url, false)
    }
}
