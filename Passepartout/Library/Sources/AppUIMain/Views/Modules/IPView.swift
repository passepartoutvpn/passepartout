//
//  IPView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/17/24.
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

import CommonUtils
import PassepartoutKit
import SwiftUI

struct IPView: View, ModuleDraftEditing {

    @ObservedObject
    var editor: ProfileEditor

    let module: IPModule.Builder

    @State
    private var routePresentation: RoutePresentation?

    var body: some View {
        Group {
            ipSections(for: .v4)
            ipSections(for: .v6)
            interfaceSection
        }
        .moduleView(editor: editor, draft: draft.wrappedValue)
        .themeModal(item: $routePresentation, content: routeModal)
    }
}

private extension IPView {
    enum RoutePresentation: Identifiable {
        case included(Address.Family)

        case excluded(Address.Family)

        var id: String {
            switch self {
            case .included(let family):
                return "included.\(family)"

            case .excluded(let family):
                return "excluded.\(family)"
            }
        }

        var family: Address.Family {
            switch self {
            case .included(let family):
                return family

            case .excluded(let family):
                return family
            }
        }

        var localizedTitle: String {
            switch self {
            case .included:
                return Strings.Modules.Ip.Routes.include

            case .excluded:
                return Strings.Modules.Ip.Routes.exclude
            }
        }
    }

    @ViewBuilder
    func ipSections(for family: Address.Family) -> some View {
        let ip = binding(forSettingsIn: family)
        ForEach(Array(ip.wrappedValue.includedRoutes.enumerated()), id: \.offset) { item in
            row(forRoute: item.element) {
                ip.wrappedValue.removeIncluded(at: IndexSet(integer: item.offset))
            }
        }
        .onDelete {
            ip.wrappedValue.removeIncluded(at: $0)
        }
        .asSectionWithHeader(family.localizedDescription) {
            Button(Strings.Modules.Ip.Routes.include) {
                routePresentation = .included(family)
            }
        }
        ForEach(Array(ip.wrappedValue.excludedRoutes.enumerated()), id: \.offset) { item in
            row(forRoute: item.element) {
                ip.wrappedValue.removeExcluded(at: IndexSet(integer: item.offset))
            }
        }
        .onDelete {
            ip.wrappedValue.removeExcluded(at: $0)
        }
        .asSectionWithTrailingContent {
            Button(Strings.Modules.Ip.Routes.exclude) {
                routePresentation = .excluded(family)
            }
        }
    }

    func row(forRoute route: Route, removeAction: @escaping () -> Void) -> some View {
        ThemeRemovableItemRow(isEditing: true) {
            ThemeCopiableText(value: route.localizedDescription) {
                Text($0)
            }
        } removeAction: {
            removeAction()
        }
    }

    var interfaceSection: some View {
        Group {
            ThemeTextField(
                Strings.Unlocalized.mtu,
                text: Binding {
                    draft.wrappedValue.mtu?.description ?? ""
                } set: {
                    draft.wrappedValue.mtu = Int($0)
                },
                placeholder: Strings.Unlocalized.Placeholders.mtu
            )
        }
        .themeSection(header: Strings.Global.interface)
    }
}

private extension IPView {
    func binding(forSettingsIn family: Address.Family) -> Binding<IPSettings> {
        switch family {
        case .v4:
            return Binding {
                draft.wrappedValue.ipv4 ?? IPSettings(subnet: nil)
            } set: {
                draft.wrappedValue.ipv4 = $0
            }

        case .v6:
            return Binding {
                draft.wrappedValue.ipv6 ?? IPSettings(subnet: nil)
            } set: {
                draft.wrappedValue.ipv6 = $0
            }
        }
    }

    func routeModal(item: RoutePresentation) -> some View {
        NavigationStack {
            RouteView(family: item.family) { route in
                defer {
                    routePresentation = nil
                }
                guard let route else {
                    return
                }
                switch item {
                case .included(let family):
                    switch family {
                    case .v4:
                        if draft.wrappedValue.ipv4 == nil {
                            draft.wrappedValue.ipv4 = IPSettings(subnet: nil)
                        }
                        draft.wrappedValue.ipv4?.include(route)

                    case .v6:
                        if draft.wrappedValue.ipv6 == nil {
                            draft.wrappedValue.ipv6 = IPSettings(subnet: nil)
                        }
                        draft.wrappedValue.ipv6?.include(route)
                    }

                case .excluded(let family):
                    switch family {
                    case .v4:
                        if draft.wrappedValue.ipv4 == nil {
                            draft.wrappedValue.ipv4 = IPSettings(subnet: nil)
                        }
                        draft.wrappedValue.ipv4?.exclude(route)

                    case .v6:
                        if draft.wrappedValue.ipv6 == nil {
                            draft.wrappedValue.ipv6 = IPSettings(subnet: nil)
                        }
                        draft.wrappedValue.ipv6?.exclude(route)
                    }
                }
            }
            .navigationTitle(item.localizedTitle)
        }
    }
}

#Preview {
    var module = IPModule.Builder()
    module.ipv4 = IPSettings(subnet: nil)
        .including(routes: [
            .init(defaultWithGateway: .ip("1.2.3.4", .v4)),
            .init(.init(rawValue: "5.5.0.0/16"), .init(rawValue: "5.5.5.5"))
        ])
    module.ipv6 = IPSettings(subnet: nil)
        .including(routes: [
            .init(defaultWithGateway: .ip("fe80::1032:2a6b:fec:f49e", .v6)),
            .init(.init(rawValue: "fe80:1032:2a6b:fec::/24"), .init(rawValue: "fe80:1032:2a6b:fec::1"))
        ])
    return module.preview()
}
