//
//  TunnelKitVPNManagerStrategy.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/4/22.
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
import NetworkExtension
import TunnelKitCore
import TunnelKitManager
import TunnelKitOpenVPNCore
import PassepartoutCore
import PassepartoutUtils

public class TunnelKitVPNManagerStrategy<VPNType: VPN>: VPNManagerStrategy where VPNType.Configuration == NetworkExtensionConfiguration, VPNType.Extra == NetworkExtensionExtra {
    private struct AtomicState: Equatable {
        let isEnabled: Bool

        let vpnStatus: VPNStatus

        init(isEnabled: Bool = false, vpnStatus: VPNStatus = .disconnected) {
            self.isEnabled = isEnabled
            self.vpnStatus = vpnStatus
        }
    }

    private let reconnectionSeconds = 2

    private let appGroup: String

    private let tunnelBundleIdentifier: (VPNProtocolType) -> String

    private let defaults: UserDefaults

    private let vpn: VPNType

    private let dataCountInterval: TimeInterval

    // MARK: State

    private var currentState: ObservableVPNState?

    private let vpnState = CurrentValueSubject<AtomicState, Never>(.init())

    private var dataCountTimer: AnyCancellable?

    private var cancellables: Set<AnyCancellable> = []

    // MARK: Protocol specific

    private var currentBundleIdentifier: String?

    public init(
        appGroup: String,
        tunnelBundleIdentifier: @escaping (VPNProtocolType) -> String,
        vpn: VPNType,
        dataCountInterval: TimeInterval = 3.0
    ) {
        self.appGroup = appGroup
        self.tunnelBundleIdentifier = tunnelBundleIdentifier
        guard let defaults = UserDefaults(suiteName: appGroup) else {
            fatalError("No entitlements for group '\(appGroup)'")
        }
        self.defaults = defaults
        self.vpn = vpn
        self.dataCountInterval = dataCountInterval

        registerNotification(withName: VPNNotification.didReinstall) {
            self.onVPNReinstall($0)
        }
        registerNotification(withName: VPNNotification.didChangeStatus) {
            self.onVPNStatus($0)
        }
        registerNotification(withName: VPNNotification.didFail) {
            self.onVPNFail($0)
        }
        Task {
            await vpn.prepare()
        }
    }

    private func registerNotification(withName name: Notification.Name, perform: @escaping (Notification) -> Void) {
        NotificationCenter.default.publisher(for: name, object: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: perform)
            .store(in: &cancellables)
    }

    // MARK: Strategy

    public func observe(into state: ObservableVPNState) {
        currentState = state

        // use this to drop redundant NE notifications
        vpnState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink {
                self.currentState?.isEnabled = $0.isEnabled
                self.currentState?.vpnStatus = $0.vpnStatus
            }.store(in: &cancellables)
    }

    public func reinstate(configuration: VPNConfiguration) async {
        guard let vpnType = configuration.neConfiguration as? VPNProtocolProviding else {
            fatalError("Configuration must implement VPNProtocolProviding")
        }
        let bundleIdentifier = tunnelBundleIdentifier(vpnType.vpnProtocol)
        currentBundleIdentifier = bundleIdentifier

        pp_log.verbose("Configuration: \(configuration)")
        pp_log.info("Reinstating VPN...")
        do {
            try await vpn.install(
                bundleIdentifier,
                configuration: configuration.neConfiguration,
                extra: configuration.neExtra
            )
        } catch {
            pp_log.error("Unable to install: \(error)")
        }
    }

    public func connect(configuration: VPNConfiguration) async {
        guard let vpnType = configuration.neConfiguration as? VPNProtocolProviding else {
            fatalError("Configuration must implement VPNProtocolProviding")
        }
        let bundleIdentifier = tunnelBundleIdentifier(vpnType.vpnProtocol)
        currentBundleIdentifier = bundleIdentifier

        pp_log.verbose("Configuration: \(configuration)")
        pp_log.info("Reconnecting VPN...")
        do {
            try await vpn.reconnect(
                bundleIdentifier,
                configuration: configuration.neConfiguration,
                extra: configuration.neExtra,
                after: .seconds(reconnectionSeconds)
            )
        } catch {
            pp_log.error("Unable to connect: \(error)")
        }
    }

    public func reconnect() async {
        try? await vpn.reconnect(
            after: .seconds(reconnectionSeconds)
        )
    }

    public func disconnect() async {
        await vpn.disconnect()
    }

    public func removeConfigurations() async {
        await vpn.uninstall()

        // XXX: force isEnabled to false as it's not properly notified by NetworkExtension
        vpnState.send(AtomicState(
            isEnabled: false,
            vpnStatus: vpnState.value.vpnStatus
        ))
    }

    // MARK: Notifications

    private func onVPNReinstall(_ notification: Notification) {
        guard isRelevantNotification(notification) else {
            return
        }

        vpnState.send(AtomicState(
            isEnabled: notification.vpnIsEnabled,
            vpnStatus: vpnState.value.vpnStatus
        ))
    }

    private func onVPNStatus(_ notification: Notification) {

        // assume first notified identifier to be the relevant one
        // in order to restore VPN status on app launch
        if currentBundleIdentifier == nil {
            currentBundleIdentifier = notification.vpnBundleIdentifier
        }
        guard isRelevantNotification(notification) else {
            return
        }

        var error: Error?

        switch notification.vpnStatus {
        case .connected:
            startCountingData()

        case .disconnecting:
            error = lastError(withBundleIdentifier: notification.vpnBundleIdentifier)

        case .disconnected:
            error = lastError(withBundleIdentifier: notification.vpnBundleIdentifier)
            stopCountingData()

        default:
            break
        }

        vpnState.send(AtomicState(
            isEnabled: notification.vpnIsEnabled,
            vpnStatus: notification.vpnStatus
        ))
        currentState?.lastError = error
    }

    private func onVPNFail(_ notification: Notification) {
        vpnState.send(AtomicState(
            isEnabled: notification.vpnIsEnabled,
            vpnStatus: vpnState.value.vpnStatus
        ))
        currentState?.lastError = notification.vpnError
    }

    private func isRelevantNotification(_ notification: Notification) -> Bool {
        guard let notificationTunnelIdentifier = notification.vpnBundleIdentifier else {
            return false
        }
        guard notificationTunnelIdentifier == currentBundleIdentifier else {
            pp_log.debug("Skipping not relevant notification from \(notificationTunnelIdentifier)")
            return false
        }
        return true
    }

    // MARK: Data count

    private func onDataCount(_: Date) {
        switch vpnState.value.vpnStatus {
        case .connected:
            guard let currentDataCount = currentDataCount else {
                return
            }
            currentState?.dataCount = currentDataCount

        default:
            currentState?.dataCount = nil
        }
    }

    private func startCountingData() {
        guard dataCountTimer == nil else {
            return
        }
        dataCountTimer = Timer.TimerPublisher(interval: dataCountInterval, runLoop: .main, mode: .common)
            .autoconnect()
            .sink {
                self.onDataCount($0)
            }
    }

    private func stopCountingData() {
        dataCountTimer?.cancel()
        dataCountTimer = nil

        currentState?.dataCount = nil
    }

    // MARK: Pulled

    public func serverConfiguration(forProtocol vpnProtocol: VPNProtocolType) -> Any? {
        switch vpnProtocol {
        case .openVPN:
            return defaults.openVPNServerConfiguration

        default:
            return nil
        }
    }

    public func debugLogURL(forProtocol vpnProtocol: VPNProtocolType) -> URL? {
        switch vpnProtocol {
        case .openVPN:
            return defaults.openVPNURLForDebugLog(appGroup: appGroup)

        default:
            return defaults.wireGuardURLForDebugLog(appGroup: appGroup)
        }
    }

    // MARK: Callbacks

    private func lastError(withBundleIdentifier bundleIdentifier: String?) -> Error? {
        switch bundleIdentifier {
        case tunnelBundleIdentifier(.openVPN):
            return defaults.openVPNLastError

        case tunnelBundleIdentifier(.wireGuard):
            return defaults.wireGuardLastError

        default:
            return nil
        }
    }

    private var currentDataCount: DataCount? {
        switch currentBundleIdentifier {
        case tunnelBundleIdentifier(.openVPN):
            return defaults.openVPNDataCount

        default:
            return nil
        }
    }
}
