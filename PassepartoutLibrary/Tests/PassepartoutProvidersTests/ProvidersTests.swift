//
//  ProvidersTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/13/22.
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

import XCTest
import CoreData
import Combine
import PassepartoutCore
@testable import PassepartoutProviders
import PassepartoutServices
import PassepartoutUtils
import SwiftyBeaver

class ProvidersTests: XCTestCase {
    private static let persistence: Persistence = {
        let model = NSManagedObjectModel.mergedModel(from: [.module])!
        return Persistence(withLocalName: "ProvidersTests", model: model, author: nil)
    }()

    private var manager: ProviderManager!

    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        pp_log.addDestination(ConsoleDestination())

        manager = ProviderManager(
            appBuild: 10000,
            bundleServices: DefaultWebServices.bundledServices(withVersion: "v5"),
            webServices: DefaultWebServices("v5", URL(string: "https://passepartoutvpn.app/api/")!, timeout: nil),
            persistence: ProvidersTests.persistence
        )
//        manager.reset()
    }

    override func tearDown() {
//        manager.reset()
    }

    func testFetchLocalIndex() throws {
        let exp = expectation(description: "Local index")

        manager.fetchProvidersIndexPublisher(priority: .bundle)
            .sink {
                switch $0 {
                case .finished:
                    exp.fulfill()

                case .failure(let error):
                    pp_log.error("Unable to load remote provider: \(error)")
                    exp.fulfill()
                }
            } receiveValue: {
                pp_log.debug("Loaded index")
            }.store(in: &cancellables)

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testFetchRemoteIndex() throws {
        let exp = expectation(description: "Remote index")

        manager.fetchProvidersIndexPublisher(priority: .remote)
            .sink {
                switch $0 {
                case .finished:
                    exp.fulfill()

                case .failure(let error):
                    pp_log.error("Unable to load remote provider: \(error)")
                    exp.fulfill()
                }
            } receiveValue: {
                pp_log.debug("Loaded index")
            }.store(in: &cancellables)

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testFetchRemoteProvider() async {
        do {
            try await manager.fetchProviderPublisher(withName: .hideme, vpnProtocol: .openVPN, priority: .remote).async()
            pp_log.debug("Loaded provider")
        } catch {
            XCTFail("Unable to load remote provider: \(error)")
        }
    }

    func testListProviders() {
        let providers = manager.allProviders()
        providers.forEach {
            pp_log.debug("\($0.name) -> \($0.fullName)")
        }
    }

    func testListCategories() async {
        await fetchProvider(.surfshark)
        let categories = manager.categories(.surfshark, vpnProtocol: .openVPN)
        categories.forEach {
            pp_log.debug("Category: \($0.name)")
            $0.locations.forEach {
                pp_log.debug("\t\($0)")
            }
        }
    }

    func testListServers() async {
        await fetchProvider(.nordvpn)
        manager.allProviders().filter({ $0.name == .nordvpn }).forEach {
            let location = ProviderLocation(
                providerMetadata: $0,
                vpnProtocol: .openVPN,
                categoryName: "",
                countryCode: "ES",
                servers: nil
            )

            let servers = manager.servers(forLocation: location)
            pp_log.debug("\($0.fullName): Servers [\(location.countryCode)] (\(servers.count)): \(servers)")
        }
    }

    func testServerId() async {
        await fetchProvider(.nordvpn)
        guard let server = manager.server(.nordvpn, vpnProtocol: .openVPN, apiId: "es143") else {
            return
        }
        pp_log.debug(server)
    }

    func testDefaultServer() async {
        await fetchProvider(.protonvpn)
        guard let server = manager.anyDefaultServer(.protonvpn, vpnProtocol: .openVPN) else {
            return
        }
        pp_log.debug(server)
    }

    func testServerUniqueId() async {
        await fetchProvider(.nordvpn)
        guard let server = manager.server(withId: "BEA03D24A5854DD17395057DEFBE7D6BEEA981227ACF8949E487443E6B5EF9C7") else {
            return
        }
        pp_log.debug(server)
        XCTAssertEqual(server.apiId, "es143")
    }

    private func fetchProvider(_ name: ProviderName) async {
        try? await manager.fetchProvidersIndexPublisher(priority: .bundle).async()
        try? await manager.fetchProviderPublisher(withName: name, vpnProtocol: .openVPN, priority: .bundle).async()
    }
}
