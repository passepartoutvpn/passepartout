//
//  OpenVPNView+Remotes.swift
//  Passepartout
//
//  Created by Davide De Rosa on 1/5/25.
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

import CommonUtils
import PassepartoutKit
import SwiftUI

extension OpenVPNView {
    struct RemotesView: View {

        @Binding
        var configurationBuilder: OpenVPN.Configuration.Builder

        @ObservedObject
        var excludedEndpoints: ObservableList<ExtendedEndpoint>

        let isEditable: Bool

        @State
        private var editMode: EditMode = .inactive

        var body: some View {
            RemotesInnerView(
                configurationBuilder: $configurationBuilder,
                excludedEndpoints: excludedEndpoints,
                isEditable: isEditable
            )
            .environment(\.editMode, $editMode)
        }
    }
}

// MARK: - Inner view

private extension OpenVPNView {
    struct RemotesInnerView: View {

        @EnvironmentObject
        private var theme: Theme

        @Environment(\.editMode)
        private var editMode: Binding<EditMode>?

        @Binding
        var configurationBuilder: OpenVPN.Configuration.Builder

        @ObservedObject
        var excludedEndpoints: ObservableList<ExtendedEndpoint>

        let isEditable: Bool

        var body: some View {
            Form {
                if isEditable {
#if os(iOS)
                    if editMode?.wrappedValue == .active {
                        editableSection
                    } else {
                        nonEditableSection
                    }
#else
                    editableSection
#endif
                } else {
                    nonEditableSection
                }
            }
            .themeForm()
            .navigationTitle(Strings.Modules.Openvpn.remotes)
            .toolbar {
#if os(iOS)
                EditButton()
#endif
            }
        }
    }
}

private extension OpenVPNView.RemotesInnerView {
    var editableSection: some View {
        theme.listSection(
            nil,
            addTitle: Strings.Global.Actions.add,
            originalItems: editableRemotesBinding,
            canEmpty: false,
            itemLabel: { isEditing, remote in
#if os(iOS)
                EditableRemoteRow(remote: remote)
#else
                if isEditing {
                    EditableRemoteRow(remote: remote)
                } else if let remote = remote.wrappedValue.asEndpoint {
                    SelectableRemoteButton(
                        remote: remote,
                        all: Set(allRemotes),
                        excludedEndpoints: excludedEndpoints
                    )
                } else {
                    HStack {
                        ThemeImage(.warning)
                        Text(remote.wrappedValue.description)
                    }
                }
#endif
            }
        )
        .labelsHidden()
    }

    var nonEditableSection: some View {
        Section {
            ForEach(allRemotes, id: \.rawValue) { remote in
                SelectableRemoteButton(
                    remote: remote,
                    all: Set(allRemotes),
                    excludedEndpoints: excludedEndpoints
                )
            }
        }
    }
}

private extension OpenVPNView.RemotesInnerView {
    var allRemotes: [ExtendedEndpoint] {
        configurationBuilder.remotes ?? []
    }

    var editableRemotesBinding: Binding<[EditableRemote]> {
        Binding {
            guard let remotes = configurationBuilder.remotes else {
                return []
            }
            return remotes.map {
                EditableRemote(
                    endpoint: "\($0.address):\($0.proto.port)",
                    socketType: $0.proto.socketType
                )
            }
        } set: {
            configurationBuilder.remotes = $0.compactMap(\.asEndpoint)
        }
    }
}

// MARK: - Subviews

private struct EditableRemoteRow: View {
    static let socketTypes: [IPSocketType] = [
        .udp,
        .udp4,
        .udp6,
        .tcp,
        .tcp4,
        .tcp6
    ]

    @Binding
    var remote: EditableRemote

    var body: some View {
        HStack {
            ThemeTextField(
                "",
                text: $remote.endpoint,
                placeholder: Strings.Unlocalized.OpenVPN.Placeholders.endpoint
            )
            Spacer()
            Picker("", selection: $remote.socketType) {
                ForEach(Self.socketTypes, id: \.self) {
                    Text($0.rawValue)
                }
            }
        }
    }
}

private struct SelectableRemoteButton: View {
    let remote: ExtendedEndpoint

    let all: Set<ExtendedEndpoint>

    @ObservedObject
    var excludedEndpoints: ObservableList<ExtendedEndpoint>

    var body: some View {
        Button {
            if excludedEndpoints.contains(remote) {
                excludedEndpoints.remove(remote)
            } else {
                if remaining.count > 1 {
                    excludedEndpoints.add(remote)
                }
            }
        } label: {
            HStack {
                EndpointCardView(endpoint: remote)
                Spacer()
                ThemeImage(.marked)
                    .opaque(!excludedEndpoints.contains(remote))
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private var remaining: Set<ExtendedEndpoint> {
        all.filter {
            !excludedEndpoints.contains($0)
        }
    }
}

// MARK: - View models

private struct EditableRemote: Equatable, EditableValue {
    static let emptyValue = EditableRemote(endpoint: "", socketType: .udp)

    var isEmptyValue: Bool {
        self == Self.emptyValue
    }

    var endpoint: String

    var socketType: IPSocketType

    var description: String {
        endpoint
    }
}

extension EditableRemote {
    init(endpoint: ExtendedEndpoint) {
        self.init(
            endpoint: "\(endpoint.address):\(endpoint.proto.port)",
            socketType: endpoint.proto.socketType
        )
    }

    var asEndpoint: ExtendedEndpoint? {
        var components = endpoint.split(separator: ":")
        guard components.count >= 2, let port = components.last else {
            return nil
        }
        components.removeLast()
        let address = components.joined(separator: ":")
        let rawValue = "\(address):\(socketType.rawValue):\(port)"
        return ExtendedEndpoint(rawValue: rawValue)
    }
}

// MARK: - Previews

private struct Preview: View {
    let isEditable: Bool

    @State
    private var builder: OpenVPN.Configuration.Builder = .forPreviews

    @State
    private var list: Set<ExtendedEndpoint> = []

    var body: some View {
        OpenVPNView.RemotesView(
            configurationBuilder: $builder,
            excludedEndpoints: ObservableList<ExtendedEndpoint>(
                contains: { list.contains($0) },
                add: { list.insert($0) },
                remove: { list.remove($0) }
            ),
            isEditable: isEditable
        )
    }
}

#Preview("Non-Editable") {
    Preview(isEditable: false)
        .withMockEnvironment()
}

#Preview("Editable") {
    Preview(isEditable: true)
        .withMockEnvironment()
        .themeNavigationStack()
}
