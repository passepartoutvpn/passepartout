//
//  OrganizerView+TV.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/17/23.
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

#if os(tvOS)
import PassepartoutLibrary
import SwiftUI

struct OrganizerView: View {
    @ObservedObject private var profileManager: ProfileManager

#if targetEnvironment(simulator)
    @State private var didLoadMockProfiles = false
#endif

    init(profileManager: ProfileManager = .shared) {
        self.profileManager = profileManager
    }

    var body: some View {
        List {
            ActiveProfileView(profileManager: profileManager)
            aboutSection
        }
        .navigationTitle(Unlocalized.appName)
        .themeTV()
        .themeAnimation(on: profileManager.activeProfileId)
#if targetEnvironment(simulator)
        .task {
            await loadMockProfiles()
        }
#endif
    }
}

private extension OrganizerView {
    var aboutSection: some View {
        Section {
            Text(L10n.Version.title)
                .withTrailingText(Constants.Global.appVersionString)
        } header: {
            Text(L10n.About.title)
        }
    }
}

// MARK: Mock

#if targetEnvironment(simulator)
import TunnelKitOpenVPN
import TunnelKitWireGuard

// poor man's preview:
//
// https://developer.apple.com/forums/thread/719078

private let mockHosts: [(String, VPNProtocolType)] = [
    ("My Profile", .wireGuard),
    ("Friend's House", .openVPN),
    ("At School", .wireGuard)
]

private let mockProviders: [ProviderName] = [
    .hideme,
    .pia,
    .protonvpn
]

@MainActor
private let mockRepository: ProfileRepository = {
    let hostProfiles = mockHosts.map { name, vpnType in
        let header = Profile.Header(name: name)
        switch vpnType {
        case .openVPN:
            let ovpn = OpenVPN.ConfigurationBuilder()
            return Profile(header, configuration: ovpn.build())

        case .wireGuard:
            let wg = WireGuard.ConfigurationBuilder()
            return Profile(header, configuration: wg.build())
        }
    }

    let providerProfiles = mockProviders.map { providerName in
        let manager = ProviderManager.shared
        let metadata = manager.provider(withName: providerName)!
        let header = Profile.Header(name: metadata.fullName, providerName: providerName)
        var provider = Profile.Provider(providerName)
        let vpnType: VPNProtocolType = .openVPN // isOpenVPN ? .openVPN : .wireGuard
        var settings = Profile.Provider.Settings()
        let anyServer = manager.anyDefaultServer(providerName, vpnProtocol: vpnType)
        settings.serverId = anyServer?.id
        settings.presetId = anyServer?.presetIds.first
        settings.account = .init("hello", "world")
        provider.vpnSettings[vpnType] = settings
        return Profile(header, provider: provider)
    }

    var profiles: [Profile] = []
    profiles.append(contentsOf: hostProfiles)
    profiles.append(contentsOf: providerProfiles)

    let repo = MockProfileRepository()
    try? repo.saveProfiles(profiles.map {
        var copy = $0
        copy.connectionExpirationDate = Date().addingTimeInterval(10.0)
        return copy
    })
    return repo
}()

private extension OrganizerView {
    func loadMockProfiles() async {
        guard !didLoadMockProfiles else {
            return
        }
        do {
            let providerManager: ProviderManager = .shared
            try await providerManager.fetchProvidersIndexPublisher(priority: .bundle).async()

            for name in mockProviders {
                try? await providerManager.fetchProviderPublisher(withName: name, vpnProtocol: .openVPN, priority: .bundle).async()
            }

            profileManager.swapProfileRepository(mockRepository)
            profileManager.activateProfile(mockRepository.allProfiles().first!.value)

            didLoadMockProfiles = true
        } catch {
            ErrorHandler.shared.handle(AppError(error))
        }
    }
}

#Preview {
    NavigationStack {
        OrganizerView()
    }
}
#endif

#endif
