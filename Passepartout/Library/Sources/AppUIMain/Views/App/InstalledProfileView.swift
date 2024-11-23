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

import CommonLibrary
import CommonUtils
import PassepartoutKit
import SwiftUI

struct InstalledProfileView: View, Routable {

    @EnvironmentObject
    private var theme: Theme

    let layout: ProfilesLayout

    let profileManager: ProfileManager

    let profile: Profile?

    let tunnel: ExtendedTunnel

    let interactiveManager: InteractiveManager

    let errorHandler: ErrorHandler

    @Binding
    var nextProfileId: Profile.ID?

    var flow: ProfileFlow?

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
    var isOpaque: Bool {
        profile != nil
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
        Text(profile?.name ?? Strings.Views.App.Rows.notInstalled)
            .font(.title2)
            .fontWeight(theme.relevantWeight)
            .themeTruncating(.tail)
    }

    var statusView: some View {
        HStack {
            providerSelectorButton
            StatusText(
                theme: theme,
                tunnel: tunnel,
                isOpaque: isOpaque
            )
        }
    }

    var toggleButton: some View {
        ToggleButton(
            theme: theme,
            tunnel: tunnel,
            profile: profile,
            nextProfileId: $nextProfileId,
            interactiveManager: interactiveManager,
            errorHandler: errorHandler,
            isOpaque: isOpaque,
            flow: flow
        )
    }

    var menuContent: some View {
        ProfileContextMenu(
            profileManager: profileManager,
            tunnel: tunnel,
            preview: .init(profile ?? .mock),
            interactiveManager: interactiveManager,
            errorHandler: errorHandler,
            isInstalledProfile: true,
            flow: flow
        )
    }

    var providerSelectorButton: some View {
        profile?
            .selectedProvider
            .map { _, selection in
                Button {
                    flow?.onProviderEntityRequired(profile!)
                } label: {
                    providerSelectorLabel(with: selection)
                }
                .buttonStyle(.plain)
            }
    }

    func providerSelectorLabel(with provider: SerializedProvider) -> some View {
        ProviderCountryFlag(provider: provider)
    }
}

// MARK: - Subviews (observing)

private struct StatusText: View {

    @ObservedObject
    var theme: Theme

    @ObservedObject
    var tunnel: ExtendedTunnel

    let isOpaque: Bool

    var body: some View {
        debugChanges()
        return ConnectionStatusText(tunnel: tunnel)
            .font(.body)
            .foregroundStyle(tunnel.statusColor(theme))
            .opaque(isOpaque)
    }
}

private struct ToggleButton: View {

    @ObservedObject
    var theme: Theme

    @ObservedObject
    var tunnel: ExtendedTunnel

    let profile: Profile?

    @Binding
    var nextProfileId: Profile.ID?

    @ObservedObject
    var interactiveManager: InteractiveManager

    @ObservedObject
    var errorHandler: ErrorHandler

    let isOpaque: Bool

    let flow: ProfileFlow?

    var body: some View {
        TunnelToggleButton(
            tunnel: tunnel,
            profile: profile,
            nextProfileId: $nextProfileId,
            interactiveManager: interactiveManager,
            errorHandler: errorHandler,
            onProviderEntityRequired: {
                flow?.onProviderEntityRequired($0)
            },
            onPurchaseRequired: {
                flow?.onPurchaseRequired($0)
            },
            label: { _ in
                ThemeImage(.tunnelToggle)
                    .scaleEffect(1.5, anchor: .trailing)
            }
        )
        // TODO: #584, necessary to avoid cell selection
        .buttonStyle(.plain)
        .foregroundStyle(tunnel.statusColor(theme))
        .opaque(isOpaque)
    }
}

private struct ProviderCountryFlag: View {
    let provider: SerializedProvider

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
#else
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
                preview: .init(.mock),
                interactiveManager: InteractiveManager(),
                errorHandler: .default(),
                nextProfileId: .constant(nil),
                withMarker: true
            )
        }
    }
}
