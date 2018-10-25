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

protocol ProfileConfigurationSource {
    var id: String { get }

    var profileDirectory: String { get }
}

extension ProfileConfigurationSource {
    var profileConfigurationPath: String {
        return "\(profileDirectory)/\(id).ovpn"
    }
}

extension ProviderConnectionProfile: ProfileConfigurationSource {
    var profileDirectory: String {
        return AppConstants.Store.providersDirectory
    }
}

extension HostConnectionProfile: ProfileConfigurationSource {
    var profileDirectory: String {
        return AppConstants.Store.hostsDirectory
    }
}

class ProfileConfigurationFactory {
    static let shared = ProfileConfigurationFactory()
    
    private let configurationsPath: URL

    private init() {
        let fm = FileManager.default
        configurationsPath = fm.userURL(for: .documentDirectory, appending: nil)
        try? fm.createDirectory(at: configurationsPath, withIntermediateDirectories: false, attributes: nil)
    }

    func save(url: URL, for profile: ProfileConfigurationSource) throws -> URL {
        let savedUrl = targetConfigurationURL(for: profile)
        try FileManager.default.copyItem(at: url, to: savedUrl)
        return savedUrl
    }
    
    func configurationURL(for profile: ProfileConfigurationSource) -> URL? {
        let url = targetConfigurationURL(for: profile)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        return url
    }

    private func targetConfigurationURL(for profile: ProfileConfigurationSource) -> URL {
        return configurationsPath.appendingPathComponent(profile.profileConfigurationPath)
    }
}
