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

import Foundation
import PassepartoutKit

// WARNING: upcast to [String: AnyHashable] relies on CodableProfileCoder
// implementation returning JSONSerialization

extension ProfileType where UserInfoType == AnyHashable {
    public var attributes: ProfileAttributes {
        ProfileAttributes(userInfo: userInfo as? [String: AnyHashable])
    }
}

extension MutableProfileType where UserInfoType == AnyHashable {
    public var attributes: ProfileAttributes {
        get {
            ProfileAttributes(userInfo: userInfo as? [String: AnyHashable])
        }
        set {
            userInfo = newValue.userInfo
        }
    }
}

// MARK: - ProfileAttributes

public struct ProfileAttributes {
    fileprivate enum Key: String {
        case fingerprint

        case lastUpdate

        case isAvailableForTV

        case preferences
    }

    private(set) var userInfo: [String: AnyHashable]

    init(userInfo: [String: AnyHashable]?) {
        self.userInfo = userInfo ?? [:]
    }
}

// MARK: Basic

extension ProfileAttributes {
    public var fingerprint: UUID? {
        get {
            guard let string = userInfo[Key.fingerprint.rawValue] as? String else {
                return nil
            }
            return UUID(uuidString: string)
        }
        set {
            userInfo[Key.fingerprint.rawValue] = newValue?.uuidString
        }
    }

    public var lastUpdate: Date? {
        get {
            guard let interval = userInfo[Key.lastUpdate.rawValue] as? TimeInterval else {
                return nil
            }
            return Date(timeIntervalSinceReferenceDate: interval)
        }
        set {
            userInfo[Key.lastUpdate.rawValue] = newValue?.timeIntervalSinceReferenceDate
        }
    }

    public var isAvailableForTV: Bool? {
        get {
            userInfo[Key.isAvailableForTV.rawValue] as? Bool
        }
        set {
            userInfo[Key.isAvailableForTV.rawValue] = newValue
        }
    }
}

// MARK: Preferences

extension ProfileAttributes {
    public func preferences(inModule moduleId: UUID) -> ModulePreferences {
        ModulePreferences(userInfo: allPreferences[moduleId.uuidString] as? [String: AnyHashable])
    }

    public mutating func setPreferences(_ module: ModulePreferences, inModule moduleId: UUID) {
        allPreferences[moduleId.uuidString] = module.userInfo
    }

    public func preference<T>(inModule moduleId: UUID, block: (ModulePreferences) -> T) -> T? {
        let module = preferences(inModule: moduleId)
        return block(module)
    }

    public mutating func editPreferences(inModule moduleId: UUID, block: (inout ModulePreferences) -> Void) {
        var module = preferences(inModule: moduleId)
        block(&module)
        setPreferences(module, inModule: moduleId)
    }
}

private extension ProfileAttributes {
    var allPreferences: [String: AnyHashable] {
        get {
            userInfo[Key.preferences.rawValue] as? [String: AnyHashable] ?? [:]
        }
        set {
            userInfo[Key.preferences.rawValue] = newValue
        }
    }
}

// MARK: -

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
            "allPreferences: \(allPreferences)"
        ].compactMap { $0 }

        return "{\(descs.joined(separator: ", "))}"
    }
}
