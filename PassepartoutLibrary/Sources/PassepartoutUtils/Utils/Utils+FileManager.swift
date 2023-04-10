//
//  Utils+FileManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/12/19.
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

extension FileManager {
    public func userURL(for searchPath: SearchPathDirectory, appending: String?) -> URL {
        let paths = urls(for: searchPath, in: .userDomainMask)
        var directory = paths[0]
        if let appending = appending {
            directory.appendPathComponent(appending)
        }
        return directory
    }

//    public func creationDate(of path: String) -> Date? {
//        guard let attrs = try? attributesOfItem(atPath: path) else {
//            return nil
//        }
//        return attrs[.creationDate] as? Date
//    }
//
//    public func modificationDate(of path: String) -> Date? {
//        guard let attrs = try? attributesOfItem(atPath: path) else {
//            return nil
//        }
//        return attrs[.modificationDate] as? Date
//    }
}
