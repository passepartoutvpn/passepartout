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
import PassepartoutKit
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
    var focusedField: ProfileView.Field?

    @ObservedObject
    var errorHandler: ErrorHandler

    var flow: ConnectionFlow?

    var body: some View {
        VStack(spacing: .zero) {
            VStack {
                VStack {
                    currentProfileView
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
//            .padding(.top, 50)

            Spacer()
        }
    }
}

private extension ActiveProfileView {
    var currentProfileView: some View {
        Text(profile?.name ?? Strings.Views.App.InstalledProfile.None.name)
            .font(.title)
            .fontWeight(theme.relevantWeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .uiAccessibility(.App.installedProfile)
    }

    var statusView: some View {
        ConnectionStatusText(tunnel: tunnel)
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(tunnel.statusColor(theme))
            .brightness(0.2)
    }

    func detailView(for profile: Profile) -> some View {
        VStack(spacing: 10) {
            if let connectionType = profile.localizedDescription(optionalStyle: .connectionType) {
                ListRowView(title: Strings.Global.Nouns.protocol) {
                    Text(connectionType)
                }
            }
            if let pair = profile.selectedProvider {
                if let provider = apiManager.provider(withId: pair.selection.id) {
                    ListRowView(title: Strings.Global.Nouns.provider) {
                        Text(provider.description)
                    }
                }
                if let entityHeader = pair.selection.entityHeader {
                    ListRowView(title: Strings.Global.Nouns.country) {
                        ThemeCountryText(entityHeader.countryCode)
                    }
                }
            }
            if let otherList = profile.localizedDescription(optionalStyle: .nonConnectionTypes) {
                ListRowView(title: otherList) {
                    EmptyView()
                }
            }
        }
        .font(.title3)
    }

    var toggleConnectionButton: some View {
        TunnelToggleButton(
            tunnel: tunnel,
            profile: profile,
            nextProfileId: .constant(nil),
            errorHandler: errorHandler,
            flow: flow,
            label: {
                Text($0 ? Strings.Global.Actions.connect : Strings.Global.Actions.disconnect)
                    .frame(maxWidth: .infinity)
                    .fontWeight(theme.relevantWeight)
                    .forMainButton(
                        withColor: toggleConnectionColor,
                        focused: focusedField == .connect,
                        disabled: $1
                    )
            }
        )
        .focused($focusedField, equals: .connect)
    }

    var toggleConnectionColor: Color {
        switch tunnel.status {
        case .inactive:
            return tunnel.currentProfile?.onDemand == true ? theme.disableColor : theme.enableColor
        default:
            return theme.disableColor
        }
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

// MARK: - Local modifiers

private extension View {
    func forMainButton(withColor color: Color, focused: Bool, disabled: Bool) -> some View {
        padding(.vertical, 25)
            .background(disabled ? .gray : color)
            .cornerRadius(50)
            .font(.title3)
            .foregroundColor(disabled ? .white.opacity(0.6) : .white)
            .overlay(
                RoundedRectangle(cornerRadius: 50)
                    .fill(.white.opacity(focused ? 0.3 : 0.0))
            )
            .scaleEffect(focused ? 1.05 : 1.0)
    }
}

// MARK: - Previews

#Preview("Host") {
    let profile: Profile = {
        do {
            let moduleBuilder = OpenVPNModule.Builder()
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
            var moduleBuilder = OpenVPNModule.Builder()
            moduleBuilder.providerId = .mullvad
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
        try? await APIManager.forPreviews.fetchIndex(from: [API.bundled])
    }
}

private struct ContentPreview: View {
    let profile: Profile

    @State
    private var isSwitching = false

    @FocusState
    private var focusedField: ProfileView.Field?

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
