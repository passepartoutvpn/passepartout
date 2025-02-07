//
//  ProfileCardView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/5/24.
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
import SwiftUI

struct ProfileCardView: View {
    enum Style {
        case compact

        case full
    }

    let style: Style

    let preview: ProfilePreview

    @ObservedObject
    var tunnel: ExtendedTunnel

    var onTap: ((ProfilePreview) -> Void)?

    var body: some View {
        VStack(alignment: .leading) {
            NavigatingButton {
                onTap?(preview)
            } label: {
                Text(preview.name)
                    .font(.headline)
                    .themeTruncating()
            }
            if style == .full {
                modulesView
            }
            tunnelView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .unanimated()
    }
}

private extension ProfileCardView {
    var modulesView: some View {
        Text(preview.subtitle ?? Strings.Views.App.Profile.noModules)
            .multilineTextAlignment(.leading)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.bottom, 4)
    }

    var tunnelView: some View {
        Group {
            if tunnel.currentProfile?.id == preview.id {
                ConnectionStatusText(tunnel: tunnel)
            } else {
                Text(Strings.Entities.TunnelStatus.inactive)
                    .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
    }
}

// MARK: - Previews

#Preview {
    Form {
        Section {
            ProfileCardView(
                style: .compact,
                preview: .init(.forPreviews),
                tunnel: .forPreviews
            )
        }
        Section {
            ProfileCardView(
                style: .full,
                preview: .init(.forPreviews),
                tunnel: .forPreviews
            )
        }
    }
    .themeForm()
    .withMockEnvironment()
}
