//
//  Repository.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/10/24.
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

import Combine
import Foundation

public protocol UniqueEntity {
    var uuid: UUID? { get }
}

public struct EntitiesResult<E> where E: UniqueEntity {
    public let entities: [E]

    public let isFiltering: Bool

    public init() {
        self.init([], isFiltering: false)
    }

    public init(_ entities: [E], isFiltering: Bool) {
        self.entities = entities
        self.isFiltering = isFiltering
    }
}

public protocol Repository {
    associatedtype Entity: UniqueEntity

    var entitiesPublisher: AnyPublisher<EntitiesResult<Entity>, Never> { get }

    func filter(byFormat format: String, arguments: [Any]?) async throws

    func resetFilter() async throws

    func saveEntities(_ entities: [Entity]) async throws

    func removeEntities(withIds ids: [UUID]?) async throws
}
