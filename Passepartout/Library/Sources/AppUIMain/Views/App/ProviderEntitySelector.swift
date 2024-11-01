//
//  ProviderEntitySelector.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/22/24.
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

import AppLibrary
import PassepartoutKit
import SwiftUI

struct ProviderEntitySelector: View {

    @EnvironmentObject
    private var profileProcessor: ProfileProcessor

    @ObservedObject
    var profileManager: ProfileManager

    @ObservedObject
    var tunnel: ConnectionObserver

    let profile: Profile

    let module: Module

    let provider: ModuleMetadata.Provider

    var body: some View {
        if let viewProvider = module as? any ProviderEntityViewProviding {
            AnyView(viewProvider.providerEntityView(with: provider, onSelect: onSelect))
        } else {
            fatalError("Module got too far without being ProviderEntityViewProviding: \(module)")
        }
    }
}

private extension ProviderEntitySelector {
    func onSelect(_ entity: any ProviderEntity & Encodable) async throws {
        pp_log(.app, .info, "Select new provider entity: \(entity)")

        var builder = profile.builder()
        try builder.setProviderEntity(entity, forModuleWithId: module.id)
        let newProfile = try builder.tryBuild()
        try await profileManager.save(newProfile)

        Task {
            do {
                try await tunnel.connect(with: newProfile, processor: profileProcessor)
            } catch {
                pp_log(.app, .error, "Unable to connect with new provider entity: \(error)")
            }
        }
    }
}
