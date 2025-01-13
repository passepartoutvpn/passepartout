//
//  Demo+VPN.swift
//  PassepartoutKit
//
//  Created by Davide De Rosa on 3/16/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of PassepartoutKit.
//
//  PassepartoutKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  PassepartoutKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with PassepartoutKit.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import PassepartoutKit
import PassepartoutOpenVPNOpenSSL

extension OpenVPN {
    static var demoModule: OpenVPNModule {
        do {
            let parser = StandardOpenVPNParser()
            let result = try parser.parsed(fromURL: Constants.demoURL)
            let builder = result.configuration.builder()
            var module = OpenVPNModule.Builder(configurationBuilder: builder)
            module.credentials = Constants.demoCredentials
            return try module.tryBuild()
        } catch {
            fatalError("Unable to build: \(error)")
        }
    }
}

private enum Constants {
    static let demoURL = Bundle.main.url(forResource: "Files/test-protonvpn", withExtension: "ovpn")!

    static let demoCredentials: OpenVPN.Credentials = {

        var builder = OpenVPN.Credentials.Builder()
        if let url = Bundle.main.url(forResource: "Files/test-protonvpn", withExtension: "txt"),
           let content = try? String(contentsOf: url, encoding: .utf8) {
            let lines = content.split(separator: "\n")
            if lines.count == 2 {
                builder.username = String(lines[0])
                builder.password = String(lines[1])
            }
        }
        return builder.build()
    }()
}
