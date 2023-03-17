//
//  InfrastructureMapper.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/14/22.
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
import CoreData
import PassepartoutCore
import PassepartoutServices
import PassepartoutUtils

struct InfrastructureMapper: DTOMapper {
    private let context: NSManagedObjectContext

    private let providerName: ProviderName

    private let vpnProtocol: VPNProtocolType

    init(_ context: NSManagedObjectContext, _ providerName: ProviderName, _ vpnProtocol: VPNProtocolType) {
        self.context = context
        self.providerName = providerName
        self.vpnProtocol = vpnProtocol
    }

    func toDTO(_ ws: WSProviderInfrastructure) -> CDInfrastructure {
        let infrastructure = CDInfrastructure(context: context)
        infrastructure.vpnProtocol = vpnProtocol.rawValue

        let defaults = DefaultSettingsMapper(context).toDTO(ws.defaults)
        infrastructure.defaults = defaults
        defaults.infrastructure = infrastructure

        let presets = ws.presets.compactMap(PresetMapper(context).toDTO)

        let categories = ws.categories.compactMap(CategoryMapper(context, vpnProtocol).toDTO)
        infrastructure.addToCategories(Set(categories) as NSSet)

        var categoryByName: [String: CDInfrastructureCategory] = [:]
        categories.forEach { category in
            category.infrastructure = infrastructure
            categoryByName[category.name!] = category
        }

        ws.categories.forEach { categoryWS in
            var presetsDTO: [CDInfrastructurePreset]?
            if let wsPresets = categoryWS.supportedPresetIds {
                presetsDTO = presets.filter {
                    guard let presetId = $0.id else {
                        assertionFailure("Preset in category '\(categoryWS.name)' supported presets has no id")
                        return false
                    }
                    return wsPresets.contains(presetId)
                }
            } else {
                presetsDTO = presets
            }
            guard let category = categoryByName[categoryWS.name] else {
                assertionFailure("Cannot find CDInfrastructureCategory with name '\(categoryWS.name)' in map")
                return
            }
            presetsDTO.map {
                category.addToPresets(Set($0) as NSSet)
                $0.forEach { presetDTO in
                    presetDTO.addToCategory(category)
                }
            }
        }

        // do this at the very end, when all entities have their parent chain set
        categories.forEach {
            $0.servers?.forEach {
                guard let server = $0 as? CDInfrastructureServer else {
                    return
                }
                guard let apiId = server.apiId else {
                    return
                }
                guard let uniqueId = ProviderServer.id(
                    withName: providerName,
                    vpnProtocol: vpnProtocol,
                    apiId: apiId
                ) else {
                    Utils.assertCoreDataDecodingFailed(#file, #function, #line)
                    return
                }
                server.uniqueId = uniqueId
            }
        }

        return infrastructure
    }
}
