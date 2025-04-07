//
//  WireGuardView+Import.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/7/25.
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
import CommonUtils
import Partout
import SwiftUI

extension WireGuardView {
    struct ImportModifier: ViewModifier {

        @ObservedObject
        var draft: ModuleDraft<WireGuardModule.Builder>

        let impl: WireGuardModule.Implementation?

        @Binding
        var isImporting: Bool

        @ObservedObject
        var errorHandler: ErrorHandler

        @State
        private var importURL: URL?

        func body(content: Content) -> some View {
            content
                .fileImporter(
                    isPresented: $isImporting,
                    allowedContentTypes: [.item],
                    onCompletion: importConfiguration
                )
        }
    }
}

private extension WireGuardView.ImportModifier {
    func importConfiguration(from result: Result<URL, Error>) {
        do {
            let url = try result.get()
            guard url.startAccessingSecurityScopedResource() else {
                throw AppError.permissionDenied
            }
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            importURL = url

            guard let impl else {
                fatalError("Requires WireGuardModule implementation")
            }
            let parsed: Module
            do {
                parsed = try impl.importer.module(fromURL: url, object: nil)
            } catch let error as PartoutError {
                pp_log(.app, .error, "Unable to parse URL: \(error)")

                switch error.code {
                case .unknownImportedModule:
                    throw PartoutError(.parsing)

                default:
                    throw error
                }
            }
            guard let module = parsed as? WireGuardModule else {
                throw PartoutError(.parsing)
            }
            draft.module.configurationBuilder = module.configuration?.builder()
        } catch {
            pp_log(.app, .error, "Unable to import WireGuard configuration: \(error)")
            errorHandler.handle(error, title: draft.module.moduleType.localizedDescription)
        }
    }
}
