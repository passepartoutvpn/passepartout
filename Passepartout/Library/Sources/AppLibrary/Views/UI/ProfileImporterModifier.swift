//
//  ProfileImporterModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/3/24.
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

import PassepartoutKit
import SwiftUI
import UtilsLibrary

struct ProfileImporterModifier: ViewModifier {
    let profileManager: ProfileManager

    let registry: Registry

    @Binding
    var isPresented: Bool

    let errorHandler: ErrorHandler

    @StateObject
    private var importer = ProfileImporter()

    func body(content: Content) -> some View {
        content
            .fileImporter(
                isPresented: $isPresented,
                allowedContentTypes: [.item],
                allowsMultipleSelection: true,
                onCompletion: onCompletion
            )
            .alert(
                Strings.Views.Profiles.Toolbar.importProfile,
                isPresented: $importer.isPresentingPassphrase,
                presenting: importer.nextURL,
                actions: actions,
                message: message
            )
    }
}

private extension ProfileImporterModifier {

    @ViewBuilder
    func actions(for url: URL) -> some View {
        SecureField(
            Strings.Placeholders.secret,
            text: $importer.currentPassphrase
        )
        Button(Strings.Views.Profiles.Alerts.Import.Passphrase.ok) {
            Task {
                try await importer.reImport(
                    url: url,
                    profileManager: profileManager,
                    registry: registry
                )
            }
        }
        Button(Strings.Global.cancel, role: .cancel) {
            importer.cancelImport()
        }
    }

    func message(for url: URL) -> some View {
        Text(Strings.Views.Profiles.Alerts.Import.Passphrase.message(url.lastPathComponent))
    }

    func onCompletion(_ result: Result<[URL], Error>) {
        Task.detached {
            do {
                let urls = try result.get()
                try await importer.tryImport(
                    urls: urls,
                    profileManager: profileManager,
                    registry: registry
                )
            } catch {
                await errorHandler.handle(
                    error,
                    title: Strings.Views.Profiles.Toolbar.importProfile,
                    message: Strings.Views.Profiles.Errors.import
                )
            }
        }
    }
}
