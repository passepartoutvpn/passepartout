// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation

@MainActor
public final class RegistryCoder: ObservableObject, Sendable {
    private let registry: Registry

    private let coder: ProfileCoder

    public init(registry: Registry, coder: ProfileCoder) {
        self.registry = registry
        self.coder = coder
    }

    public nonisolated func string(from profile: Profile) throws -> String {
        try registry.encodedProfile(profile, with: coder)
    }

    public nonisolated func profile(from string: String) throws -> Profile {
        try registry.decodedProfile(from: string, with: coder)
    }

    public nonisolated func module(from string: String, object: Any?) throws -> Module {
        try registry.module(fromContents: string, object: object)
    }
}

@MainActor
extension Registry {
    public func with(coder: ProfileCoder) -> RegistryCoder {
        RegistryCoder(registry: self, coder: coder)
    }
}
