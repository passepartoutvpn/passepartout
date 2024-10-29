//
//  ConnectionObserver.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/7/24.
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

import Combine
import CommonLibrary
import Foundation
import PassepartoutKit

@MainActor
public final class ConnectionObserver: ObservableObject {
    public let tunnel: Tunnel

    private let environment: TunnelEnvironment

    private let interval: TimeInterval

    public func value<T>(forKey key: TunnelEnvironmentKey<T>) -> T? where T: Decodable {
        environment.environmentValue(forKey: key)
    }

    public var connectionStatus: ConnectionStatus? {
        value(forKey: TunnelEnvironmentKeys.connectionStatus)
    }

    @Published
    public private(set) var lastErrorCode: PassepartoutError.Code? {
        didSet {
            pp_log(.app, .info, "ConnectionObserver.lastErrorCode -> \(lastErrorCode?.rawValue ?? "nil")")
        }
    }

    @Published
    public private(set) var dataCount: DataCount?

    private var subscriptions: Set<AnyCancellable>

    public init(
        tunnel: Tunnel,
        environment: TunnelEnvironment,
        interval: TimeInterval
    ) {
        self.tunnel = tunnel
        self.environment = environment
        self.interval = interval
        subscriptions = []
    }

    public func observeObjects() {
        tunnel
            .$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else {
                    return
                }
                switch $0 {
                case .activating:
                    lastErrorCode = nil

                default:
                    lastErrorCode = value(forKey: TunnelEnvironmentKeys.lastErrorCode)
                }
                if $0 != .active {
                    dataCount = nil
                }
            }
            .store(in: &subscriptions)

        Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                guard tunnel.status == .active else {
                    return
                }
                dataCount = value(forKey: TunnelEnvironmentKeys.dataCount)
            }
            .store(in: &subscriptions)
    }
}
