//
//  StandardWireGuardParser.swift
//  Partout
//
//  Created by Davide De Rosa on 4/17/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Partout.
//
//  Partout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Partout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Partout.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Partout
internal import WireGuardKit

/// Parses WireGuard configurations in `wg-quick` format.
public final class StandardWireGuardParser {
    public init() {
    }
}

// MARK: - ConfigurationCoder

extension StandardWireGuardParser: ConfigurationCoder {
    public func configuration(from string: String) throws -> WireGuard.Configuration {
        try WireGuard.Configuration(wgQuickConfig: string)
    }

    public func string(from configuration: WireGuard.Configuration) throws -> String {
        try configuration.toWgQuickConfig()
    }
}

// MARK: - ModuleImporter

extension StandardWireGuardParser: ModuleImporter {
    public func module(fromContents contents: String, object: Any?) throws -> Module {
        do {
            let cfg = try configuration(from: contents)
            let builder = WireGuardModule.Builder(configurationBuilder: cfg.builder())
            return try builder.tryBuild()
        } catch TunnelConfiguration.ParseError.invalidLine {
            throw PartoutError(.unknownImportedModule)
        } catch {
            throw PartoutError(.parsing, error)
        }
    }
}
