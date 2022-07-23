//
//  MockVPNManagerStrategy.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/9/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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
import TunnelKitCore
import PassepartoutCore

// XXX: mock connect/disconnect tasks overlap, should cancel other pending task

public class MockVPNManagerStrategy: VPNManagerStrategy {
    private var currentState: ObservableVPNState?
    
    private var dataCountTimer: AnyCancellable?
    
    public init() {
    }
    
    public func observe(into state: ObservableVPNState) {
        currentState = state
    }

    public func reinstate(configuration: VPNConfiguration) {
    }
    
    @MainActor
    public func connect(configuration: VPNConfiguration) {
        guard currentState?.vpnStatus != .connected else {
            return
        }
        Task {
            currentState?.isEnabled = true
            currentState?.vpnStatus = .connecting
            await Task.maybeWait(forMilliseconds: 1000)
            currentState?.vpnStatus = .connected
            startCountingData()
        }
    }

    @MainActor
    public func reconnect() async {
        guard currentState?.vpnStatus == .connected else {
            return
        }
        Task {
            currentState?.vpnStatus = .disconnecting
            await Task.maybeWait(forMilliseconds: 1000)
            currentState?.vpnStatus = .disconnected
            await Task.maybeWait(forMilliseconds: 1000)
            currentState?.vpnStatus = .connecting
            await Task.maybeWait(forMilliseconds: 1000)
            currentState?.vpnStatus = .connected
            currentState?.dataCount = nil
        }
    }
    
    @MainActor
    public func disconnect() {
        stopCountingData()
        guard currentState?.vpnStatus != .disconnected else {
            return
        }
        Task {
            currentState?.isEnabled = false
            currentState?.vpnStatus = .disconnecting
            await Task.maybeWait(forMilliseconds: 1000)
            currentState?.vpnStatus = .disconnected
            currentState?.dataCount = nil
        }
    }
    
    private func startCountingData() {
        guard currentState?.vpnStatus == .connected else {
            return
        }
        guard dataCountTimer == nil else {
            return
        }
        dataCountTimer = Timer.TimerPublisher(interval: 2.0, runLoop: .main, mode: .common)
            .autoconnect()
            .sink(receiveValue: { _ in
                let previous = self.currentState?.dataCount ?? DataCount(0, 0)
                self.currentState?.dataCount = DataCount(previous.received + 4000, previous.sent + 2000)
            })
    }
    
    private func stopCountingData() {
        dataCountTimer?.cancel()
        dataCountTimer = nil
    }
    
    @MainActor
    public func removeConfigurations() {
        disconnect()
    }
    
    public func serverConfiguration(forProtocol vpnProtocol: VPNProtocolType) -> Any? {
        return nil
    }
    
    public func debugLogURL(forProtocol vpnProtocol: VPNProtocolType) -> URL? {
        return nil
    }
}
