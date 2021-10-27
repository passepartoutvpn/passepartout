//
//  Infrastructure+External.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/4/21.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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
import PassepartoutConstants
import DTFoundation

extension InfrastructureName {
    public var externalURL: URL {
        return GroupConstants.App.externalURL.appendingPathComponent(self)
    }

    public func importExternalResources(from url: URL, completionHandler: @escaping () -> Void) {
        var task: () -> Void
        switch self {
        case .nordvpn:
            task = {
                let archive = DTZipArchive(atPath: url.path)
                archive?.uncompress(toPath: self.externalURL.path, completion: nil)
            }
            
        default:
            task = {}
        }
        execute(task: task, completionHandler: completionHandler)
    }

    private func execute(task: @escaping () -> Void, completionHandler: @escaping () -> Void) {
        let queue: DispatchQueue = .global(qos: .background)
        queue.async {
            task()
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
}
