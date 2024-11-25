//
//  VPNProviderServerView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/7/24.
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

import CommonAPI
import CommonLibrary
import CommonUtils
import PassepartoutKit
import SwiftUI

struct VPNProviderServerView<Configuration>: View where Configuration: ProviderConfigurationIdentifiable & Codable {
    var apis: [APIMapper] = API.shared

    let moduleId: UUID

    let providerId: ProviderID

    let configurationType: Configuration.Type

    let selectedEntity: VPNEntity<Configuration>?

    let filtersWithSelection: Bool

    var selectTitle = Strings.Views.Providers.selectEntity

    let onSelect: (VPNServer, VPNPreset<Configuration>) -> Void

    @StateObject
    private var vpnManager = VPNProviderManager<Configuration>(sorting: [
        .localizedCountry,
        .area,
        .serverId
    ])

    @StateObject
    private var filtersViewModel = VPNFiltersView.Model()

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        debugChanges()
        return contentView
            .themeNavigationDetail()
            .withErrorHandler(errorHandler)
    }
}

extension VPNProviderServerView {
    var containerView: some View {
        ContainerView(
            vpnManager: vpnManager,
            apis: apis,
            moduleId: moduleId,
            providerId: providerId,
            selectedServer: selectedEntity?.server,
            filtersViewModel: filtersViewModel,
            initialFilters: initialFilters,
            selectTitle: selectTitle,
            onSelect: onSelect,
            errorHandler: errorHandler
        )
    }

    var filtersView: some View {
        VPNFiltersView(
            apis: apis,
            providerId: providerId,
            model: filtersViewModel
        )
    }

    var initialFilters: VPNFilters? {
        guard let selectedEntity, filtersWithSelection else {
            return nil
        }
        var filters = VPNFilters()
        filters.categoryName = selectedEntity.server.provider.categoryName
#if os(macOS)
        filters.countryCode = selectedEntity.server.provider.countryCode
#endif
        return filters
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VPNProviderServerView(
            apis: [API.bundled],
            moduleId: UUID(),
            providerId: .protonvpn,
            configurationType: OpenVPN.Configuration.self,
            selectedEntity: nil,
            filtersWithSelection: false,
            selectTitle: "Select",
            onSelect: { _, _ in }
        )
    }
    .withMockEnvironment()
}
