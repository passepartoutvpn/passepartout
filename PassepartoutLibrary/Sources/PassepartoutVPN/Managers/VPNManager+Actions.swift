//
//  VPNManager+Actions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/30/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
import PassepartoutCore
import PassepartoutUtils

// IMPORTANT: if active profile is set/modified and it happens to also be
// current profile, this must be updated too. this is done in
// ProfileManager.activateProfile()

extension VPNManager {
    public func connectWithActiveProfile(toServer newServerId: String?) async throws {
        guard currentState.vpnStatus != .connected else {
            pp_log.warning("VPN is already connected")
            return
        }
        guard let profileId = profileManager.activeProfileId else {
            pp_log.warning("No active profile")
            return
        }
        if let newServerId = newServerId {
            _ = try await connect(with: profileId, toServer: newServerId)
        } else {
            _ = try await connect(with: profileId)
        }
    }

    @discardableResult
    public func connect(with profileId: UUID, newPassword: String? = nil) async throws -> Profile {
        let result = try profileManager.liveProfileEx(withId: profileId)
        var profile = result.profile
        guard !profileManager.isActiveProfile(profileId) ||
              currentState.vpnStatus != .connected else {

            pp_log.warning("Profile \(profile.logDescription) is already active and connected")
            return profile
        }
        if !result.isReady {
            try await profileManager.makeProfileReady(profile)
        }

        pp_log.info("Connecting to: \(profile.logDescription)")
        if let newPassword {
            profile.account.password = newPassword
        }
        let cfg = try vpnConfiguration(withProfile: profile)

        profileManager.activateProfile(profile)
        await reconnect(cfg)
        return profile
    }

    @discardableResult
    public func connect(with profileId: UUID, toServer newServerId: String) async throws -> Profile {
        let result = try profileManager.liveProfileEx(withId: profileId)
        var profile = result.profile
        guard profile.isProvider else {
            assertionFailure("Profile \(profile.logDescription) is not a provider")
            throw PassepartoutError.missingProfile
        }
        if !result.isReady {
            try await profileManager.makeProfileReady(profile)
        }

        let oldServerId = profile.providerServerId
        guard let newServer = providerManager.server(withId: newServerId) else {
            pp_log.warning("Server \(newServerId) not found")
            throw PassepartoutError.missingProviderServer
        }
        guard !profileManager.isActiveProfile(profileId) ||
                currentState.vpnStatus != .connected ||
                oldServerId != newServer.id else {

            pp_log.info("Profile \(profile.logDescription) is already active and connected to: \(newServer.logDescription)")
            return profile
        }

        pp_log.info("Connecting to: \(profile.logDescription) @ \(newServer.logDescription)")
        profile.setProviderServer(newServer)
        let cfg = try vpnConfiguration(withProfile: profile)

        profileManager.activateProfile(profile)
        guard !profileManager.isCurrentProfile(profileId) else {
            pp_log.debug("Active profile is current, will reconnect via observation")
            return profile
        }
        await reconnect(cfg)
        return profile
    }

    public func modifyActiveProfile(_ block: (inout Profile) -> Void) async throws {
        guard var profile = profileManager.activeProfile else {
            pp_log.warning("Nothing to modify, no active profile")
            return
        }

        pp_log.info("Modifying active profile")
        block(&profile)
        let cfg = try vpnConfiguration(withProfile: profile)

        profileManager.activateProfile(profile)
        guard !profileManager.isCurrentProfile(profile.id) else {
            pp_log.debug("Active profile is current, will reinstate via observation")
            return
        }
        await reinstate(cfg)
    }
}
