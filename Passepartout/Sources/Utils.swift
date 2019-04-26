//
//  Utils.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/16/18.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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
import SystemConfiguration.CaptiveNetwork
#else
import CoreWLAN
#endif
import SwiftyBeaver

private let log = SwiftyBeaver.self

public class Utils {
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
    
    public static func versionString() -> String {
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
    public static func hasCellularData() -> Bool {
        return true
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

    #if targetEnvironment(simulator)
    public static func currentWifiNetworkName() -> String? {
//        return nil
        return ["FOO", "BAR", "WIFI"].customRandomElement()
    }
    #else
    public static func currentWifiNetworkName() -> String? {
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
    
    public static func regex(_ pattern: String) -> NSRegularExpression {
        return try! NSRegularExpression(pattern: pattern, options: [])
    }
    
    public static func checkConnectivityURL(_ url: URL, timeout: TimeInterval, completionHandler: @escaping (Bool) -> Void) {
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

    public static func localizedCountry(_ code: String) -> String {
        return Locale.current.localizedString(forRegionCode: code) ?? code
    }

    public static func localizedLanguage(_ code: String) -> String {
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? code
    }
    
    private init() {
    }
}

public extension FileManager {
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

public extension Date {
    var timestamp: String {
        return Utils.timestampFormatter.string(from: self)
    }
}

public extension TimeInterval {
    var localized: String {
        guard let str = Utils.componentsFormatter.string(from: self) else {
            fatalError("Could not format a TimeInterval?")
        }
        return str
    }
}

public extension Sequence {
    func stableSorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> [Element] {
        return try enumerated().sorted {
            return try areInIncreasingOrder($0.element, $1.element) ||
                ($0.offset < $1.offset && !areInIncreasingOrder($1.element, $0.element))
            }.map { $0.element }
    }
}

public extension Array {
    func customRandomElement() -> Element {
        let i = Int(arc4random() % UInt32(count))
        return self[i]
    }
}

public extension StringProtocol where Index == String.Index {
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}

public extension CharacterSet {
    static let filename: CharacterSet = {
        var chars: CharacterSet = .decimalDigits
        let english = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let symbols = "-_."
        chars.formUnion(CharacterSet(charactersIn: english))
        chars.formUnion(CharacterSet(charactersIn: english.lowercased()))
        chars.formUnion(CharacterSet(charactersIn: symbols))
        return chars
    }()
}

public extension URL {
    private static let illegalCharacterFallback = "_"
    
    var normalizedFilename: String {
        let filename = deletingPathExtension().lastPathComponent
        return filename.components(separatedBy: CharacterSet.filename.inverted).joined(separator: URL.illegalCharacterFallback)
    }
}

public extension Array where Element: CustomStringConvertible {
    func sortedCaseInsensitive() -> [Element] {
        return sorted { $0.description.lowercased() < $1.description.lowercased() }
    }
}

public extension UITableView {
    func scrollToRowAsync(at indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            self?.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
    }

    func selectRowAsync(at indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            self?.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
        }
    }
}
