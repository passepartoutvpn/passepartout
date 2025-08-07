// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import Foundation

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
