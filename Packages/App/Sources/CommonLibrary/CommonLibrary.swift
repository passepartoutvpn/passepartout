//
//  CommonLibrary.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/11/25.
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

import Foundation
import Partout

public final class CommonLibrary {
    public enum Target {
        case app

        case tunnel
    }

    public init() {
    }

    public func configure(_ target: Target) {
        switch target {
        case .app:
            configureApp()
        case .tunnel:
            configureTunnel()
        }
    }
}

private extension CommonLibrary {
    func configureApp() {
        configureShared()

        PassepartoutConfiguration.shared.configureLogging(
            to: BundleConfiguration.urlForAppLog,
            parameters: Constants.shared.log,
            logsPrivateData: UserDefaults.appGroup.bool(forKey: AppPreference.logsPrivateData.key)
        )
    }

    func configureTunnel() {
        configureShared()

        PassepartoutConfiguration.shared.configureLogging(
            to: BundleConfiguration.urlForTunnelLog,
            parameters: Constants.shared.log,
            logsPrivateData: UserDefaults.appGroup.bool(forKey: AppPreference.logsPrivateData.key)
        )
        if UserDefaults.appGroup.bool(forKey: AppPreference.dnsFallsBack.key) {
            let servers = Constants.shared.tunnel.dnsFallbackServers
            PassepartoutConfiguration.shared.dnsFallbackServers = servers
            pp_log(.app, .info, "Enable DNS fallback servers: \(servers)")
        }
    }

    func configureShared() {
        UserDefaults.appGroup.register(defaults: [
            AppPreference.dnsFallsBack.key: true,
            AppPreference.logsPrivateData.key: false
        ])
    }
}
