// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary

extension Dependencies {
    func appProcessor(
        apiManager: APIManager,
        iapManager: IAPManager,
        registry: Registry
    ) -> DefaultAppProcessor {
        DefaultAppProcessor(
            apiManager: apiManager,
            iapManager: iapManager,
            registry: registry,
            title: profileTitle
        )
    }

    @Sendable
    nonisolated func profileTitle(_ profile: Profile) -> String {
        String(format: Constants.shared.tunnel.profileTitleFormat, profile.name)
    }
}
