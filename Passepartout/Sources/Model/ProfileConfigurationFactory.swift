//
//  ProfileConfigurationFactory.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/22/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
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

class ProfileConfigurationFactory {
    static let shared = ProfileConfigurationFactory(withDirectory: AppConstants.Store.profileConfigurationsDirectory)
    
    private let cachePath: URL
    
    private let configurationsPath: URL

    private init(withDirectory directory: String) {
        let fm = FileManager.default
        cachePath = fm.userURL(for: .cachesDirectory, appending: directory)
        configurationsPath = fm.userURL(for: .documentDirectory, appending: directory)
        try? fm.createDirectory(at: cachePath, withIntermediateDirectories: false, attributes: nil)
        try? fm.createDirectory(at: configurationsPath, withIntermediateDirectories: false, attributes: nil)
    }

    func save(url: URL, for profile: ConnectionProfile) throws -> URL {
        let savedUrl = configurationURL(for: profile)
        try FileManager.default.copyItem(at: url, to: savedUrl)
        return savedUrl
    }
    
    func configurationURL(for profile: ConnectionProfile) -> URL {
        let filename = "\(profile.id).ovpn"
        return configurationsPath.appendingPathComponent(filename)
    }
}
