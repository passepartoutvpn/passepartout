//
//  Utils+Network.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/26/22.
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
#if os(iOS)
import NetworkExtension
#elseif os(macOS)
import CoreWLAN
#endif

extension Utils {
#if targetEnvironment(simulator)
    public static func hasCellularData() -> Bool {
        true
    }
#else
    public static func hasCellularData() -> Bool {
        var addrs: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addrs) == 0 else {
            return false
        }
        var isFound = false
        var cursor = addrs?.pointee
        while let ifa = cursor {
            let name = String(cString: ifa.ifa_name)
            if name == "pdp_ip0" {
                isFound = true
                break
            }
            cursor = ifa.ifa_next?.pointee
        }
        freeifaddrs(addrs)
        return isFound
    }
#endif

    public static func hasEthernet() -> Bool {
#if os(macOS)
        true
#else
        false
#endif
    }

    public static func currentWifiSSID() async -> String? {
#if targetEnvironment(simulator)
        ["My Home Network", "Safe Wi-Fi", "Friend's House"].randomElement()
#elseif os(iOS)
        await withCheckedContinuation { continuation in
            NEHotspotNetwork.fetchCurrent {
                guard let network = $0 else {
                    continuation.resume(with: .success(nil))
                    return
                }
                continuation.resume(with: .success(network.ssid))
            }
        }
#elseif os(macOS)
        CWWiFiClient.shared().interface()?.ssid()
#else
        nil
#endif
    }
}

extension Utils {
    public static func string(fromIPv4 ipv4: UInt32) -> String {
        var remainder = ipv4
        var groups: [UInt32] = []
        var base: UInt32 = 1 << 24
        while base > 0 {
            groups.append(remainder / base)
            remainder %= base
            base >>= 8
        }
        return groups
            .map { $0.description }
            .joined(separator: ".")
    }

    public static func ipv4(fromString string: String) -> UInt32? {
        var addr = in_addr()
        let result = string.withCString {
            inet_pton(AF_INET, $0, &addr)
        }
        guard result > 0 else {
            return nil
        }
        return CFSwapInt32BigToHost(addr.s_addr)
    }
}
