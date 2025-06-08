//
//  RegistryCoder+ProfileImporter.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/5/25.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

extension RegistryCoder: ProfileImporter {
    public func profile(from input: ProfileImporterInput, passphrase: String?) throws -> Profile {
        let name: String
        let contents: String
        switch input {
        case .contents(let filename, let data):
            name = filename
            contents = data
        case .file(let url):
            var encoding: String.Encoding = .utf8
            // TODO: ###, this may be very inefficient
            contents = try String(contentsOf: url, usedEncoding: &encoding)
            name = url.lastPathComponent
        }

        // try to decode a full Partout profile first
        do {
            return try profile(from: contents)
        } catch {
            pp_log_g(.app, .debug, "Unable to decode profile for import: \(error)")
        }

        // fall back to parsing a single module
        let importedModule = try module(from: contents, object: passphrase)
        return try registry.profile(withName: name, importedModule: importedModule)
    }
}
