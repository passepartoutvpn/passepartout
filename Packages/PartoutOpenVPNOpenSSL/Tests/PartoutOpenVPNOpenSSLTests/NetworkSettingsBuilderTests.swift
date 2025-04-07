//
//  NetworkSettingsBuilderTests.swift
//  Partout
//
//  Created by Davide De Rosa on 4/12/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Partout.
//
//  Partout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Partout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Partout.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Partout
@testable import PartoutOpenVPNOpenSSL
import XCTest

final class NetworkSettingsBuilderTests: XCTestCase {

    // MARK: IP

    func test_givenSettings_whenBuildIPModule_thenRequiresRemoteIP() throws {
        var remoteOptions = OpenVPN.Configuration.Builder()

        remoteOptions.ipv4 = nil
        remoteOptions.ipv6 = nil
        XCTAssertNil(try builtModule(ofType: IPModule.self, with: remoteOptions))
        remoteOptions.ipv4 = IPSettings(subnet: Subnet(rawValue: "100.1.2.3/32")!)
        XCTAssertNotNil(try builtModule(ofType: IPModule.self, with: remoteOptions))

        remoteOptions.ipv4 = nil
        remoteOptions.ipv6 = nil
        XCTAssertNil(try builtModule(ofType: IPModule.self, with: remoteOptions))
        remoteOptions.ipv6 = IPSettings(subnet: Subnet(rawValue: "100:1:2::3/32")!)
        XCTAssertNotNil(try builtModule(ofType: IPModule.self, with: remoteOptions))
    }

    func test_givenSettings_whenBuildIPModule_thenMergesRoutes() throws {
        var sut: IPModule
        let allRoutes4 = [
            Route(Subnet(rawValue: "1.1.1.1/16")!, nil),
            Route(Subnet(rawValue: "2.2.2.2/8")!, nil),
            Route(Subnet(rawValue: "3.3.3.3/24")!, nil),
            Route(Subnet(rawValue: "4.4.4.4/32")!, nil)
        ]
        let allRoutes6 = [
            Route(Subnet(rawValue: "::1/16")!, nil),
            Route(Subnet(rawValue: "::2/8")!, nil),
            Route(Subnet(rawValue: "::3/24")!, nil),
            Route(Subnet(rawValue: "::4/32")!, nil)
        ]
        let localRoutes4 = Array(allRoutes4.prefix(2))
        let localRoutes6 = Array(allRoutes6.prefix(2))
        let remoteRoutes4 = Array(allRoutes4.suffix(from: 2))
        let remoteRoutes6 = Array(allRoutes6.suffix(from: 2))

        var localOptions = OpenVPN.Configuration.Builder()
        localOptions.routes4 = localRoutes4
        localOptions.routes6 = localRoutes6
        var remoteOptions = OpenVPN.Configuration.Builder()
        remoteOptions.ipv4 = IPSettings(subnet: Subnet(rawValue: "100.1.2.3/32")!)
        remoteOptions.ipv6 = IPSettings(subnet: Subnet(rawValue: "100:1:2::3/32")!)
        remoteOptions.routes4 = remoteRoutes4
        remoteOptions.routes6 = remoteRoutes6

        sut = try XCTUnwrap(try builtModule(ofType: IPModule.self, with: remoteOptions, localOptions: localOptions))
        XCTAssertEqual(sut.ipv4?.includedRoutes, allRoutes4)
        XCTAssertEqual(sut.ipv6?.includedRoutes, allRoutes6)

        localOptions.noPullMask = [.routes]
        sut = try XCTUnwrap(try builtModule(ofType: IPModule.self, with: remoteOptions, localOptions: localOptions))
        XCTAssertEqual(sut.ipv4?.includedRoutes, localOptions.routes4)
        XCTAssertEqual(sut.ipv6?.includedRoutes, localOptions.routes6)
    }

    func test_givenSettings_whenBuildIPModule_thenFollowsRoutingPolicies() throws {
        var sut: IPModule
        var remoteOptions = OpenVPN.Configuration.Builder()
        remoteOptions.ipv4 = IPSettings(
            subnet: Subnet(try XCTUnwrap(Address(rawValue: "1.1.1.1")), 16)
        )
        .including(
            routes: [
                Route(defaultWithGateway: try XCTUnwrap(Address(rawValue: "6.6.6.6")))
            ]
        )
        remoteOptions.ipv6 = IPSettings(
            subnet: Subnet(try XCTUnwrap(Address(rawValue: "1:1::1")), 72)
        )
        .including(
            routes: [
                Route(defaultWithGateway: try XCTUnwrap(Address(rawValue: "::6")))
            ]
        )

        sut = try XCTUnwrap(try builtModule(ofType: IPModule.self, with: remoteOptions))
        XCTAssertEqual(sut.ipv4?.subnet?.rawValue, "1.1.1.1/16")
        XCTAssertEqual(sut.ipv6?.subnet?.rawValue, "1:1::1/72")
        XCTAssertNil(sut.ipv4?.defaultGateway?.rawValue)
        XCTAssertNil(sut.ipv6?.defaultGateway?.rawValue)

        remoteOptions.routingPolicies = [.IPv4]
        sut = try XCTUnwrap(try builtModule(ofType: IPModule.self, with: remoteOptions))
        XCTAssertEqual(sut.ipv4?.defaultGateway?.rawValue, "6.6.6.6")
        XCTAssertNil(sut.ipv6?.defaultGateway?.rawValue)

        remoteOptions.routingPolicies = [.IPv6]
        sut = try XCTUnwrap(try builtModule(ofType: IPModule.self, with: remoteOptions))
        XCTAssertNil(sut.ipv4?.defaultGateway?.rawValue)
        XCTAssertEqual(sut.ipv6?.defaultGateway?.rawValue, "::6")

        remoteOptions.routingPolicies = [.IPv4, .IPv6]
        sut = try XCTUnwrap(try builtModule(ofType: IPModule.self, with: remoteOptions))
        XCTAssertEqual(sut.ipv4?.defaultGateway?.rawValue, "6.6.6.6")
        XCTAssertEqual(sut.ipv6?.defaultGateway?.rawValue, "::6")
    }

    // MARK: DNS

    func test_givenSettings_whenBuildDNSModule_thenRequiresServers() throws {
        var localOptions = OpenVPN.Configuration.Builder()
        var remoteOptions = OpenVPN.Configuration.Builder()

        XCTAssertNil(try builtModule(ofType: DNSModule.self, with: remoteOptions, localOptions: localOptions))

        localOptions.dnsServers = ["1.1.1.1"]
        remoteOptions.dnsServers = nil
        XCTAssertNotNil(try builtModule(ofType: DNSModule.self, with: remoteOptions, localOptions: localOptions))

        localOptions.dnsServers = nil
        remoteOptions.dnsServers = ["1.1.1.1"]
        XCTAssertNotNil(try builtModule(ofType: DNSModule.self, with: remoteOptions, localOptions: localOptions))

        localOptions.dnsServers = []
        remoteOptions.dnsServers = []
        XCTAssertNil(try builtModule(ofType: DNSModule.self, with: remoteOptions, localOptions: localOptions))
    }

    func test_givenSettings_whenBuildDNSModule_thenMergesServers() throws {
        var sut: DNSModule
        let allServers = [
            Address(rawValue: "1.1.1.1")!,
            Address(rawValue: "2.2.2.2")!,
            Address(rawValue: "3.3.3.3")!
        ]
        let localServers = Array(allServers.prefix(2))
        let remoteServers = Array(allServers.suffix(from: 2))

        var localOptions = OpenVPN.Configuration.Builder()
        localOptions.dnsServers = localServers.map(\.rawValue)
        var remoteOptions = OpenVPN.Configuration.Builder()
        remoteOptions.dnsServers = remoteServers.map(\.rawValue)

        sut = try XCTUnwrap(try builtModule(ofType: DNSModule.self, with: remoteOptions, localOptions: localOptions))
        XCTAssertEqual(sut.servers, allServers)

        localOptions.noPullMask = [.dns]
        sut = try XCTUnwrap(try builtModule(ofType: DNSModule.self, with: remoteOptions, localOptions: localOptions))
        XCTAssertEqual(sut.servers, localServers)
    }

    func test_givenSettings_whenBuildDNSModule_thenMergesDomains() throws {
        var sut: DNSModule
        let allDomains = [
            Address(rawValue: "one.com")!,
            Address(rawValue: "two.com")!,
            Address(rawValue: "three.com")!
        ]
        let localDomains = Array(allDomains.prefix(2))
        let remoteDomains = Array(allDomains.suffix(from: 2))

        var localOptions = OpenVPN.Configuration.Builder()
        localOptions.dnsServers = ["1.1.1.1"]
        localOptions.searchDomains = localDomains.map(\.rawValue)
        var remoteOptions = OpenVPN.Configuration.Builder()
        remoteOptions.searchDomains = remoteDomains.map(\.rawValue)

        sut = try XCTUnwrap(try builtModule(ofType: DNSModule.self, with: remoteOptions, localOptions: localOptions))
        XCTAssertEqual(sut.searchDomains, allDomains)

        localOptions.noPullMask = [.dns]
        sut = try XCTUnwrap(try builtModule(ofType: DNSModule.self, with: remoteOptions, localOptions: localOptions))
        XCTAssertEqual(sut.searchDomains, localDomains)
    }

    // MARK: Proxy

    func test_givenSettings_whenBuildHTTPProxyModule_thenRequiresEndpoint() throws {
        var localOptions = OpenVPN.Configuration.Builder()
        var remoteOptions = OpenVPN.Configuration.Builder()

        XCTAssertNil(try builtModule(ofType: HTTPProxyModule.self, with: remoteOptions, localOptions: localOptions))

        localOptions.httpProxy = Endpoint(rawValue: "1.1.1.1:8080")!
        remoteOptions.httpProxy = nil
        XCTAssertNotNil(try builtModule(ofType: HTTPProxyModule.self, with: remoteOptions, localOptions: localOptions))
        localOptions.httpsProxy = Endpoint(rawValue: "1.1.1.1:8080")!
        XCTAssertNotNil(try builtModule(ofType: HTTPProxyModule.self, with: remoteOptions, localOptions: localOptions))

        localOptions.httpProxy = nil
        remoteOptions.httpProxy = Endpoint(rawValue: "1.1.1.1:8080")!
        XCTAssertNotNil(try builtModule(ofType: HTTPProxyModule.self, with: remoteOptions, localOptions: localOptions))
        remoteOptions.httpsProxy = Endpoint(rawValue: "1.1.1.1:8080")!
        XCTAssertNotNil(try builtModule(ofType: HTTPProxyModule.self, with: remoteOptions, localOptions: localOptions))

        localOptions.httpProxy = nil
        remoteOptions.httpProxy = nil
        XCTAssertNotNil(try builtModule(ofType: HTTPProxyModule.self, with: remoteOptions, localOptions: localOptions))
        localOptions.httpsProxy = nil
        remoteOptions.httpsProxy = nil
        XCTAssertNil(try builtModule(ofType: HTTPProxyModule.self, with: remoteOptions, localOptions: localOptions))
    }

    func test_givenSettings_whenBuildACProxyModule_thenRequiresURL() throws {
        var localOptions = OpenVPN.Configuration.Builder()
        var remoteOptions = OpenVPN.Configuration.Builder()

        XCTAssertNil(try builtModule(ofType: HTTPProxyModule.self, with: remoteOptions, localOptions: localOptions))

        localOptions.proxyAutoConfigurationURL = URL(string: "https://www.gogle.com")!
        remoteOptions.proxyAutoConfigurationURL = nil
        XCTAssertNotNil(try builtModule(ofType: HTTPProxyModule.self, with: remoteOptions, localOptions: localOptions))

        localOptions.proxyAutoConfigurationURL = nil
        remoteOptions.proxyAutoConfigurationURL = URL(string: "https://www.gogle.com")!
        XCTAssertNotNil(try builtModule(ofType: HTTPProxyModule.self, with: remoteOptions, localOptions: localOptions))

        localOptions.proxyAutoConfigurationURL = nil
        remoteOptions.proxyAutoConfigurationURL = nil
        XCTAssertNil(try builtModule(ofType: HTTPProxyModule.self, with: remoteOptions, localOptions: localOptions))
    }

    func test_givenSettings_whenBuildProxyModule_thenMergesBypassDomains() throws {
        var sut: HTTPProxyModule
        let allDomains = [
            Address(rawValue: "one.com")!,
            Address(rawValue: "two.com")!,
            Address(rawValue: "three.com")!
        ]
        let localDomains = Array(allDomains.prefix(2))
        let remoteDomains = Array(allDomains.suffix(from: 2))

        var localOptions = OpenVPN.Configuration.Builder()
        localOptions.httpProxy = Endpoint(rawValue: "1.1.1.1:8080")!
        localOptions.proxyBypassDomains = localDomains.map(\.rawValue)
        var remoteOptions = OpenVPN.Configuration.Builder()
        remoteOptions.proxyBypassDomains = remoteDomains.map(\.rawValue)

        sut = try XCTUnwrap(try builtModule(ofType: HTTPProxyModule.self, with: remoteOptions, localOptions: localOptions))
        XCTAssertEqual(sut.bypassDomains, allDomains)

        localOptions.noPullMask = [.proxy]
        sut = try XCTUnwrap(try builtModule(ofType: HTTPProxyModule.self, with: remoteOptions, localOptions: localOptions))
        XCTAssertEqual(sut.bypassDomains, localDomains)
    }

    // MARK: MTU

    func test_givenSettings_whenBuildMTU_thenReturnsLocalMTU() throws {
        var sut: NetworkSettingsBuilder
        var localOptions = OpenVPN.Configuration.Builder()
        var remoteOptions = OpenVPN.Configuration.Builder()

        localOptions.mtu = 1200
        sut = try newBuilder(with: remoteOptions, localOptions: localOptions)
        XCTAssertEqual((sut.modules().first as? IPModule)?.mtu, localOptions.mtu)

        remoteOptions.mtu = 1400
        sut = try newBuilder(with: remoteOptions, localOptions: localOptions)
        XCTAssertEqual((sut.modules().first as? IPModule)?.mtu, localOptions.mtu)

        localOptions.mtu = nil
        sut = try newBuilder(with: remoteOptions, localOptions: localOptions)
        XCTAssertNil((sut.modules().first as? IPModule)?.mtu)
    }
}

// MARK: - Helpers

private extension NetworkSettingsBuilderTests {
    func builtModule<T>(
        ofType type: T.Type,
        with remoteOptions: OpenVPN.Configuration.Builder,
        localOptions: OpenVPN.Configuration.Builder? = nil
    ) throws -> T? where T: Module {
        try newBuilder(with: remoteOptions, localOptions: localOptions)
            .modules()
            .first(ofType: type)
    }

    func newBuilder(
        with remoteOptions: OpenVPN.Configuration.Builder,
        localOptions: OpenVPN.Configuration.Builder? = nil
    ) throws -> NetworkSettingsBuilder {
        NetworkSettingsBuilder(
            localOptions: try (localOptions ?? OpenVPN.Configuration.Builder()).tryBuild(isClient: false),
            remoteOptions: try remoteOptions.tryBuild(isClient: false)
        )
    }
}
