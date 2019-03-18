//
//  GroupConstants.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/7/18.
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

class GroupConstants {
    class App {
        static let name = "Passepartout"

        static let tunnelKitName = "TunnelKit"
        
        static let title = name
//        static let title = "\u{1F511}"

        static let versionNumber = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

        static let buildNumber = Int(Bundle.main.infoDictionary![kCFBundleVersionKey as String] as! String)!

        static let versionString = "\(versionNumber) (\(buildNumber))"
        
        static let teamId = "DTDYD63ZX9"

        static let appId = "1433648537"
        
        #if os(iOS)
        static let appGroup = "group.com.algoritmico.Passepartout"
        
        static let tunnelIdentifier = "com.algoritmico.ios.Passepartout.Tunnel"
        #else
        static let appGroup = "\(teamId).group.com.algoritmico.Passepartout"
        
        static let tunnelIdentifier = "com.algoritmico.macos.Passepartout.Tunnel"
        #endif

        private static var containerURL: URL {
            guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
                fatalError("Unable to access App Group container")
            }
            return url
        }

        static let documentsURL: URL = {
            let url = containerURL.appendingPathComponent("Documents", isDirectory: true)
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return url
        }()

        static let cachesURL: URL = {
            let url = containerURL.appendingPathComponent("Library/Caches", isDirectory: true)
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return url
        }()
    }
    
    class VPN {
        static let dnsTimeout = 5000

        static let sessionMarker = "--- EOF ---"
    }
}
