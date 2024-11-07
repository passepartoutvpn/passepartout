//
//  ProfileAttributes.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/3/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

import CommonUtils
import Foundation
import PassepartoutKit

public struct ProfileAttributes: Hashable, Codable {
    public var fingerprint: UUID?

    public var lastUpdate: Date?

    public var isAvailableForTV: Bool?

    public var expirationDate: Date?

    public init() {
    }

    public init(
        fingerprint: UUID?,
        lastUpdate: Date?,
        isAvailableForTV: Bool?,
        expirationDate: Date?
    ) {
        self.fingerprint = fingerprint
        self.lastUpdate = lastUpdate
        self.isAvailableForTV = isAvailableForTV
        self.expirationDate = expirationDate
    }
}

extension ProfileAttributes: CustomDebugStringConvertible {
    public var debugDescription: String {
        let descs = [
            fingerprint.map {
                "fingerprint: \($0)"
            },
            lastUpdate.map {
                "lastUpdate: \($0)"
            },
            isAvailableForTV.map {
                "isAvailableForTV: \($0)"
            },
            expirationDate.map {
                "expirationDate: \($0)"
            }
        ].compactMap { $0 }

        return "{\(descs.joined(separator: ", "))}"
    }
}

extension ProfileAttributes {
    public var isExpired: Bool {
        if let expirationDate {
            return Date().distance(to: expirationDate) <= .zero
        }
        return false
    }
}

// MARK: - ProfileUserInfoTransformable

// FIXME: #570, test user info encoding/decoding with JSONSerialization
extension ProfileAttributes: ProfileUserInfoTransformable {
    public var userInfo: [String: AnyHashable]? {
        do {
            let data = try JSONEncoder().encode(self)
            return try JSONSerialization.jsonObject(with: data) as? [String: AnyHashable] ?? [:]
        } catch {
            pp_log(.App.profiles, .error, "Unable to encode ProfileAttributes to dictionary: \(error)")
            return [:]
        }
    }

    public init?(userInfo: [String: AnyHashable]?) {
        do {
            let data = try JSONSerialization.data(withJSONObject: userInfo ?? [:])
            self = try JSONDecoder().decode(ProfileAttributes.self, from: data)
        } catch {
            pp_log(.App.profiles, .error, "Unable to decode ProfileAttributes from dictionary: \(error)")
            return nil
        }
    }
}

extension Profile {
    public var attributes: ProfileAttributes {
        userInfo() ?? ProfileAttributes()
    }
}

extension Profile.Builder {
    public var attributes: ProfileAttributes {
        get {
            userInfo() ?? ProfileAttributes()
        }
        set {
            setUserInfo(newValue)
        }
    }
}
