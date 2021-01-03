//
//  DebugLog.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/26/18.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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
import Cocoa
#endif

public struct DebugLog {
    private let raw: String

    public init(raw: String) {
        self.raw = raw
    }

    public func string() -> String {
        return raw
    }
    
    public func data() -> Data? {
        return raw.data(using: .utf8)
    }

    public func decoratedString() -> String {
        let appName = GroupConstants.App.name
        let appVersion = GroupConstants.App.versionString

        var metadata: [String] = []
        let osVersion: String
        let deviceType: String?

        #if os(iOS)
        let device = UIDevice.current
        osVersion = "\(device.systemName) \(device.systemVersion)"
        deviceType = device.model
        #else
        let os = ProcessInfo().operatingSystemVersion
        osVersion = "macOS \(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
        deviceType = nil
        #endif

        metadata.append("App: \(appName) \(appVersion)")
        metadata.append("OS: \(osVersion)")
        if let deviceType = deviceType {
            metadata.append("Device: \(deviceType)")
        }

        var fullText = metadata.joined(separator: "\n")
        fullText += "\n\n"
        fullText += raw
        return fullText
    }
    
    public func decoratedData() -> Data {
        guard let data = decoratedString().data(using: .utf8) else {
            fatalError("Could not encode log metadata to UTF8?")
        }
        return data
    }
}
