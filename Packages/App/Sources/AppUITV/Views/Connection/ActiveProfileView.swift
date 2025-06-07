//
//  ActiveProfileView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/1/24.
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
import SwiftUI
import UIAccessibility

struct ActiveProfileView: View {

    @EnvironmentObject
    private var theme: Theme

    @EnvironmentObject
    private var apiManager: APIManager

    let profile: Profile?

    @ObservedObject
    var tunnel: ExtendedTunnel

    @Binding
    var isSwitching: Bool

    @FocusState.Binding
    var focusedField: ConnectionView.Field?

    @ObservedObject
    var errorHandler: ErrorHandler

    var flow: ConnectionFlow?

    var body: some View {
        VStack(spacing: .zero) {
            VStack {
                VStack {
                    activeProfileView
                    statusView
                }
                .padding(.bottom)

                profile.map {
                    detailView(for: $0)
                }
                .padding(.bottom)

                Group {
                    toggleConnectionButton
                    switchProfileButton
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 100)

            Spacer()
        }
    }
}

private extension ActiveProfileView {
    var activeProfileView: some View {
        Text(profile?.name ?? Strings.Views.App.InstalledProfile.None.name)
            .font(.title)
            .fontWeight(theme.relevantWeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .uiAccessibility(.App.profilesHeader)
    }

    var statusView: some View {
        ConnectionStatusText(tunnel: tunnel, profileId: profile?.id)
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .brightness(0.2)
    }

    func detailView(for profile: Profile) -> some View {
        VStack(spacing: 10) {
            if let primaryType = profile.localizedDescription(optionalStyle: .primaryType) {
                ListRowView(title: Strings.Global.Nouns.protocol) {
                    Text(primaryType)
                }
            }
            if let pair = profile.activeProviderModule {
                if let provider = apiManager.provider(withId: pair.providerId) {
                    ListRowView(title: Strings.Global.Nouns.provider) {
                        Text(provider.description)
                    }
                }
                if let entityHeader = pair.entity?.header {
                    ListRowView(title: Strings.Global.Nouns.country) {
                        ThemeCountryText(entityHeader.countryCode)
                    }
                }
            }
            if let secondaryTypes = profile.localizedDescription(optionalStyle: .secondaryTypes) {
                ListRowView(title: secondaryTypes) {
                    EmptyView()
                }
            }
        }
        .font(.title3)
    }

    var toggleConnectionButton: some View {
        ActiveTunnelButton(
            tunnel: tunnel,
            profile: profile,
            focusedField: $focusedField,
            errorHandler: errorHandler,
            flow: flow
        )
        .focused($focusedField, equals: .connect)
    }

    var switchProfileButton: some View {
        Button {
            isSwitching.toggle()
        } label: {
            Text(Strings.Global.Actions.select)
                .frame(maxWidth: .infinity)
                .forMainButton(
                    withColor: .gray,
                    focused: focusedField == .switchProfile,
                    disabled: false
                )
        }
        .focused($focusedField, equals: .switchProfile)
    }
}

// MARK: - Previews

#Preview("Host") {
    let profile: Profile = {
        do {
            var moduleBuilder = OpenVPNModule.Builder()
            moduleBuilder.configurationBuilder = .init()
            moduleBuilder.configurationBuilder?.ca = .init(pem: "")
            moduleBuilder.configurationBuilder?.remotes = [
                try .init("1.2.3.4", .init(.tcp, 1234))
            ]
            let module = try moduleBuilder.tryBuild()

            let builder = Profile.Builder(
                name: "Host",
                modules: [module],
                activatingModules: true
            )
            return try builder.tryBuild()
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    HStack {
        ContentPreview(profile: profile)
            .frame(maxWidth: .infinity)
        VStack {}
            .frame(maxWidth: .infinity)
    }
}

#Preview("Provider") {
    let profile: Profile = {
        do {
            var moduleBuilder = ProviderModule.Builder()
            moduleBuilder.providerId = .mullvad
            moduleBuilder.providerModuleType = .openVPN
            let module = try moduleBuilder.tryBuild()

            let builder = Profile.Builder(
                name: "Provider",
                modules: [module],
                activatingModules: true
            )
            return try builder.tryBuild()
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    HStack {
        ContentPreview(profile: profile)
            .frame(maxWidth: .infinity)
        VStack {}
            .frame(maxWidth: .infinity)
    }
    .task {
        try? await APIManager.forPreviews.fetchIndex()
    }
}

private struct ContentPreview: View {
    let profile: Profile

    @State
    private var isSwitching = false

    @FocusState
    private var focusedField: ConnectionView.Field?

    var body: some View {
        ActiveProfileView(
            profile: profile,
            tunnel: .forPreviews,
            isSwitching: $isSwitching,
            focusedField: $focusedField,
            errorHandler: .default()
        )
        .withMockEnvironment()
    }
}
