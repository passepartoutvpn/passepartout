// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import CommonLibrary
import CommonUtils
import SwiftUI

struct ProfileRowView: View, Routable, SizeClassProviding {

    @EnvironmentObject
    private var theme: Theme

    @Environment(\.horizontalSizeClass)
    var hsClass

    @Environment(\.verticalSizeClass)
    var vsClass

    let style: ProfileCardView.Style

    @ObservedObject
    var profileManager: ProfileManager

    let tunnel: ExtendedTunnel

    let preview: ProfilePreview

    let errorHandler: ErrorHandler

    var flow: ProfileFlow?

    var body: some View {
        HStack {
            cardView
            Spacer()
            attributesView
            tunnelToggle
        }
        .unanimated()
    }
}

private extension ProfileRowView {
    var cardView: some View {
        ProfileCardView(
            style: style,
            preview: preview,
            tunnel: tunnel,
            onTap: flow?.onEditProfile
        )
        .contentShape(.rect)
        .foregroundStyle(.primary)
    }

    var attributesView: some View {
        ProfileAttributesView(
            attributes: attributes,
            isRemoteImportingEnabled: profileManager.isRemoteImportingEnabled
        )
        .imageScale(isBigDevice ? .large : .medium)
    }

    var tunnelToggle: some View {
        TunnelToggle(
            tunnel: tunnel,
            profile: profile,
            errorHandler: errorHandler,
            flow: flow?.connectionFlow
        )
        .labelsHidden()
        .uiAccessibility(.App.profileToggle)
    }
}

private extension ProfileRowView {
    var profile: Profile? {
        profileManager.profile(withId: preview.id)
    }

    var attributes: [ProfileAttributesView.Attribute] {
        if isTV {
            return [.tv]
        } else if isShared {
            return [.shared]
        }
        return []
    }

    var requiredFeatures: Set<AppFeature>? {
        profileManager.requiredFeatures(forProfileWithId: preview.id)
    }

    var isShared: Bool {
        profileManager.isRemotelyShared(profileWithId: preview.id)
    }

    var isTV: Bool {
        isShared && profileManager.isAvailableForTV(profileWithId: preview.id)
    }
}

// MARK: - Previews

#Preview {
    let profile: Profile = .forPreviews
    let profileManager: ProfileManager = .forPreviews

    return Form {
        ProfileRowView(
            style: .full,
            profileManager: profileManager,
            tunnel: .forPreviews,
            preview: .init(profile),
            errorHandler: .default()
        )
    }
    .task {
        do {
            try await profileManager.observeRemote(repository: InMemoryProfileRepository())
            try await profileManager.save(profile, isLocal: true, remotelyShared: true)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    .themeForm()
    .withMockEnvironment()
}
