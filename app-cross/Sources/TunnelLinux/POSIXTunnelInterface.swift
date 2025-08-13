// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation
import Partout
import Tunnel_C
import TunnelLinux_C

public final class POSIXTunnelInterface: TunnelInterface {
    private let fd: Int

    public init() {
        self.fd = 0//tunnel_create()
    }

    deinit {
        //tunnel_free(fd)
    }

    public func readPackets() async throws -> [Data] {
        // read from TUN fd
        fatalError()
    }

    public func writePackets(_ packets: [Data]) async throws {
        // write to TUN fd
        fatalError()
    }
}
