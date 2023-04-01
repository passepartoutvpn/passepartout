//
//  DebugLog+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/14/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
import UIKit
#else
import AppKit
#endif

extension DebugLog {
    public func decoratedString(_ appName: String, _ appVersion: String) -> String {
        let osVersion: String
        let deviceType: String?

        #if os(iOS)
        let device: UIDevice = .current
        osVersion = "\(device.systemName) \(device.systemVersion)"
        #if targetEnvironment(macCatalyst)
        deviceType = "\(device.model) (Catalyst)"
        #else
        deviceType = "\(device.model) (\(device.userInterfaceIdiom.debugDescription))"
        #endif
        #else
        let os = ProcessInfo().operatingSystemVersion
        osVersion = "macOS \(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
        deviceType = nil
        #endif

        var metadata = [
            "App: \(appName) \(appVersion)",
            "OS: \(osVersion)"
        ]
        if let deviceType = deviceType {
            metadata.append("Device: \(deviceType)")
        }

        var fullText = metadata.joined(separator: "\n")
        fullText += "\n\n"
        fullText += content
        return fullText
    }

    public func decoratedData(_ appName: String, _ appVersion: String) -> Data {
        guard let data = decoratedString(appName, appVersion).data(using: .utf8) else {
            assertionFailure("Could not encode log metadata to UTF8?")
            return Data()
        }
        return data
    }
}

#if canImport(UIKit)
private extension UIUserInterfaceIdiom {
    var debugDescription: String {
        switch self {
        case .phone:
            return "Phone"

        case .pad:
            return "Pad"

        case .mac:
            return "Mac"

        default:
            return "Other"
        }
    }
}
#endif
