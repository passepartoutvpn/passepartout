//
//  OpenVPNModule+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/17/24.
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

extension OpenVPNModule.Builder: ModuleViewProviding {
    func moduleView(with editor: ProfileEditor) -> some View {
        OpenVPNView(editor: editor, module: self)
    }
}

extension OpenVPNModule.Builder: InteractiveViewProviding {
    func interactiveView(with editor: ProfileEditor) -> some View {
        let draft = editor[self]

        return OpenVPNView.CredentialsView(
            isInteractive: draft.isInteractive,
            credentials: draft.credentials,
            isAuthenticating: true
        )
    }
}

extension OpenVPNModule: ProviderEntityViewProviding {
    func providerEntityView(
        with provider: ModuleMetadata.Provider,
        onSelect: @escaping (any ProviderEntity & Encodable) async throws -> Void
    ) -> some View {
        VPNProviderServerCoordinator<OpenVPN.Configuration>(
            providerId: provider.id,
            onSelect: onSelect
        )
    }
}
