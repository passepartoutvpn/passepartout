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
import PassepartoutCore
import TunnelKit
import SwiftyBeaver
import Convenience

private let log = SwiftyBeaver.self

private enum FieldTag: Int {
    case dnsAddress = 100
    
    case dnsDomain = 200
    
    case proxyAddress = 301

    case proxyPort = 302
    
    case proxyAutoConfigurationURL = 303
    
    case proxyBypass = 400
}

private struct Offsets {
    static let dnsAddress = 0
    
    static let dnsDomain = 0
    
    static let proxyBypass = 2
}

class NetworkSettingsViewController: UITableViewController {
    var profile: ConnectionProfile?
    
    private lazy var networkChoices = ProfileNetworkChoices.with(profile: profile)
    
    private lazy var clientNetworkSettings = profile?.clientNetworkSettings
    
    private let networkSettings = ProfileNetworkSettings()
    
    // MARK: StrongTableHost
    
    let model: StrongTableModel<SectionType, RowType> = StrongTableModel()
    
    func reloadModel() {
        model.clear()
        
        // sections (candidate)
        var sections: [SectionType] = []
        sections.append(.choices)
        if networkChoices.gateway != .server {
            sections.append(.manualGateway)
        }
        if networkChoices.dns != .server {
            sections.append(.manualDNSServers)
            sections.append(.manualDNSDomains)
        }
        if networkChoices.proxy != .server {
            sections.append(.manualProxy)
        }
        
        // headers
        model.setHeader("", forSection: .choices)
        model.setHeader(L10n.Core.NetworkSettings.Gateway.title, forSection: .manualGateway)
        model.setHeader(L10n.Core.NetworkSettings.Proxy.title, forSection: .manualProxy)
        
        // footers
//        model.setFooter(L10n.Core.Configuration.Sections.Reset.footer, for: .reset)
        
        // rows
        model.set([.gateway, .dns, .proxy], forSection: .choices)
        model.set([.gatewayIPv4, .gatewayIPv6], forSection: .manualGateway)

        var dnsServers: [RowType] = Array(repeating: .dnsAddress, count: networkSettings.dnsServers?.count ?? 0)
        if networkChoices.dns == .manual {
            dnsServers.append(.dnsAddAddress)
        }
        model.set(dnsServers, forSection: .manualDNSServers)

        var dnsDomains: [RowType] = Array(repeating: .dnsDomain, count: networkSettings.dnsSearchDomains?.count ?? 0)
        if networkChoices.dns == .manual {
            dnsDomains.append(.dnsAddDomain)
        }
        model.set(dnsDomains, forSection: .manualDNSDomains)
        
        var proxyRows: [RowType] = Array(repeating: .proxyBypass, count: networkSettings.proxyBypassDomains?.count ?? 0)
        proxyRows.insert(.proxyAddress, at: 0)
        proxyRows.insert(.proxyPort, at: 1)
        proxyRows.insert(.proxyAutoConfigurationURL, at: 2)
        if networkChoices.proxy == .manual {
            proxyRows.append(.proxyAddBypass)
        }
        model.set(proxyRows, forSection: .manualProxy)

        // refine sections before add (DNS is tricky)
        if !dnsServers.isEmpty {
            model.setHeader(L10n.Core.NetworkSettings.Dns.title, forSection: .manualDNSServers)
        } else if !dnsDomains.isEmpty {
            sections.removeAll { $0 == .manualDNSServers }
            model.setHeader(L10n.Core.NetworkSettings.Dns.title, forSection: .manualDNSDomains)
        } else {
            sections.removeAll { $0 == .manualDNSServers }
            sections.removeAll { $0 == .manualDNSDomains }
        }
        for s in sections {
            model.add(s)
        }
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

        commitChanges()
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

        // DNS: servers, domains
        // Proxy: address, port, PAC, bypass domains

        let text = field.text ?? ""

        if field.tag >= FieldTag.dnsAddress.rawValue && field.tag < FieldTag.dnsDomain.rawValue {
            let i = field.tag - FieldTag.dnsAddress.rawValue
            if let _ = networkSettings.dnsServers {
                networkSettings.dnsServers?[i] = text
            } else {
                networkSettings.dnsServers = [text]
            }
        } else if field.tag >= FieldTag.dnsDomain.rawValue && field.tag < FieldTag.proxyAddress.rawValue {
            let i = field.tag - FieldTag.dnsDomain.rawValue
            if let _ = networkSettings.dnsSearchDomains {
                networkSettings.dnsSearchDomains?[i] = text
            } else {
                networkSettings.dnsSearchDomains = [text]
            }
        } else if field.tag == FieldTag.proxyAddress.rawValue {
            networkSettings.proxyAddress = field.text
        } else if field.tag == FieldTag.proxyPort.rawValue {
            networkSettings.proxyPort = UInt16(field.text ?? "0")
        } else if field.tag == FieldTag.proxyAutoConfigurationURL.rawValue {
            if let string = field.text {
                networkSettings.proxyAutoConfigurationURL = URL(string: string)
            } else {
                networkSettings.proxyAutoConfigurationURL = nil
            }
        } else if field.tag >= FieldTag.proxyBypass.rawValue {
            let i = field.tag - FieldTag.proxyBypass.rawValue
            if let _ = networkSettings.proxyBypassDomains {
                networkSettings.proxyBypassDomains?[i] = text
            } else {
                networkSettings.proxyBypassDomains = [text]
            }
        }
        
        log.debug("Network settings: \(networkSettings)")
    }
    
    private func commitChanges() {
        let settings = profile?.manualNetworkSettings ?? ProfileNetworkSettings()
        profile?.networkChoices = networkChoices
        if networkChoices.gateway == .manual {
            settings.copyGateway(from: networkSettings)
        }
        if networkChoices.dns == .manual {
            settings.copyDNS(from: networkSettings)
        }
        if networkChoices.proxy == .manual {
            settings.copyProxy(from: networkSettings)
        }
        profile?.manualNetworkSettings = settings
    }
}

// MARK: -

extension NetworkSettingsViewController {
    enum SectionType: Int {
        case choices
        
        case manualGateway
        
        case manualDNSServers
        
        case manualDNSDomains
        
        case manualProxy
    }
    
    enum RowType: Int {
        case gateway
        
        case dns
        
        case proxy
        
        case gatewayIPv4

        case gatewayIPv6
        
        case dnsAddress
        
        case dnsAddAddress
        
        case dnsDomain
        
        case dnsAddDomain
        
        case proxyAddress
        
        case proxyPort
        
        case proxyAutoConfigurationURL
        
        case proxyBypass

        case proxyAddBypass
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return model.headerHeight(for: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = model.row(at: indexPath)
        
        switch row {
        case .gateway:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.Core.NetworkSettings.Gateway.title
            cell.rightText = networkChoices.gateway.description
            return cell

        case .dns:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.Core.NetworkSettings.Dns.title
            cell.rightText = networkChoices.dns.description
            return cell

        case .proxy:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.leftText = L10n.Core.NetworkSettings.Proxy.title
            cell.rightText = networkChoices.proxy.description
            return cell

        case .gatewayIPv4:
            let cell = Cells.toggle.dequeue(from: tableView, for: indexPath, tag: row.rawValue, delegate: self)
            cell.caption = "IPv4"
            cell.toggle.isEnabled = (networkChoices.gateway == .manual)
            cell.isOn = networkSettings.gatewayPolicies?.contains(.IPv4) ?? false
            return cell

        case .gatewayIPv6:
            let cell = Cells.toggle.dequeue(from: tableView, for: indexPath, tag: row.rawValue, delegate: self)
            cell.caption = "IPv6"
            cell.toggle.isEnabled = (networkChoices.gateway == .manual)
            cell.isOn = networkSettings.gatewayPolicies?.contains(.IPv6) ?? false
            return cell
            
        case .dnsAddress:
            let i = indexPath.row - Offsets.dnsAddress
            
            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cell.caption = L10n.Core.Global.Captions.address
            cell.field.tag = FieldTag.dnsAddress.rawValue + i
            cell.field.placeholder = L10n.Core.Global.Values.none
            cell.field.text = networkSettings.dnsServers?[i]
            cell.field.clearButtonMode = .always
            cell.field.keyboardType = .numbersAndPunctuation
            cell.captionWidth = 160.0
            cell.delegate = self
            cell.field.isEnabled = (networkChoices.dns == .manual)
            return cell

        case .dnsAddAddress:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.applyAction(Theme.current)
            cell.leftText = L10n.App.NetworkSettings.Cells.AddDnsServer.caption
            return cell
            
        case .dnsDomain:
            let i = indexPath.row - Offsets.dnsDomain

            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cell.caption = L10n.Core.NetworkSettings.Dns.Cells.Domain.caption
            cell.field.tag = FieldTag.dnsDomain.rawValue + i
            cell.field.placeholder = L10n.Core.Global.Values.none
            cell.field.text = networkSettings.dnsSearchDomains?[i]
            cell.field.clearButtonMode = .always
            cell.field.keyboardType = .asciiCapable
            cell.captionWidth = 160.0
            cell.delegate = self
            cell.field.isEnabled = (networkChoices.dns == .manual)
            return cell
            
        case .dnsAddDomain:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.applyAction(Theme.current)
            cell.leftText = L10n.App.NetworkSettings.Cells.AddDnsDomain.caption
            return cell
            
        case .proxyAddress:
            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cell.caption = L10n.Core.Global.Captions.address
            cell.field.tag = FieldTag.proxyAddress.rawValue
            cell.field.placeholder = L10n.Core.Global.Values.none
            cell.field.text = networkSettings.proxyAddress
            cell.field.clearButtonMode = .always
            cell.field.keyboardType = .numbersAndPunctuation
            cell.captionWidth = 160.0
            cell.delegate = self
            cell.field.isEnabled = (networkChoices.proxy == .manual)
            return cell

        case .proxyPort:
            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cell.caption = L10n.Core.Global.Captions.port
            cell.field.tag = FieldTag.proxyPort.rawValue
            cell.field.placeholder = L10n.Core.Global.Values.none
            cell.field.text = networkSettings.proxyPort?.description
            cell.field.clearButtonMode = .always
            cell.field.keyboardType = .numberPad
            cell.captionWidth = 160.0
            cell.delegate = self
            cell.field.isEnabled = (networkChoices.proxy == .manual)
            return cell
            
        case .proxyAutoConfigurationURL:
            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cell.caption = "PAC"
            cell.field.tag = FieldTag.proxyAutoConfigurationURL.rawValue
            cell.field.placeholder = L10n.Core.Global.Values.none
            cell.field.text = networkSettings.proxyAutoConfigurationURL?.absoluteString
            cell.field.clearButtonMode = .always
            cell.field.keyboardType = .asciiCapable
            cell.captionWidth = 160.0
            cell.delegate = self
            cell.field.isEnabled = (networkChoices.proxy == .manual)
            return cell

        case .proxyBypass:
            let i = indexPath.row - Offsets.proxyBypass
            
            let cell = Cells.field.dequeue(from: tableView, for: indexPath)
            cell.caption = L10n.App.NetworkSettings.Cells.ProxyBypass.caption
            cell.field.tag = FieldTag.proxyBypass.rawValue + i
            cell.field.placeholder = L10n.Core.Global.Values.none
            cell.field.text = networkSettings.proxyBypassDomains?[i]
            cell.field.clearButtonMode = .always
            cell.field.keyboardType = .asciiCapable
            cell.captionWidth = 160.0
            cell.delegate = self
            cell.field.isEnabled = (networkChoices.proxy == .manual)
            return cell

        case .proxyAddBypass:
            let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
            cell.applyAction(Theme.current)
            cell.leftText = L10n.App.NetworkSettings.Cells.AddProxyBypass.caption
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        switch model.row(at: indexPath) {
        case .gateway:
            let vc = SingleOptionViewController<NetworkChoice>()
            vc.title = (cell as? SettingTableViewCell)?.leftText
            vc.options = NetworkChoice.choices(for: profile)
            vc.descriptionBlock = { $0.description }

            vc.selectedOption = networkChoices.gateway
            vc.selectionBlock = { [weak self] in
                self?.updateGateway($0)
                self?.navigationController?.popViewController(animated: true)
            }
            navigationController?.pushViewController(vc, animated: true)

        case .dns:
            let vc = SingleOptionViewController<NetworkChoice>()
            vc.title = (cell as? SettingTableViewCell)?.leftText
            vc.options = NetworkChoice.choices(for: profile)
            vc.descriptionBlock = { $0.description }
            
            vc.selectedOption = networkChoices.dns
            vc.selectionBlock = { [weak self] in
                self?.updateDNS($0)
                self?.navigationController?.popViewController(animated: true)
            }
            navigationController?.pushViewController(vc, animated: true)

        case .proxy:
            let vc = SingleOptionViewController<NetworkChoice>()
            vc.title = (cell as? SettingTableViewCell)?.leftText
            vc.options = NetworkChoice.choices(for: profile)
            vc.descriptionBlock = { $0.description }
            
            vc.selectedOption = networkChoices.proxy
            vc.selectionBlock = { [weak self] in
                self?.updateProxy($0)
                self?.navigationController?.popViewController(animated: true)
            }
            navigationController?.pushViewController(vc, animated: true)

        case .dnsAddAddress:
            tableView.deselectRow(at: indexPath, animated: true)
            
            var dnsServers = networkSettings.dnsServers ?? []
            dnsServers.append("")
            networkSettings.dnsServers = dnsServers
            reloadModel()
            tableView.insertRows(at: [indexPath], with: .automatic)

        case .dnsAddDomain:
            tableView.deselectRow(at: indexPath, animated: true)
            
            var dnsSearchDomains = networkSettings.dnsSearchDomains ?? []
            dnsSearchDomains.append("")
            networkSettings.dnsSearchDomains = dnsSearchDomains
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
    
    private func handle(row: RowType, cell: ToggleTableViewCell) {
        switch row {
        case .gatewayIPv4:
            guard networkChoices.gateway == .manual else {
                return
            }
            var policies = networkSettings.gatewayPolicies ?? []
            if cell.toggle.isOn {
                policies.append(.IPv4)
            } else {
                policies.removeAll { $0 == .IPv4 }
            }
            policies.sort { $0.rawValue < $1.rawValue }
            networkSettings.gatewayPolicies = policies

        case .gatewayIPv6:
            guard networkChoices.gateway == .manual else {
                return
            }
            var policies = networkSettings.gatewayPolicies ?? []
            if cell.toggle.isOn {
                policies.append(.IPv6)
            } else {
                policies.removeAll { $0 == .IPv6 }
            }
            policies.sort { $0.rawValue < $1.rawValue }
            networkSettings.gatewayPolicies = policies

        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch model.row(at: indexPath) {
        case .dnsAddress, .dnsDomain, .proxyBypass:
            return true

        default:
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch model.row(at: indexPath) {
        case .dnsAddress:
            networkSettings.dnsServers?.remove(at: indexPath.row - Offsets.dnsAddress)

        case .dnsDomain:
            networkSettings.dnsSearchDomains?.remove(at: indexPath.row - Offsets.dnsDomain)

        case .proxyBypass:
            networkSettings.proxyBypassDomains?.remove(at: indexPath.row - Offsets.proxyBypass)
            
        default:
            break
        }

        reloadModel()
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension NetworkSettingsViewController: ToggleTableViewCellDelegate {
    func toggleCell(_ cell: ToggleTableViewCell, didToggleToValue value: Bool) {
        guard let item = RowType(rawValue: cell.tag) else {
            return
        }
        handle(row: item, cell: cell)
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
            return L10n.Core.NetworkChoice.client
            
        case .server:
            return L10n.Core.NetworkChoice.server
            
        case .manual:
            return L10n.Core.Global.Values.manual
        }
    }
}
