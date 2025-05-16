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
@_exported import Partout

@MainActor
public final class CommonLibrary {
    public enum Target {
        case app

        case tunnel(Profile.ID)
    }

    private let kvStore: KeyValueManager

    public init(kvStore: KeyValueManager) {
        self.kvStore = kvStore
    }

    public func configurePartout(forTarget target: Target) -> PartoutContext {
        switch target {
        case .app:
            return configureApp()
        case .tunnel(let profileId):
            return configureTunnel(profileId: profileId)
        }
    }
}

private extension CommonLibrary {
    func configureApp() -> PartoutContext {
        configureShared()

        var ctxBuilder = PartoutContext.Builder()
        let logsPrivateData = kvStore.bool(forKey: AppPreference.logsPrivateData.key)
        ctxBuilder.configureLogging(
            to: BundleConfiguration.urlForAppLog,
            parameters: Constants.shared.log,
            logsPrivateData: logsPrivateData
        )
        let ctx = ctxBuilder.build()
        PartoutContext.register(ctx)

        ctx.logPreamble(parameters: Constants.shared.log)
        return ctx
    }

    func configureTunnel(profileId: Profile.ID) -> PartoutContext {
        configureShared()

        var ctxBuilder = PartoutContext.Builder(profileId: profileId)
        // FIXME: #1374, AppPreference not accessible by sysex
        let logsPrivateData = kvStore.bool(forKey: AppPreference.logsPrivateData.key)
        ctxBuilder.configureLogging(
            to: BundleConfiguration.urlForTunnelLog,
            parameters: Constants.shared.log,
            logsPrivateData: logsPrivateData
        )
        // FIXME: #1374, AppPreference not accessible by sysex
        if kvStore.bool(forKey: AppPreference.dnsFallsBack.key) {
            ctxBuilder.dnsFallbackServers = Constants.shared.tunnel.dnsFallbackServers
        }
        let ctx = ctxBuilder.build()
        PartoutContext.register(ctx)

        ctx.logPreamble(parameters: Constants.shared.log)
        if let dnsFallbackServers = ctx.dnsFallbackServers {
            pp_log(ctx, .app, .info, "Enable DNS fallback servers: \(dnsFallbackServers)")
        }
        return ctx
    }

    func configureShared() {
        kvStore.fallback = [
            AppPreference.dnsFallsBack.key: true,
            AppPreference.logsPrivateData.key: false
        ]
    }
}

private extension PartoutContext {
    func logPreamble(parameters: Constants.Log) {
        appendLog(parameters.options.maxLevel, message: "")
        appendLog(parameters.options.maxLevel, message: "--- BEGIN ---")
        appendLog(parameters.options.maxLevel, message: "")

        let systemInfo = SystemInformation()
        appendLog(parameters.options.maxLevel, message: "App: \(BundleConfiguration.mainVersionString)")
        appendLog(parameters.options.maxLevel, message: "OS: \(systemInfo.osString)")
        if let deviceString = systemInfo.deviceString {
            appendLog(parameters.options.maxLevel, message: "Device: \(deviceString)")
        }
        appendLog(parameters.options.maxLevel, message: "")
    }
}
