//
//  EndpointView+Add.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/22/23.
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

#if !os(tvOS)
import PassepartoutLibrary
import SwiftUI
import TunnelKitCore

extension EndpointView {
    struct AddView: View {
        @Environment(\.presentationMode) private var presentationMode

        private let title: String

        private let endpoint: Endpoint?

        private let onSave: ((Endpoint, Endpoint?) -> Void)?

        @State private var socketType: SocketType = .udp

        @State private var address = ""

        @State private var port = ""

        @State private var didAppear = false

        private let allSocketTypes: [SocketType] = [
            .udp,
            .udp4,
            .udp6,
            .tcp,
            .tcp4,
            .tcp6
        ]

        init(_ title: String, endpoint: Endpoint? = nil, onSave: ((Endpoint, Endpoint?) -> Void)? = nil) {
            self.title = title
            self.endpoint = endpoint
            self.onSave = onSave
        }

        var body: some View {
            List {
                Section {
                    themeTextPicker(
                        L10n.Global.Strings.protocol,
                        selection: $socketType,
                        values: allSocketTypes,
                        description: \.rawValue
                    )
                    TextField(L10n.Global.Strings.address, text: $address, onCommit: commitChanges)
                        .themeValidIPAddress(address)
                    TextField(L10n.Global.Strings.port, text: $port, onCommit: commitChanges)
                        .themeValidSocketPort(port)
                }
            }.onAppear {
                guard !didAppear, let endpoint else {
                    return
                }
                socketType = endpoint.proto.socketType
                address = endpoint.address
                port = String(endpoint.proto.port)
                didAppear = true
            }.themeSecondaryView()
            .navigationTitle(title)
            .toolbar {
                themeCloseItem(presentationMode: presentationMode)
                ToolbarItem(placement: .primaryAction) {
                    Button(action: commitChanges, label: themeSaveButtonLabel)
                }
            }
        }
    }
}

// MARK: -

private extension EndpointView.AddView {
}

// MARK: -

private extension EndpointView.AddView {
    func commitChanges() {
        let endpointString = "\(address):\(socketType.rawValue):\(port)"
        guard let newEndpoint = Endpoint(rawValue: endpointString) else {
            return
        }
        onSave?(newEndpoint, endpoint)
        presentationMode.wrappedValue.dismiss()
    }
}
#endif
