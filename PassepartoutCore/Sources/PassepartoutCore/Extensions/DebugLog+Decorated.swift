//
//  DebugLog+Decorated.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/14/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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

#if os(iOS)
import Foundation
import UIKit

extension DebugLog {
    public func decoratedString(_ appName: String, _ appVersion: String) -> String {
        let device: UIDevice = .current
        let osVersion = "\(device.systemName) \(device.systemVersion)"
        let deviceModel = device.model
        let deviceIdiom = device.userInterfaceIdiom

        let metadata = [
            "App: \(appName) \(appVersion)",
            "OS: \(osVersion)",
            "Device: \(deviceModel) (\(deviceIdiom))"
        ]

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
#endif
