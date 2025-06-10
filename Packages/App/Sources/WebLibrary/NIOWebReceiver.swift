//
//  NIOWebReceiver.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/3/25.
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
import Foundation
import NIO
import NIOHTTP1

public final class NIOWebReceiver: WebReceiver, @unchecked Sendable {
    private let port: Int

    private var channel: Channel?

    private var group: EventLoopGroup?

    public init(port: Int) {
        self.port = port
    }

    public func start(passcode: String?, onReceive: @escaping (String, String) -> Void) throws -> URL {
        guard channel == nil else {
            pp_log_g(.App.web, .error, "Web server is already started")
            throw AppError.webReceiver()
        }
        guard let host = firstIPv4Address(withInterfacePrefix: "en") else {
            pp_log_g(.App.web, .error, "Web server has no IPv4 Ethernet addresses to listen on")
            throw AppError.webReceiver()
        }
        do {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            let bootstrap = ServerBootstrap(group: group)
                .serverChannelOption(.backlog, value: 256)
                .serverChannelOption(.socketOption(.so_reuseaddr), value: 1)
                .childChannelInitializer { channel in
                    channel.pipeline.configureHTTPServerPipeline().flatMap {
                        channel.pipeline.addHandler(NIOWebReceiverHandler(passcode: passcode) {
                            onReceive($0, $1)
                        })
                    }
                }
                .childChannelOption(.socketOption(.so_reuseaddr), value: 1)

            channel = try bootstrap.bind(host: host, port: port).wait()
            self.group = group
        } catch {
            pp_log_g(.App.web, .error, "Web server could not bind: \(error)")
            throw AppError.webReceiver(error)
        }
        guard let address = channel?.localAddress?.ipAddress else {
            pp_log_g(.App.web, .error, "Web server has no bound IP address")
            throw AppError.webReceiver()
        }
        guard let url = URL(string: "http://\(address):\(port)") else {
            pp_log_g(.App.web, .error, "Web server URL could not be built")
            throw AppError.webReceiver()
        }
        pp_log_g(.App.web, .notice, "Web server did start: \(url)")
        return url
    }

    public func stop() {
        guard let channel else {
            pp_log_g(.App.web, .error, "Web server is not started")
            return
        }
        defer {
            self.channel = nil
            self.group = nil
        }
        do {
            try channel.close().wait()
            try group?.syncShutdownGracefully()
            pp_log_g(.App.web, .notice, "Web server did stop")
        } catch {
            pp_log_g(.App.web, .error, "Unable to stop web server: \(error)")
        }
    }
}

private extension NIOWebReceiver {
    func firstIPv4Address(withInterfacePrefix prefix: String) -> String? {
        var firstAddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&firstAddr) == 0, let firstAddr else {
            return nil
        }

        var ipAddress: String?
        var ptr = firstAddr

        while let cIfName = ptr.pointee.ifa_name {
            let addr = ptr.pointee.ifa_addr.pointee
            let flags = ptr.pointee.ifa_flags

            let isIPv4 = addr.sa_family == UInt8(AF_INET)
            let isUp = (flags & UInt32(IFF_UP)) != 0
            let isLoopback = (flags & UInt32(IFF_LOOPBACK)) != 0
            let ifName = String(cString: cIfName)

            if isIPv4, !isLoopback, isUp, ifName.hasPrefix(prefix) {
                var addrCopy = ptr.pointee.ifa_addr.pointee
                var cIPAddress = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(
                    &addrCopy,
                    socklen_t(ptr.pointee.ifa_addr.pointee.sa_len),
                    &cIPAddress,
                    socklen_t(cIPAddress.count),
                    nil,
                    0,
                    NI_NUMERICHOST
                )
                ipAddress = String(cString: cIPAddress)
                guard let ipAddress, !ipAddress.starts(with: "169.254") else {
                    continue
                }
                // success
                break
            }

            // leave if no more addresses
            guard let next = ptr.pointee.ifa_next else {
                break
            }
            ptr = next
        }

        freeifaddrs(firstAddr)
        return ipAddress
    }
}
