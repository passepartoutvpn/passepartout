//
//  ObservableVPNState.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/27/22.
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

import Foundation
import PassepartoutCore
import TunnelKitCore
import TunnelKitManager

public final class ObservableVPNState: ObservableObject, VPNState {
    @Published public internal(set) var isEnabled = false {
        didSet {
            pp_log.debug("VPN enabled -> \(isEnabled)")
        }
    }

    @Published public internal(set) var vpnStatus: VPNStatus = .disconnected {
        didSet {
            pp_log.debug("VPN status: \(vpnStatus)")
        }
    }

    @Published public internal(set) var lastError: Error? {
        didSet {
            guard let lastError = lastError else {
                return
            }
            pp_log.debug("Last error: \(lastError)")
        }
    }

    @Published public internal(set) var dataCount: DataCount? {
        didSet {
            guard let dataCount = dataCount else {
                return
            }
            pp_log.debug("Data count: \(dataCount)")
        }
    }

    public init() {
    }
}

public final class MutableObservableVPNState: VPNState {
    private let observable: ObservableVPNState

    public var isEnabled: Bool {
        get {
            observable.isEnabled
        }
        set {
            observable.isEnabled = newValue
        }
    }

    public var vpnStatus: VPNStatus {
        get {
            observable.vpnStatus
        }
        set {
            observable.vpnStatus = newValue
        }
    }

    public var lastError: Error? {
        get {
            observable.lastError
        }
        set {
            observable.lastError = newValue
        }
    }

    public var dataCount: DataCount? {
        get {
            observable.dataCount
        }
        set {
            observable.dataCount = newValue
        }
    }

    init(_ observable: ObservableVPNState) {
        self.observable = observable
    }
}
