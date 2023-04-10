//
//  VPNManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/9/22.
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
import Combine
import PassepartoutCore
import PassepartoutProfiles
import PassepartoutProviders
import PassepartoutUtils

@MainActor
public final class VPNManager: ObservableObject {

    // MARK: Initialization

    let appGroup: String

    private let store: KeyValueStore

    let profileManager: ProfileManager

    let providerManager: ProviderManager

    private let strategy: VPNManagerStrategy

    public var isNetworkSettingsSupported: () -> Bool

    public var isOnDemandRulesSupported: () -> Bool

    // MARK: State

    public let currentState: ObservableVPNState

    public let didUpdatePreferences = PassthroughSubject<VPNPreferences, Never>()

    public private(set) var lastError: Error? {
        get {
            currentState.lastError
        }
        set {
            currentState.lastError = newValue
        }
    }

    public let configurationError = PassthroughSubject<VPNConfigurationError, Never>()

    // MARK: Internals

    private var lastProfile: Profile = .placeholder

    private var cancellables: Set<AnyCancellable> = []

    public init(
        appGroup: String,
        store: KeyValueStore,
        profileManager: ProfileManager,
        providerManager: ProviderManager,
        strategy: VPNManagerStrategy
    ) {
        self.appGroup = appGroup
        self.store = store
        self.profileManager = profileManager
        self.providerManager = providerManager
        self.strategy = strategy
        isNetworkSettingsSupported = { true }
        isOnDemandRulesSupported = { true }

        currentState = ObservableVPNState()
    }

    func reinstate(_ configuration: VPNConfiguration) async {
        pp_log.info("Reinstating VPN")
        clearLastError()
        await strategy.reinstate(configuration: configuration)
    }

    func reconnect(_ configuration: VPNConfiguration) async {
        pp_log.info("Reconnecting VPN (with new configuration)")
        clearLastError()
        await strategy.connect(configuration: configuration)
    }

    public func reconnect() async {
        pp_log.info("Reconnecting VPN")
        clearLastError()
        await strategy.reconnect()
    }

    public func disable() async {
        pp_log.info("Disabling VPN")
        clearLastError()
        await strategy.disconnect()
    }

    public func uninstall() async {
        pp_log.info("Uninstalling VPN")
        clearLastError()
        await strategy.removeConfigurations()
    }

    public func serverConfiguration(forProtocol vpnProtocol: VPNProtocolType) -> Any? {
        strategy.serverConfiguration(forProtocol: vpnProtocol)
    }

    public func debugLogURL(forProtocol vpnProtocol: VPNProtocolType) -> URL? {
        strategy.debugLogURL(forProtocol: vpnProtocol)
    }

    private func clearLastError() {
        guard currentState.lastError != nil else {
            return
        }
        currentState.lastError = nil
    }
}

// MARK: Observation

extension VPNManager {
    public func observeUpdates() {
        observeStrategy()
        observeProfileManager()
    }

    private func observeStrategy() {
        strategy.observe(into: currentState)
    }

    private func observeProfileManager() {
        profileManager.didUpdateActiveProfile
            .dropFirst()
            .removeDuplicates()
            .sink { newId in
                Task {
                    await self.willUpdateActiveId(newId)
                }
            }.store(in: &cancellables)

        profileManager.currentProfile.$value
            .dropFirst()
            .removeDuplicates()
            .sink { newProfile in
                Task {
                    await self.willUpdateCurrentProfile(newProfile)
                }
            }.store(in: &cancellables)
    }

    private func willUpdateActiveId(_ newId: UUID?) async {
        guard let newId = newId else {
            pp_log.info("No active profile, disconnecting VPN...")
            await disable()
            return
        }
        pp_log.debug("Active profile: \(newId)")
    }

    private func willUpdateCurrentProfile(_ newProfile: Profile) async {
        defer {
            lastProfile = newProfile
        }
        // ignore if VPN disabled
        guard currentState.isEnabled else {
            pp_log.debug("Ignoring updates, VPN is disabled")
            return
        }
        // ignore non-active profiles
        guard profileManager.isActiveProfile(newProfile.id) else {
            pp_log.debug("Ignoring updates, profile \(newProfile.logDescription) is not active")
            return
        }
        // ignore profile changes, react on changes within same profile
        guard newProfile.id == lastProfile.id else {
            return
        }

        pp_log.debug("Active profile updated: \(newProfile.header.name)")

        var isHandled = false
        var shouldReconnect = false
        let notDisconnected = (currentState.vpnStatus != .disconnected)

        // do not reconnect if connected
        if newProfile.isProvider {

            // server changed?
            if newProfile.providerServerId != lastProfile.providerServerId {
                pp_log.info("Provider server changed: \(newProfile.providerServerId?.description ?? "nil")")
                isHandled = true
                shouldReconnect = notDisconnected
            }

            // endpoint changed?
            else if newProfile.providerCustomEndpoint != lastProfile.providerCustomEndpoint {
                pp_log.info("Provider endpoint changed: \(newProfile.providerCustomEndpoint?.description ?? "automatic")")
                isHandled = true
                shouldReconnect = notDisconnected
            }
        } else {

            // endpoint changed?
            if newProfile.hostCustomEndpoint != lastProfile.hostCustomEndpoint {
                pp_log.info("Host endpoint changed: \(newProfile.hostCustomEndpoint?.description ?? "automatic")")
                isHandled = true
                shouldReconnect = notDisconnected
            }
        }

        if !isHandled {
            if newProfile.onDemand != lastProfile.onDemand {
                pp_log.info("On-demand settings changed")
                isHandled = true
                shouldReconnect = false
            }
        }

        guard isHandled else {
            return
        }
        guard let cfg = vpnConfigurationWithCurrentProfile() else {
            return
        }
        if shouldReconnect {
            await reconnect(cfg)
        } else {
            await reinstate(cfg)
        }
    }
}

// MARK: KeyValueStore

extension VPNManager {
    public var tunnelLogPath: String? {
        get {
            store.value(forLocation: StoreKey.tunnelLogPath)
        }
        set {
            store.setValue(newValue, forLocation: StoreKey.tunnelLogPath)
            didUpdatePreferences.send(vpnPreferences)
        }
    }

    public var tunnelLogFormat: String? {
        get {
            store.value(forLocation: StoreKey.tunnelLogFormat)
        }
        set {
            store.setValue(newValue, forLocation: StoreKey.tunnelLogFormat)
            didUpdatePreferences.send(vpnPreferences)
        }
    }

    public var masksPrivateData: Bool {
        get {
            store.value(forLocation: StoreKey.masksPrivateData) ?? true
        }
        set {
            store.setValue(newValue, forLocation: StoreKey.masksPrivateData)
            didUpdatePreferences.send(vpnPreferences)
        }
    }
}

private extension VPNManager {
    private enum StoreKey: String, KeyStoreDomainLocation {
        case tunnelLogPath

        case tunnelLogFormat

        case masksPrivateData

        var domain: String {
            "Passepartout.VPNManager"
        }
    }
}
