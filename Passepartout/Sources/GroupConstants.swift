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

public class GroupConstants {
    public class App {
        public static let name = "Passepartout"

        public static let tunnelKitName = "TunnelKit"
        
        public static let title = name
//        public static let title = "\u{1F511}"

        public static let versionNumber = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

        public static let buildNumber = Int(Bundle.main.infoDictionary![kCFBundleVersionKey as String] as! String)!

        public static let versionString = "\(versionNumber) (\(buildNumber))"
        
        public static let teamId = "DTDYD63ZX9"

        public static let appId = "1433648537"
        
        #if os(iOS)
        public static let appGroup = "group.com.algoritmico.Passepartout"
        
        public static let tunnelIdentifier = "com.algoritmico.ios.Passepartout.Tunnel"
        #else
        public static let appGroup = "\(teamId).group.com.algoritmico.Passepartout"
        
        public static let tunnelIdentifier = "com.algoritmico.macos.Passepartout.Tunnel"
        #endif

        private static var containerURL: URL {
            guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
                print("Unable to access App Group container")
                return FileManager.default.userURL(for: .documentDirectory, appending: nil)
            }
            return url
        }

        public static let documentsURL: URL = {
            let url = containerURL.appendingPathComponent("Documents", isDirectory: true)
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return url
        }()

        public static let cachesURL: URL = {
            let url = containerURL.appendingPathComponent("Library/Caches", isDirectory: true)
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return url
        }()
    }
    
    public class VPN {
        public static let dnsTimeout = 5000

        public static let sessionMarker = "--- EOF ---"

        public static let dataCountInterval = 5000
    }
}
