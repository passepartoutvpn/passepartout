//
//  Utils+TestFlight.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/18/22.
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

// https://stackoverflow.com/a/32238344/784615
// https://gist.github.com/lukaskubanek/cbfcab29c0c93e0e9e0a16ab09586996

extension Bundle {
    public var isTestFlight: Bool {
        #if targetEnvironment(simulator)
        true
        #elseif targetEnvironment(macCatalyst) || os(macOS)
        var status = noErr

        var code: SecStaticCode?
        status = SecStaticCodeCreateWithPath(bundleURL as CFURL, [], &code)
        guard status == noErr else {
            return false
        }
        guard let code = code else {
            return false
        }

        var requirement: SecRequirement?
        status = SecRequirementCreateWithString(
            "anchor apple generic and certificate leaf[field.1.2.840.113635.100.6.1.25.1]" as CFString,
            [], // default
            &requirement
        )
        guard status == noErr else {
            return false
        }
        guard let requirement = requirement else {
            return false
        }

        status = SecStaticCodeCheckValidity(
            code,
            [], // default
            requirement
        )
        return status == errSecSuccess
        #elseif os(iOS)
        appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        #else
        false
        #endif
    }
}
