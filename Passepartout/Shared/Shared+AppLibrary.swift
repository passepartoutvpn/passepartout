//
//  Shared+AppLibrary.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/26/24.
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

import AppData
import AppDataProfiles
import AppLibrary
import CoreData
import Foundation
import PassepartoutKit
import UtilsLibrary

extension ProfileManager {
    static let shared: ProfileManager = {
        let repository = localProfileRepository

        let remoteStore = CoreDataPersistentStore(
            logger: .default,
            containerName: BundleConfiguration.mainString(for: .remoteProfilesContainerName),
            model: coreDataModel,
            cloudKitIdentifier: BundleConfiguration.mainString(for: .cloudKitId),
            author: nil
        )
        let remoteRepository = AppData.cdProfileRepositoryV3(
            registry: .shared,
            coder: CodableProfileCoder(),
            context: remoteStore.context,
            observingResults: true
        ) { error in
            pp_log(.app, .error, "Unable to decode remote result: \(error)")
            return .ignore
        }

        return ProfileManager(repository: repository, remoteRepository: remoteRepository)
    }()
}

private var coreDataModel: NSManagedObjectModel {
    AppData.cdProfilesModel
}

#if targetEnvironment(simulator)

extension Tunnel {
    static let shared = Tunnel(
        strategy: FakeTunnelStrategy(environment: .shared, dataCountInterval: 1000)
    )
}

private var localProfileRepository: any ProfileRepository {
    let store = CoreDataPersistentStore(
        logger: .default,
        containerName: BundleConfiguration.mainString(for: .profilesContainerName),
        model: coreDataModel,
        cloudKitIdentifier: nil,
        author: nil
    )
    return AppData.cdProfileRepositoryV3(
        registry: .shared,
        coder: CodableProfileCoder(),
        context: store.context,
        observingResults: false
    ) { error in
        pp_log(.app, .error, "Unable to decode local result: \(error)")
        return .ignore
    }
}

#else

extension Tunnel {
    static let shared = Tunnel(
        strategy: NETunnelStrategy(repository: neRepository)
    )
}

private var localProfileRepository: any ProfileRepository {
    NEProfileRepository(repository: neRepository)
}

private var neRepository: NETunnelManagerRepository {
    NETunnelManagerRepository(
        bundleIdentifier: BundleConfiguration.mainString(for: .tunnelId),
        coder: Registry.sharedProtocolCoder,
        environment: .shared
    )
}

#endif
