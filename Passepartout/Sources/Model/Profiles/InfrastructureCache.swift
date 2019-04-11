//
//  InfrastructureCache.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/11/19.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
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

// TODO: retain max N pool models at a time (LRU)

public class InfrastructureCache {
    public static let shared = InfrastructureCache()
    
    private var poolModelsByName: [Infrastructure.Name: [PoolModel]]
    
    private init() {
        poolModelsByName = [:]
    }
    
    public func poolModels(for provider: ProviderConnectionProfile) -> [PoolModel] {
        if let models = poolModelsByName[provider.name] {
            return models
        }
        let freeModel = PoolModel(isFree: true)
        let paidModel = PoolModel(isFree: false)
        for p in provider.infrastructure.pools {
            if p.isFree ?? false {
                freeModel.addPool(p)
            } else {
                paidModel.addPool(p)
            }
//            if p.id == currentPoolId {
//                currentPool = p
//            }
        }
        freeModel.sort()
        paidModel.sort()
        
        var models: [PoolModel] = []
        if !freeModel.isEmpty {
            models.append(freeModel)
        }
        if !paidModel.isEmpty {
            models.append(paidModel)
        }
        poolModelsByName[provider.name] = models
        return models
    }
    
    public func removePoolModels(for name: Infrastructure.Name? = nil) {
        if let name = name {
            poolModelsByName.removeValue(forKey: name)
            return
        }
        poolModelsByName.removeAll()
    }
}
