//
//  Utils.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/16/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
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
import SystemConfiguration.CaptiveNetwork
#else
import CoreWLAN
#endif
import SwiftyBeaver

private let log = SwiftyBeaver.self

class Utils {
    fileprivate static let timestampFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .medium
        return fmt
    }()
    
    fileprivate static let componentsFormatter: DateComponentsFormatter = {
        let fmt = DateComponentsFormatter()
        fmt.unitsStyle = .full
        return fmt
    }()
    
    static func versionString() -> String {
        let info = Bundle.main.infoDictionary
        guard let version = info?["CFBundleShortVersionString"] else {
            fatalError("No bundle version?")
        }
        guard let build = info?["CFBundleVersion"] else {
            fatalError("No bundle build number?")
        }
        return "\(version) (\(build))"
    }
    
    #if targetEnvironment(simulator)
    static func hasCellularData() -> Bool {
        return true
    }
    #else
    static func hasCellularData() -> Bool {
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

    #if targetEnvironment(simulator)
    static func currentWifiNetworkName() -> String? {
//        return nil
        return ["FOO", "BAR", "WIFI"].customRandomElement()
    }
    #else
    static func currentWifiNetworkName() -> String? {
        #if os(iOS)
        guard let interfaceNames = CNCopySupportedInterfaces() as? [CFString] else {
            return nil
        }
        for name in interfaceNames {
            guard let iface = CNCopyCurrentNetworkInfo(name) as? [String: Any] else {
                continue
            }
            if let ssid = iface["SSID"] as? String {
                return ssid
            }
        }
        return nil
        #else
        return CWWiFiClient.shared().interface()?.ssid()
        #endif
    }
    #endif
    
    static func regex(_ pattern: String) -> NSRegularExpression {
        return try! NSRegularExpression(pattern: pattern, options: [])
    }
    
    static func checkConnectivityURL(_ url: URL, timeout: TimeInterval, completionHandler: @escaping (Bool) -> Void) {
        let session = URLSession(configuration: .ephemeral)
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeout)

        log.info("Check connectivity via \(url)")
        session.dataTask(with: request) { (_, response, error) in
            if let response = response as? HTTPURLResponse {
                log.debug("Response code: \(response.statusCode)")
            }
            if let error = error {
                log.error("Connectivity failed: \(error)")
            } else {
                log.info("Connectivity succeeded!")
            }
            DispatchQueue.main.async {
                completionHandler(error == nil)
            }
        }.resume()
    }

    private init() {
    }
}

extension FileManager {
    func userURL(for searchPath: SearchPathDirectory, appending: String?) -> URL {
        let paths = urls(for: .documentDirectory, in: .userDomainMask)
        var directory = paths[0]
        if let appending = appending {
            directory.appendPathComponent(appending)
        }
        return directory
    }

    func modificationDate(of path: String) -> Date? {
        guard let attrs = try? attributesOfItem(atPath: path) else {
            return nil
        }
        return attrs[.modificationDate] as? Date
    }
}

extension Date {
    var timestamp: String {
        return Utils.timestampFormatter.string(from: self)
    }
}

extension TimeInterval {
    var localized: String {
        guard let str = Utils.componentsFormatter.string(from: self) else {
            fatalError("Could not format a TimeInterval?")
        }
        return str
    }
}

extension Sequence {
    func stableSorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> [Element] {
        return try enumerated().sorted {
            return try areInIncreasingOrder($0.element, $1.element) ||
                ($0.offset < $1.offset && !areInIncreasingOrder($1.element, $0.element))
            }.map { $0.element }
    }
}

extension Array {
    func customRandomElement() -> Element {
        let i = Int(arc4random() % UInt32(count))
        return self[i]
    }
}

extension StringProtocol where Index == String.Index {
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}
