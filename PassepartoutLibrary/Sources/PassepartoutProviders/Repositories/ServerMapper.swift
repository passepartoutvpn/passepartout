//
//  ServerMapper.swift
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

struct ServerMapper: DTOMapper, ModelMapper {
    private let context: NSManagedObjectContext

    init(_ context: NSManagedObjectContext) {
        self.context = context
    }

    func toDTO(_ ws: WSProviderServer) -> CDInfrastructureServer {
        let server = CDInfrastructureServer(context: context)

        server.apiId = ws.id
        server.countryCode = ws.countryCode
        server.extraCountryCodes = ws.encodedExtraCountryCodes
        server.area = ws.area
        if let serverIndex = ws.serverIndex {
            server.serverIndex = Int16(serverIndex)
        } else {
            server.serverIndex = 0
        }
        server.tags = ws.encodedTags

        server.hostname = ws.hostname
        if let addrs = ws.numericAddresses {
            server.ipAddresses = ws.encodedIPAddresses

            // strip hostname if found in IP addresses
            if let hostname = server.hostname, let numericHostname = Utils.ipv4(fromString: hostname), addrs.contains(numericHostname) {
                server.hostname = nil
            }
        }

        return server
    }

    static func toModel(_ dto: CDInfrastructureServer) -> ProviderServer? {
        guard let uniqueId = dto.uniqueId,
              let apiId = dto.apiId,
              let categoryDTO = dto.category,
              let categoryName = categoryDTO.name,
              let infrastructureDTO = categoryDTO.infrastructure,
              let providerDTO = infrastructureDTO.provider,
              let providerMetadata = ProviderMapper.toModel(providerDTO),
              let countryCode = dto.countryCode else {

            Utils.assertCoreDataDecodingFailed(#file, #function, #line)
            return nil
        }
        guard let presetDTOs = categoryDTO.presets?.allObjects as? [CDInfrastructurePreset], !presetDTOs.isEmpty else {
            Utils.assertCoreDataDecodingFailed(
                #file, #function, #line,
                "Category '\(categoryName)' of server \(apiId) has no presets"
            )
            return nil
        }

        let supportedPresetIds = presetDTOs
            .sorted()
            .compactMap(\.id)

        return ProviderServer(
            providerMetadata: providerMetadata,
            id: uniqueId,
            apiId: apiId,
            categoryName: categoryName,
            countryCode: countryCode,
            extraCountryCodes: dto.decodedExtraCountryCodes,
            localizedName: dto.localizedName,
            serverIndex: dto.serverIndex != 0 ? Int(dto.serverIndex) : nil,
            tags: dto.decodedTags,
            hostname: dto.hostname,
            ipAddresses: dto.decodedIPAddresses,
            presetIds: supportedPresetIds
        )
    }

    static func toModelWithPresets(_ dto: CDInfrastructureServer) -> ProviderServer? {
        guard let server = toModel(dto),
              let categoryDTO = dto.category,
              let categoryName = categoryDTO.name else {

            Utils.assertCoreDataDecodingFailed(#file, #function, #line)
            return nil
        }
        guard let presetDTOs = dto.category?.presets?.allObjects as? [CDInfrastructurePreset], !presetDTOs.isEmpty else {
            Utils.assertCoreDataDecodingFailed(
                #file, #function, #line,
                "Category '\(categoryName)' has no presets"
            )
            return nil
        }

        let presets = presetDTOs
            .sorted()
            .compactMap(PresetMapper.toModel)

        return server.withPresets(presets)
    }
}

private extension WSProviderServer {
    var encodedExtraCountryCodes: String? {
        extraCountryCodes?.joined(separator: ",")
    }

    var encodedTags: String? {
        tags?.joined(separator: ",")
    }

    var encodedIPAddresses: String? {
        guard let addrs = numericAddresses, !addrs.isEmpty else {
            return nil
        }
        return numericAddresses?
            .map(Utils.string(fromIPv4:))
            .joined(separator: ",")
    }
}

private extension CDInfrastructureServer {
    var decodedExtraCountryCodes: [String]? {
        extraCountryCodes?.components(separatedBy: ",")
    }

    var decodedTags: [String]? {
        tags?.components(separatedBy: ",")
    }

    var decodedIPAddresses: [String] {
        ipAddresses?.components(separatedBy: ",") ?? []
    }
}

private extension CDInfrastructureServer {
    var localizedName: String? {
        var comps: [String] = []
        if let extraCountryCodes = decodedExtraCountryCodes {
            comps.append(contentsOf: extraCountryCodes.map {
                $0.localizedAsCountryCode
            })
        }
        if let area = area {
            comps.append(area.capitalized)
        }
        guard !comps.isEmpty else {
            return nil
        }
        return comps.joined(separator: " ")
    }
}

extension CDInfrastructurePreset: Comparable {
    public static func < (lhs: CDInfrastructurePreset, rhs: CDInfrastructurePreset) -> Bool {
        guard let lname = lhs.name, let rname = rhs.name else {
            fatalError("CDPreset has no name?")
        }
        return lname.lowercased() < rname.lowercased()
    }
}
