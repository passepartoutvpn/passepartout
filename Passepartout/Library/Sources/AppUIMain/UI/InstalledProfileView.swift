//
//  InstalledProfileView.swift
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

import AppLibrary
import PassepartoutKit
import SwiftUI
import UtilsLibrary

struct InstalledProfileView: View, Routable {

    @EnvironmentObject
    var theme: Theme

    let layout: ProfilesLayout

    let profileManager: ProfileManager

    let profile: Profile?

    let tunnel: Tunnel

    let interactiveManager: InteractiveManager

    let errorHandler: ErrorHandler

    @Binding
    var nextProfileId: Profile.ID?

    var flow: ProfileContainerView.Flow?

    var body: some View {
        debugChanges()
        return HStack(alignment: .center) {
            cardView
            Spacer()
            toggleButton
        }
        .modifier(HeaderModifier(layout: layout))
    }
}

private extension InstalledProfileView {
    var installedOpacity: CGFloat {
        profile != nil ? 1.0 : 0.0
    }

    var cardView: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            HStack(alignment: .center) {
                if profile != nil {
                    actionableNameView
                    Spacer(minLength: 10.0)
                } else {
                    nameView
                }
            }
            statusView
        }
        .modifier(CardModifier(layout: layout))
    }

    var actionableNameView: some View {
        ThemeDisclosableMenu {
            menuContent
        } label: {
            nameView
        }
    }

    var nameView: some View {
        Text(profile?.name ?? Strings.Views.Profiles.Rows.notInstalled)
            .font(.title2)
            .fontWeight(theme.relevantWeight)
            .themeTruncating(.tail)
    }

    var statusView: some View {
        HStack {
            providerSelectorButton
            ConnectionStatusView(tunnel: tunnel)
                .opacity(installedOpacity)
        }
    }

    var toggleButton: some View {
        TunnelToggleButton(
            style: .color,
            tunnel: tunnel,
            profile: profile,
            nextProfileId: $nextProfileId,
            interactiveManager: interactiveManager,
            errorHandler: errorHandler,
            onProviderEntityRequired: flow?.onEditProviderEntity,
            label: { _ in
                ThemeImage(.tunnelToggle)
                    .scaleEffect(1.5, anchor: .trailing)
            }
        )
        // TODO: #584, necessary to avoid cell selection
        .buttonStyle(.plain)
        .opacity(installedOpacity)
    }

    var menuContent: some View {
        ProfileContextMenu(
            profileManager: profileManager,
            tunnel: tunnel,
            header: (profile ?? .mock).header(),
            interactiveManager: interactiveManager,
            errorHandler: errorHandler,
            isInstalledProfile: true,
            flow: flow
        )
    }

    var providerSelectorButton: some View {
        profile?
            .firstProviderModuleWithMetadata
            .map { _, provider in
                Button {
                    flow?.onEditProviderEntity(profile!)
                } label: {
                    providerSelectorLabel(with: provider)
                }
                .buttonStyle(.plain)
            }
    }

    func providerSelectorLabel(with provider: ModuleMetadata.Provider) -> some View {
        ProviderCountryFlag(provider: provider)
    }
}

private struct ProviderCountryFlag: View {
    let provider: ModuleMetadata.Provider

    var body: some View {
        ThemeCountryFlag(
            provider.entity?.header.countryCode,
            placeholderTip: Strings.Errors.App.Passepartout.missingProviderEntity,
            countryTip: {
                $0.localizedAsRegionCode
            }
        )
    }
}

private struct HeaderModifier: ViewModifier {

    @EnvironmentObject
    private var theme: Theme

    let layout: ProfilesLayout

    func body(content: Content) -> some View {
        switch layout {
        case .list:
            content
                .listRowInsets(.init())
#if os(iOS)
                .padding(.horizontal)
#endif

        case .grid:
            content
                .themeGridCell(isSelected: false)
        }
    }
}

private struct CardModifier: ViewModifier {
    let layout: ProfilesLayout

    func body(content: Content) -> some View {
        switch layout {
        case .list:
#if os(iOS)
            content
                .padding(.vertical)
#elseif os(macOS)
            content
#endif

        case .grid:
            content
        }
    }
}

// MARK: - Previews

#Preview("List") {
    Form {
        HeaderView(layout: .list)
        Section {
            ContentView()
        }
    }
    .themeForm()
    .withMockEnvironment()
}

#Preview("Grid") {
    ScrollView {
        VStack {
            HeaderView(layout: .grid)
                .padding(.bottom)
            ContentView()
                .themeGridCell(isSelected: false)
        }
        .padding()
    }
    .withMockEnvironment()
}

private struct HeaderView: View {
    let layout: ProfilesLayout

    var body: some View {
        InstalledProfileView(
            layout: layout,
            profileManager: .mock,
            profile: .mock,
            tunnel: .mock,
            interactiveManager: InteractiveManager(),
            errorHandler: .default(),
            nextProfileId: .constant(nil)
        )
    }
}

private struct ContentView: View {
    var body: some View {
        ForEach(0..<3) { _ in
            ProfileRowView(
                style: .full,
                profileManager: .mock,
                tunnel: .mock,
                header: Profile.mock.header(),
                interactiveManager: InteractiveManager(),
                errorHandler: .default(),
                nextProfileId: .constant(nil),
                withMarker: true
            )
        }
    }
}
