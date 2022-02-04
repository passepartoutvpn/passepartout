//
//  ServerNetworkViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/23/19.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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

import UIKit
import SwiftyBeaver
import PassepartoutCore
import ConvenienceUI

private let log = SwiftyBeaver.self

class ServerNetworkViewController: UITableViewController, StrongTableHost {
    var configuration: OpenVPN.Configuration!
    
    private let indexOfFirstRoute4 = 2

    private let indexOfFirstRoute6 = 2

    private var indexOfFirstDNSAddress = 0

    private var indexOfFirstProxyBypassDomain = 0

    // MARK: StrongTableHost

    lazy var model: StrongTableModel<SectionType, RowType> = {
        let model: StrongTableModel<SectionType, RowType> = StrongTableModel()
        var rows: [RowType]

        if let ipv4 = configuration.ipv4 {
            model.add(.ipv4)
            rows = [.address, .defaultGateway]
            for i in 0..<ipv4.routes.count {
                rows.append(.route)
            }
            model.set(rows, forSection: .ipv4)
        }

        if let ipv6 = configuration.ipv6 {
            model.add(.ipv6)
            rows = [.address, .defaultGateway]
            for i in 0..<ipv6.routes.count {
                rows.append(.route)
            }
            model.set(rows, forSection: .ipv6)
        }

        rows = []
        if let dnsDomains = configuration.searchDomains, !dnsDomains.isEmpty {
            for i in 0..<dnsDomains.count {
                rows.append(.dnsDomain)
            }
        }
        if let dnsServers = configuration.dnsServers, !dnsServers.isEmpty {
            indexOfFirstDNSAddress = rows.count
            for i in 0..<dnsServers.count {
                rows.append(.dnsAddress)
            }
        }
        if !rows.isEmpty {
            model.add(.dns)
            model.set(rows, forSection: .dns)
        }

        if let proxy = configuration.httpsProxy ?? configuration.httpProxy {
            model.add(.proxy)
            var rows: [RowType] = []
            rows.append(.proxyAddress)
            if let autoConfigurationURL = configuration.proxyAutoConfigurationURL {
                rows.append(.proxyAutoConfigurationURL)
            }
            indexOfFirstProxyBypassDomain = rows.count
            if let bypassDomains = configuration.proxyBypassDomains, !bypassDomains.isEmpty {
                for i in 0..<bypassDomains.count {
                    rows.append(.proxyBypassDomains)
                }
            }
            model.set(rows, forSection: .proxy)
        }

        // headers
        model.setHeader("IPv4", forSection: .ipv4)
        model.setHeader("IPv6", forSection: .ipv6)
        model.setHeader(L10n.NetworkSettings.Dns.title, forSection: .dns)
        model.setHeader(L10n.NetworkSettings.Proxy.title, forSection: .proxy)

        return model
    }()
    
    func reloadModel() {
    }
    
    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = configuration else {
            fatalError("Configuration not set")
        }
    }
}

// MARK: -

extension ServerNetworkViewController {
    enum SectionType: Int {
        case ipv4

        case ipv6

        case dns
        
        case proxy
    }
    
    enum RowType: Int {
        case address
        
        case defaultGateway

        case route
        
        case dnsAddress
        
        case dnsDomain
        
        case proxyAddress

        case proxyBypassDomains

        case proxyAutoConfigurationURL
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(forSection: section)
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.footer(forSection: section)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(forSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = model.section(forIndex: indexPath.section)
        let row = model.row(at: indexPath)

        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        cell.accessoryType = .none
        cell.isTappable = false

        // family-specific rows
        switch section {
        case .ipv4:
            switch row {
            case .address:
                cell.leftText = L10n.Global.Captions.address
                if let ipv4 = configuration.ipv4 {
                    cell.rightText = "\(ipv4.address)/\(ipv4.addressMask)"
                } else {
                    cell.rightText = L10n.Global.Values.none
                }

            case .defaultGateway:
                cell.leftText = L10n.NetworkSettings.Gateway.title
                cell.rightText = configuration.ipv4?.defaultGateway ?? L10n.Global.Values.none

            case .route:
                guard let route = configuration.ipv4?.routes[indexPath.row - indexOfFirstRoute4] else {
                    fatalError("Got an IPv4 route cell with empty routes")
                }
                cell.leftText = L10n.ServerNetwork.Cells.Route.caption
                cell.rightText = "\(route.destination)/\(route.mask) -> \(route.gateway)"

            default:
                break
            }

        case .ipv6:
            switch row {
            case .address:
                cell.leftText = L10n.Global.Captions.address
                if let ipv6 = configuration.ipv6 {
                    cell.rightText = "\(ipv6.address)/\(ipv6.addressPrefixLength)"
                } else {
                    cell.rightText = L10n.Global.Values.none
                }

            case .defaultGateway:
                cell.leftText = L10n.NetworkSettings.Gateway.title
                cell.rightText = configuration.ipv6?.defaultGateway ?? L10n.Global.Values.none

            case .route:
                guard let route = configuration.ipv6?.routes[indexPath.row - indexOfFirstRoute6] else {
                    fatalError("Got an IPv6 route cell with empty routes")
                }
                cell.leftText = L10n.ServerNetwork.Cells.Route.caption
                cell.rightText = "\(route.destination)/\(route.prefixLength) -> \(route.gateway)"

            default:
                break
            }
            
        default:
            break
        }

        // shared rows
        switch row {
        case .dnsDomain:
            guard let domain = configuration.searchDomains?[indexPath.row] else {
                fatalError("Got DNS search domain with empty search domains")
            }
            cell.leftText = L10n.NetworkSettings.Dns.Cells.Domain.caption
            cell.rightText = domain
            
        case .dnsAddress:
            guard let server = configuration.dnsServers?[indexPath.row - indexOfFirstDNSAddress] else {
                fatalError("Got DNS server with empty servers")
            }
            cell.leftText = L10n.Global.Captions.address
            cell.rightText = server

        case .proxyAddress:
            guard let proxy = configuration.httpsProxy ?? configuration.httpProxy else {
                fatalError("Got proxy section without a proxy")
            }
            cell.leftText = L10n.Global.Captions.address
            cell.rightText = "\(proxy.address):\(proxy.port)"

        case .proxyAutoConfigurationURL:
            cell.leftText = "PAC"
            guard let url = configuration.proxyAutoConfigurationURL else {
                fatalError("Got PAC cell without a PAC")
            }
            cell.rightText = url.absoluteString

        case .proxyBypassDomains:
            guard let domain = configuration.proxyBypassDomains?[indexPath.row - indexOfFirstProxyBypassDomain] else {
                fatalError("Got proxy bypass domain with empty domains")
            }
            cell.leftText = L10n.NetworkSettings.Cells.ProxyBypass.caption
            cell.rightText = domain
            
        default:
            break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy(_:))
    }
    
    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        let cell = tableView.cellForRow(at: indexPath)
        UIPasteboard.general.string = cell?.detailTextLabel?.text
    }
}
