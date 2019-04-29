//
//  NetworkSettingsViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 4/29/19.
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

import UIKit
import Passepartout_Core
import TunnelKit
import SwiftyBeaver

private let log = SwiftyBeaver.self

private enum FieldTag: Int {
    case dnsDomain = 101
    
    case dnsAddress = 200
    
    case proxyAddress = 301

    case proxyPort = 302
    
    case proxyBypass = 400
}

private struct Offsets {
    static let dnsAddress = 1
    
    static let proxyBypass = 2
}

// FIXME: init networkSettings with HOST profile.sessionConfiguration
// FIXME: omit "Client" for PROVIDER

class NetworkSettingsViewController: UITableViewController {
    var profile: ConnectionProfile?
    
    private lazy var networkChoices: ProfileNetworkChoices = {
        if let choices = profile?.networkChoices {
            return choices
        }
        if let _ = profile as? ProviderConnectionProfile {
            return ProfileNetworkChoices(choice: .server)
        }
        return ProfileNetworkChoices(choice: .client)
    }()
    
    private let networkSettings = ProfileNetworkSettings()

    private lazy var clientNetworkSettings: ProfileNetworkSettings? = {
        guard let hostProfile = profile as? HostConnectionProfile else {
            return nil
        }
        return ProfileNetworkSettings(from: hostProfile.parameters.sessionConfiguration)
    }()
    
    private var choices: [NetworkChoice] {
        guard let _ = clientNetworkSettings else {
            return [.server, .manual]
        }
        return [.client, .server, .manual]
    }
    
    // MARK: TableModelHost
    
    let model: TableModel<SectionType, RowType> = TableModel()
    
    func reloadModel() {
        model.clear()
        
        // sections
        model.add(.choices)
        if networkChoices.gateway != .server {
            model.add(.manualGateway)
        }
        if networkChoices.dns != .server {
            model.add(.manualDNS)
        }
        if networkChoices.proxy != .server {
            model.add(.manualProxy)
        }
        
        // headers
        model.setHeader("", for: .choices)
        model.setHeader(L10n.Configuration.Cells.DefaultGateway.caption, for: .manualGateway)
        model.setHeader(L10n.Configuration.Cells.DnsServer.caption, for: .manualDNS)
        model.setHeader(L10n.Configuration.Cells.ProxyHttp.caption, for: .manualProxy)
        
        // footers
//        model.setFooter(L10n.Configuration.Sections.Reset.footer, for: .reset)
        
        // rows
        model.set([.gateway, .dns, .proxy], in: .choices)
        model.set([.gatewayAll, .gatewayIPv4, .gatewayIPv6, .gatewayNone], in: .manualGateway)

        var dnsRows: [RowType] = Array(repeating: .dnsAddress, count: networkSettings.dnsServers?.count ?? 0)
        dnsRows.insert(.dnsDomain, at: 0)
        if networkChoices.dns == .manual {
            dnsRows.append(.dnsAddAddress)
        }
        model.set(dnsRows, in: .manualDNS)

        var proxyRows: [RowType] = Array(repeating: .proxyBypass, count: networkSettings.proxyBypassDomains?.count ?? 0)
        proxyRows.insert(.proxyAddress, at: 0)
        proxyRows.insert(.proxyPort, at: 1)
        if networkChoices.proxy == .manual {
            proxyRows.append(.proxyAddBypass)
        }
        model.set(proxyRows, in: .manualProxy)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateGateway(networkChoices.gateway)
        updateDNS(networkChoices.dns)
        updateProxy(networkChoices.proxy)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadModel()
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        profile?.networkChoices = networkChoices
        if networkChoices.gateway == .manual {
            let settings = profile?.manualNetworkSettings ?? ProfileNetworkSettings()
            settings.copyGateway(from: networkSettings)
            profile?.manualNetworkSettings = settings
        }
        if networkChoices.dns == .manual {
            let settings = profile?.manualNetworkSettings ?? ProfileNetworkSettings()
            settings.copyDNS(from: networkSettings)
            profile?.manualNetworkSettings = settings
        }
        if networkChoices.proxy == .manual {
            let settings = profile?.manualNetworkSettings ?? ProfileNetworkSettings()
            settings.copyProxy(from: networkSettings)
            profile?.manualNetworkSettings = settings
        }
    }
    
    // MARK: Actions
    
    private func updateGateway(_ choice: NetworkChoice) {
        networkChoices.gateway = choice
        switch networkChoices.gateway {
        case .client:
            if let settings = clientNetworkSettings {
                networkSettings.copyGateway(from: settings)
            }
            
        case .server:
            break

        case .manual:
            if let settings = profile?.manualNetworkSettings {
                networkSettings.copyGateway(from: settings)
            }
        }
    }
    
    private func updateDNS(_ choice: NetworkChoice) {
        networkChoices.dns = choice
        switch networkChoices.dns {
        case .client:
            if let settings = clientNetworkSettings {
                networkSettings.copyDNS(from: settings)
            }
            
        case .server:
            break
            
        case .manual:
            if let settings = profile?.manualNetworkSettings {
                networkSettings.copyDNS(from: settings)
            }
        }
    }
    
    private func updateProxy(_ choice: NetworkChoice) {
        networkChoices.proxy = choice
        switch networkChoices.proxy {
        case .client:
            if let settings = clientNetworkSettings {
                networkSettings.copyProxy(from: settings)
            }
            
        case .server:
            break
            
        case .manual:
            if let settings = profile?.manualNetworkSettings {
                networkSettings.copyProxy(from: settings)
            }
        }
    }
    
    private func commitTextField(_ field: UITextField) {

        // DNS: domain, servers
        // Proxy: address, port, bypass domains
        
        if field.tag == FieldTag.dnsDomain.rawValue {
            networkSettings.dnsDomainName = field.text
        } else if field.tag == FieldTag.proxyAddress.rawValue {
            networkSettings.proxyAddress = field.text
        } else if field.tag == FieldTag.proxyPort.rawValue {
            networkSettings.proxyPort = UInt16(field.text ?? "0")
        } else if field.tag >= FieldTag.dnsAddress.rawValue && field.tag < FieldTag.proxyAddress.rawValue {
            let i = field.tag - FieldTag.dnsAddress.rawValue
            networkSettings.dnsServers?[i] = field.text ?? ""
        } else if field.tag >= FieldTag.proxyBypass.rawValue {
            let i = field.tag - FieldTag.proxyBypass.rawValue
            networkSettings.proxyBypassDomains?[i] = field.text ?? ""
        }
        
        log.debug("Network settings: \(networkSettings)")
    }
}

// MARK: -

extension NetworkSettingsViewController {
    enum SectionType: Int {
        case choices
        
        case manualGateway
        
        case manualDNS
        
        case manualProxy
    }
    
    enum RowType: Int {
        case gateway
        
        case dns
        
        case proxy
        
        case gatewayAll
        
        case gatewayIPv4

        case gatewayIPv6

        case gatewayNone
        
        case dnsDomain
        
        case dnsAddress
        
        case dnsAddAddress
        
        case proxyAddress
        
        case proxyPort
        
        case proxyBypass

        case proxyAddBypass
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(for: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.footer(for: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return model.headerHeight(for: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count(for: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = model.row(at: indexPath)
        
        switch row {
        case .gateway:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = model.header(for: .manualGateway)
            cell.rightText = networkChoices.gateway.description
            return cell

        case .dns:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = model.header(for: .manualDNS)
            cell.rightText = networkChoices.dns.description
            return cell

        case .proxy:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = model.header(for: .manualProxy)
            cell.rightText = networkChoices.proxy.description
            return cell

        case .gatewayAll, .gatewayIPv4, .gatewayIPv6, .gatewayNone:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            var policies: [SessionProxy.RoutingPolicy]?
            
            switch row {
            case .gatewayAll:
                cell.leftText = L10n.Global.Cells.enabled
                policies = [.IPv4, .IPv6]

            case .gatewayIPv4:
                cell.leftText = "IPv4"
                policies = [.IPv4]

            case .gatewayIPv6:
                cell.leftText = "IPv6"
                policies = [.IPv6]

            case .gatewayNone:
                cell.leftText = L10n.Global.Cells.disabled

            default:
                break
            }
            cell.applyChecked(networkSettings.gatewayPolicies == policies, Theme.current)
            cell.isTappable = (networkChoices.gateway == .manual)
            return cell

        case .dnsDomain:
            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cell.caption = L10n.Configuration.Cells.DnsDomain.caption
            cell.field.tag = FieldTag.dnsDomain.rawValue
            cell.field.text = networkSettings.dnsDomainName
            cell.field.clearButtonMode = .always
            cell.field.keyboardType = .asciiCapable
            cell.captionWidth = 160.0
            cell.delegate = self
            if networkChoices.dns == .manual {
                cell.field.isEnabled = true
                cell.field.placeholder = "example.com"
            } else {
                cell.field.isEnabled = false
                cell.field.placeholder = nil
            }
            return cell
            
        case .dnsAddress:
            let i = indexPath.row - Offsets.dnsAddress
            
            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cell.caption = L10n.NetworkSettings.Cells.Address.caption
            cell.field.tag = FieldTag.dnsAddress.rawValue + i
            cell.field.text = networkSettings.dnsServers?[i]
            cell.field.clearButtonMode = .always
            cell.field.keyboardType = .decimalPad
            cell.captionWidth = 160.0
            cell.delegate = self
            if networkChoices.dns == .manual {
                cell.field.isEnabled = true
                cell.field.placeholder = "8.8.8.8"
            } else {
                cell.field.isEnabled = false
                cell.field.placeholder = nil
            }
            return cell

        case .dnsAddAddress:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.applyAction(Theme.current)
            cell.leftText = L10n.NetworkSettings.Cells.AddDnsServer.caption
            return cell
            
        case .proxyAddress:
            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cell.caption = L10n.NetworkSettings.Cells.Address.caption
            cell.field.tag = FieldTag.proxyAddress.rawValue
            cell.field.text = networkSettings.proxyAddress
            cell.field.clearButtonMode = .always
            cell.field.keyboardType = .decimalPad
            cell.captionWidth = 160.0
            cell.delegate = self
            if networkChoices.proxy == .manual {
                cell.field.isEnabled = true
                cell.field.placeholder = "192.168.1.1"
            } else {
                cell.field.isEnabled = false
                cell.field.placeholder = nil
            }
            return cell

        case .proxyPort:
            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cell.caption = L10n.NetworkSettings.Cells.Port.caption
            cell.field.tag = FieldTag.proxyPort.rawValue
            cell.field.text = networkSettings.proxyPort?.description
            cell.field.clearButtonMode = .always
            cell.field.keyboardType = .numberPad
            cell.captionWidth = 160.0
            cell.delegate = self
            if networkChoices.proxy == .manual {
                cell.field.isEnabled = true
                cell.field.placeholder = "8080"
            } else {
                cell.field.isEnabled = false
                cell.field.placeholder = nil
            }
            return cell

        case .proxyBypass:
            let i = indexPath.row - Offsets.proxyBypass
            
            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cell.caption = L10n.NetworkSettings.Cells.ProxyBypass.caption
            cell.field.tag = FieldTag.proxyBypass.rawValue + i
            cell.field.text = networkSettings.proxyBypassDomains?[i]
            cell.field.clearButtonMode = .always
            cell.field.keyboardType = .asciiCapable
            cell.captionWidth = 160.0
            cell.delegate = self
            if networkChoices.proxy == .manual {
                cell.field.isEnabled = true
                cell.field.placeholder = "excluded.com"
            } else {
                cell.field.isEnabled = false
                cell.field.placeholder = nil
            }
            return cell

        case .proxyAddBypass:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.applyAction(Theme.current)
            cell.leftText = L10n.NetworkSettings.Cells.AddProxyBypass.caption
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        switch model.row(at: indexPath) {
        case .gateway:
            let vc = OptionViewController<NetworkChoice>()
            vc.title = (cell as? SettingTableViewCell)?.leftText
            vc.options = choices
            vc.descriptionBlock = { $0.description }

            vc.selectedOption = networkChoices.gateway
            vc.selectionBlock = { [weak self] in
                self?.updateGateway($0)
                self?.navigationController?.popViewController(animated: true)
            }
            navigationController?.pushViewController(vc, animated: true)

        case .dns:
            let vc = OptionViewController<NetworkChoice>()
            vc.title = (cell as? SettingTableViewCell)?.leftText
            vc.options = choices
            vc.descriptionBlock = { $0.description }
            
            vc.selectedOption = networkChoices.dns
            vc.selectionBlock = { [weak self] in
                self?.updateDNS($0)
                self?.navigationController?.popViewController(animated: true)
            }
            navigationController?.pushViewController(vc, animated: true)

        case .proxy:
            let vc = OptionViewController<NetworkChoice>()
            vc.title = (cell as? SettingTableViewCell)?.leftText
            vc.options = choices
            vc.descriptionBlock = { $0.description }
            
            vc.selectedOption = networkChoices.proxy
            vc.selectionBlock = { [weak self] in
                self?.updateProxy($0)
                self?.navigationController?.popViewController(animated: true)
            }
            navigationController?.pushViewController(vc, animated: true)

        case .gatewayAll:
            guard networkChoices.gateway == .manual else {
                return
            }
            networkSettings.gatewayPolicies = [.IPv4, .IPv6]
            tableView.reloadData()

        case .gatewayIPv4:
            guard networkChoices.gateway == .manual else {
                return
            }
            networkSettings.gatewayPolicies = [.IPv4]
            tableView.reloadData()

        case .gatewayIPv6:
            guard networkChoices.gateway == .manual else {
                return
            }
            networkSettings.gatewayPolicies = [.IPv6]
            tableView.reloadData()

        case .gatewayNone:
            guard networkChoices.gateway == .manual else {
                return
            }
            networkSettings.gatewayPolicies = nil
            tableView.reloadData()
            
        case .dnsAddAddress:
            tableView.deselectRow(at: indexPath, animated: true)
            
            var dnsServers = networkSettings.dnsServers ?? []
            dnsServers.append("")
            networkSettings.dnsServers = dnsServers
            reloadModel()
            tableView.insertRows(at: [indexPath], with: .automatic)

        case .proxyAddBypass:
            tableView.deselectRow(at: indexPath, animated: true)
            
            var bypassDomains = networkSettings.proxyBypassDomains ?? []
            bypassDomains.append("")
            networkSettings.proxyBypassDomains = bypassDomains
            reloadModel()
            tableView.insertRows(at: [indexPath], with: .automatic)
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch model.row(at: indexPath) {
        case .dnsAddress, .proxyBypass:
            return true

        default:
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch model.row(at: indexPath) {
        case .dnsAddress:
            // start at row 1
            networkSettings.dnsServers?.remove(at: indexPath.row - Offsets.dnsAddress)

        case .proxyBypass:
            // start at row 2
            networkSettings.proxyBypassDomains?.remove(at: indexPath.row - Offsets.proxyBypass)
            
        default:
            break
        }

        reloadModel()
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension NetworkSettingsViewController: FieldTableViewCellDelegate {
    func fieldCellDidEdit(_ cell: FieldTableViewCell) {
        commitTextField(cell.field)
    }
    
    func fieldCellDidEnter(_: FieldTableViewCell) {
    }
}

extension NetworkChoice: CustomStringConvertible {
    public var description: String {
        switch self {
        case .client:
            return L10n.NetworkSettings.Cells.Choice.client
            
        case .server:
            return L10n.NetworkSettings.Cells.Choice.server
            
        case .manual:
            return L10n.Global.Cells.manual
        }
    }
}
