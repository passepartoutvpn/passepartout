//
//  OrganizerView+AddProfileMenu.swift
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
import PassepartoutCore

extension OrganizerView {
    struct AddProfileMenu: View {
        struct Bindings {
            @Binding var modalType: ModalType?

            @Binding var alertType: AlertType?

            @Binding var isHostFileImporterPresented: Bool
        }
        
        private let withImportedURLs: Bool
        
        private let bindings: Bindings

        init(
            withImportedURLs: Bool,
            bindings: Bindings
        ) {
            self.withImportedURLs = withImportedURLs
            self.bindings = bindings
        }
        
        var body: some View {
            Group {
                Button {
                    bindings.modalType = .addProvider
                } label: {
                    Label(L10n.Organizer.Items.AddProvider.caption, systemImage: themeProviderImage)
                }
                Button {
                    presentHostFileImporter()
                } label: {
                    Label(L10n.Organizer.Items.AddHost.caption, systemImage: themeHostImage)
                }
                if withImportedURLs {
                    Divider()
                    importedURLs.map { urls in
                        ForEach(urls, id: \.absoluteString, content: importedURLRow)
                    }
                }
            }
        }

        private func importedURLRow(_ url: URL) -> some View {
            Button(L10n.Organizer.Menus.AddProfile.imported(url.lastPathComponent)) {
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
}

extension OrganizerView.AddProfileMenu {
    private func presentAddProvider() {
        bindings.modalType = .addProvider
    }

    private func presentAddHost(withURL url: URL, deletingURLOnSuccess: Bool) {
        bindings.modalType = .addHost(url, deletingURLOnSuccess)
    }

    private func presentHostFileImporter() {

        // XXX: iOS bug, hack around crappy bug when dismissing by swiping down
        //
        // https://stackoverflow.com/questions/66965471/swiftui-fileimporter-modifier-not-updating-binding-when-dismissed-by-tapping
        bindings.isHostFileImporterPresented = false
        Task {
            await Task.maybeWait(forMilliseconds: Constants.Delays.xxxPresentFileImporter)
            bindings.isHostFileImporterPresented = true
        }
//        isHostFileImporterPresented = true

//        // use this to test hardcoded bundle file
//        let url = Bundle.main.url(forResource: "pia", withExtension: "ovpn")!
//        importedProfileName = "pia.ovpn"
//        modalType = .addHost(url, false)
    }
}
