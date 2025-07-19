//
//  RefreshInfrastructureButton.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/25/24.
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

public struct RefreshInfrastructureButton<Label>: View where Label: View {

    @EnvironmentObject
    private var apiManager: APIManager

    @EnvironmentObject
    private var kvManager: KeyValueManager

    private let module: ProviderModule

    private let label: () -> Label

    @State
    private var elapsed: TimeInterval = .infinity

    public init(module: ProviderModule, label: @escaping () -> Label) {
        self.module = module
        self.label = label
    }

    public var body: some View {
        Button {
            Task {
                try await apiManager.fetchInfrastructure(for: module)
                saveLastUpdate()
            }
        } label: {
            label()
        }
        .disabled(elapsed <= Constants.shared.api.refreshInfrastructureRateLimit)
        .task {
            loadLastUpdate()
        }
        .onChange(of: elapsed) {
            pp_log_g(.app, .info, "Elapsed since last update of \(module.providerId): \($0)")
        }
    }
}

extension RefreshInfrastructureButton where Label == RefreshInfrastructureButtonProgressView {
    public init(module: ProviderModule) {
        self.module = module
        label = {
            RefreshInfrastructureButtonProgressView()
        }
    }
}

public struct RefreshInfrastructureButtonProgressView: View {

    @EnvironmentObject
    private var apiManager: APIManager

    public var body: some View {
#if os(iOS)
        HStack {
            Text(Strings.Views.Providers.refreshInfrastructure)
            if apiManager.isLoading {
                Spacer()
                ProgressView()
            }
        }
#else
        Text(Strings.Views.Providers.refreshInfrastructure)
#endif
    }
}

private extension RefreshInfrastructureButton {
    func loadLastUpdate() {
        guard let map = kvManager.object(forKey: UIPreference.lastInfrastructureRefresh.key) as [String: TimeInterval]? else {
            elapsed = .infinity
            return
        }
        guard let lastUpdate = map[module.providerId.rawValue] else {
            elapsed = .infinity
            return
        }
        elapsed = Date.timeIntervalSinceReferenceDate - lastUpdate
    }

    func saveLastUpdate() {
        var map = kvManager.object(forKey: UIPreference.lastInfrastructureRefresh.key) as [String: TimeInterval]? ?? [:]
        map[module.providerId.rawValue] = Date.timeIntervalSinceReferenceDate
        kvManager.set(map, forKey: UIPreference.lastInfrastructureRefresh.key)
        elapsed = .zero
    }
}
