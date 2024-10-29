//
//  IPView+Route.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/20/24.
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

import PassepartoutKit
import SwiftUI

extension IPView {
    struct RouteView: View {

        @EnvironmentObject
        private var theme: Theme

        let family: Address.Family

        let onSubmit: (Route?) -> Void

        @State
        private var destinationString = ""

        @State
        private var gatewayString = ""

        @State
        private var isDefault = false

        var body: some View {
            Form {
                Section {
                    Toggle(Strings.Global.default, isOn: $isDefault.animation(theme.animation(for: .modules)))
                }
                if !isDefault {
                    Section {
                        ThemeTextField(Strings.Global.destination, text: $destinationString, placeholder: Strings.Unlocalized.Placeholders.ipDestination(forFamily: family))
                        ThemeTextField(Strings.Global.gateway, text: $gatewayString, placeholder: Strings.Unlocalized.Placeholders.ipGateway(forFamily: family))
                    }
                }
            }
            .themeForm()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.Global.cancel, role: .cancel) {
                        onSubmit(nil)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.Global.ok, action: parseAndSubmit)
                }
            }
            .themeNavigationDetail()
        }
    }
}

private extension IPView.RouteView {
    func parseAndSubmit() {
        let route: Route
        if isDefault {
            route = Route(defaultWithGateway: nil)
        } else {
            guard let destination = Subnet(rawValue: destinationString) else {
                return
            }
            let gateway = Address(rawValue: gatewayString)
            guard destination.address.family == family else {
                return
            }
            if let gateway {
                guard gateway.family == family else {
                    return
                }
            }
            route = Route(destination, gateway)
        }
        onSubmit(route)
    }
}

#Preview {
    struct Preview: View {

        @State
        private var route: Route?

        @State
        private var isPresented = false

        var body: some View {
            List {
                Button("Add route") {
                    isPresented = true
                }
                .themeModal(isPresented: $isPresented) {
                    NavigationStack {
                        IPView.RouteView(family: .v4) {
                            route = $0
                            isPresented = false
                        }
                        .navigationTitle("Add route")
                    }
                }
                route.map { route in
                    VStack {
                        route.destination.map {
                            Text("Destination")
                                .themeTrailingValue($0.rawValue)
                        }
                        route.gateway.map {
                            Text("Gateway")
                                .themeTrailingValue($0.rawValue)
                        }
                    }
                }
            }
        }
    }

    return Preview()
        .withMockEnvironment()
}
