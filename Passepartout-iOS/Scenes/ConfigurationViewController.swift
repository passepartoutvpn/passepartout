//
//  ConfigurationViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/2/18.
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
import TunnelKit
import SwiftyBeaver
import Passepartout_Core

private let log = SwiftyBeaver.self

class ConfigurationViewController: UIViewController, TableModelHost {
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var itemRefresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))

    var initialConfiguration: SessionProxy.Configuration!
    
    private lazy var configuration: SessionProxy.ConfigurationBuilder = initialConfiguration.builder()
    
    var originalConfigurationURL: URL?

    private var isEditable: Bool {
        return originalConfigurationURL != nil
    }
        
    weak var delegate: ConfigurationModificationDelegate?
    
    // MARK: TableModelHost

    lazy var model: TableModel<SectionType, RowType> = {
        let model: TableModel<SectionType, RowType> = TableModel()
        
        // sections
        model.add(.communication)
        if isEditable {
            model.add(.reset)
        }
        model.add(.tls)
        model.add(.compression)
        model.add(.network)
        model.add(.other)

        // headers
        model.setHeader(L10n.Configuration.Sections.Communication.header, for: .communication)
        model.setHeader(L10n.Configuration.Sections.Tls.header, for: .tls)
        model.setHeader(L10n.Configuration.Sections.Compression.header, for: .compression)
        model.setHeader(L10n.Configuration.Sections.Network.header, for: .network)
        model.setHeader(L10n.Configuration.Sections.Other.header, for: .other)

        // footers
        if isEditable {
            model.setFooter(L10n.Configuration.Sections.Reset.footer, for: .reset)
        }
        
        // rows
        model.set([.cipher, .digest], in: .communication)
        if isEditable {
            model.set([.resetOriginal], in: .reset)
        }
        model.set([.client, .tlsWrapping, .eku], in: .tls)
        model.set([.compressionFraming, .compressionAlgorithm], in: .compression)
        var networkRows: [RowType]
        if let dnsServers = configuration.dnsServers {
            networkRows = [RowType](repeating: .dnsServer, count: dnsServers.count)
        } else {
            networkRows = []
        }
        networkRows.insert(.defaultGateway, at: 0)
        networkRows.append(.dnsDomain)
        networkRows.append(.httpProxy)
        networkRows.append(.httpsProxy)
        model.set(networkRows, in: .network)
        model.set([.keepAlive, .renegSeconds, .randomEndpoint], in: .other)

        return model
    }()
    
    func reloadModel() {
    }
    
    // MARK: UIViewController

    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyDetailTitle(Theme.current)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = initialConfiguration else {
            fatalError("Initial configuration not set")
        }
        
        guard isEditable else {
            tableView.allowsSelection = false
            return
        }
        itemRefresh.isEnabled = false
        navigationItem.rightBarButtonItem = itemRefresh
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let ip = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: ip, animated: true)
        }
    }
    
    // MARK: Actions

    private func resetOriginalConfiguration() {
        guard let originalURL = originalConfigurationURL else {
            log.warning("Resetting with no original configuration set? Bad table model?")
            return
        }
        let parsingResult: ConfigurationParser.Result
        do {
            parsingResult = try ConfigurationParser.parsed(fromURL: originalURL)
        } catch let e {
            log.error("Could not parse original configuration: \(e)")
            return
        }
        configuration = parsingResult.configuration.builder()
        itemRefresh.isEnabled = !configuration.canCommunicate(with: initialConfiguration)
        initialConfiguration = parsingResult.configuration
        tableView.reloadData()

        delegate?.configuration(didUpdate: initialConfiguration)
    }

    @IBAction private func refresh() {
        guard isEditable else {
            return
        }
        initialConfiguration = configuration.build()
        itemRefresh.isEnabled = false
        
        delegate?.configurationShouldReinstall()
    }
}

// MARK: -

extension ConfigurationViewController: UITableViewDataSource, UITableViewDelegate {
    enum SectionType: Int {
        case communication

        case reset

        case tls
        
        case compression
        
        case network
        
        case other
    }
    
    enum RowType: Int {
        case cipher
        
        case digest
        
        case resetOriginal

        case client
        
        case tlsWrapping
        
        case eku

        case compressionFraming
        
        case compressionAlgorithm
        
        case defaultGateway
        
        case dnsServer
        
        case dnsDomain
        
        case httpProxy
        
        case httpsProxy
        
        case keepAlive
        
        case renegSeconds

        case randomEndpoint
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(for: section)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.footer(for: section)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return model.headerHeight(for: section)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = model.row(at: indexPath)
        let V = L10n.Configuration.Cells.self

        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        if !isEditable {
            cell.accessoryType = .none
        }
        cell.isTappable = isEditable
        switch row {
        case .cipher:
            cell.leftText = L10n.Configuration.Cells.Cipher.caption
            cell.rightText = configuration.fallbackCipher.description
            
        case .digest:
            cell.leftText = L10n.Configuration.Cells.Digest.caption
            cell.rightText = configuration.fallbackDigest.description

        case .resetOriginal:
            cell.leftText = L10n.Configuration.Cells.ResetOriginal.caption
            cell.applyAction(Theme.current)
            
        case .client:
            cell.leftText = L10n.Configuration.Cells.Client.caption
            cell.rightText = (configuration.clientCertificate != nil) ? L10n.Configuration.Cells.Client.Value.enabled : L10n.Configuration.Cells.Client.Value.disabled
            cell.accessoryType = .none
            cell.isTappable = false
            
        case .tlsWrapping:
            cell.leftText = L10n.Configuration.Cells.TlsWrapping.caption
            if let strategy = configuration.tlsWrap?.strategy {
                switch strategy {
                case .auth:
                    cell.rightText = V.TlsWrapping.Value.auth

                case .crypt:
                    cell.rightText = V.TlsWrapping.Value.crypt
                }
            } else {
                cell.rightText = V.All.Value.disabled
            }
            cell.accessoryType = .none
            cell.isTappable = false
            
        case .eku:
            cell.leftText = V.Eku.caption
            cell.rightText = (configuration.checksEKU ?? false) ? V.All.Value.enabled : V.All.Value.disabled
            cell.accessoryType = .none
            cell.isTappable = false

        case .compressionFraming:
            cell.leftText = L10n.Configuration.Cells.CompressionFraming.caption
            cell.rightText = configuration.fallbackCompressionFraming.cellDescription
            cell.accessoryType = .none
            cell.isTappable = false

        case .compressionAlgorithm:
            cell.leftText = L10n.Configuration.Cells.CompressionAlgorithm.caption
            if let compressionAlgorithm = configuration.compressionAlgorithm {
                cell.rightText = compressionAlgorithm.cellDescription
            } else {
                cell.rightText = V.All.Value.disabled
            }
            cell.accessoryType = .none
            cell.isTappable = false
            
        case .defaultGateway:
            cell.leftText = L10n.Configuration.Cells.DefaultGateway.caption
            if let policies = configuration.routingPolicies {
                cell.rightText = policies.map { $0.rawValue }.joined(separator: " / ")
            } else {
                cell.rightText = V.All.Value.none
            }
            cell.accessoryType = .none
            cell.isTappable = false

        case .dnsServer:
            guard let dnsServers = configuration.dnsServers else {
                fatalError("Showing DNS section without any custom server")
            }
            cell.leftText = L10n.Configuration.Cells.DnsServer.caption
            cell.rightText = dnsServers[indexPath.row - 1]
            cell.accessoryType = .none
            cell.isTappable = false
            
        case .dnsDomain:
            cell.leftText = L10n.Configuration.Cells.DnsDomain.caption
            cell.rightText = configuration.searchDomain ?? L10n.Configuration.Cells.All.Value.none
            cell.accessoryType = .none
            cell.isTappable = false

        case .httpProxy:
            cell.leftText = L10n.Configuration.Cells.ProxyHttp.caption
            cell.rightText = configuration.httpProxy?.description ?? L10n.Configuration.Cells.All.Value.none
            cell.accessoryType = .none
            cell.isTappable = false
            
        case .httpsProxy:
            cell.leftText = L10n.Configuration.Cells.ProxyHttps.caption
            cell.rightText = configuration.httpsProxy?.description ?? L10n.Configuration.Cells.All.Value.none
            cell.accessoryType = .none
            cell.isTappable = false
            
        case .keepAlive:
            cell.leftText = L10n.Configuration.Cells.KeepAlive.caption
            if let keepAlive = configuration.keepAliveInterval, keepAlive > 0 {
                cell.rightText = V.KeepAlive.Value.seconds(Int(keepAlive))
            } else {
                cell.rightText = V.All.Value.disabled
            }
            cell.accessoryType = .none
            cell.isTappable = false

        case .renegSeconds:
            cell.leftText = L10n.Configuration.Cells.RenegotiationSeconds.caption
            if let reneg = configuration.renegotiatesAfter, reneg > 0 {
                cell.rightText = V.RenegotiationSeconds.Value.after(TimeInterval(reneg).localized)
            } else {
                cell.rightText = V.All.Value.disabled
            }
            cell.accessoryType = .none
            cell.isTappable = false

        case .randomEndpoint:
            cell.leftText = V.RandomEndpoint.caption
            cell.rightText = (configuration.randomizeEndpoint ?? false) ? V.All.Value.enabled : V.All.Value.disabled
            cell.accessoryType = .none
            cell.isTappable = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isEditable else {
            fatalError("Table should not allow selection when isEditable is false")
        }
        
        let settingCell = tableView.cellForRow(at: indexPath) as? SettingTableViewCell
        
        switch model.row(at: indexPath) {
        case .cipher:
            let vc = OptionViewController<SessionProxy.Cipher>()
            vc.title = settingCell?.leftText
            vc.options = [.aes128cbc, .aes192cbc, .aes256cbc, .aes128gcm, .aes192gcm, .aes256gcm]
            vc.selectedOption = configuration.cipher
            vc.descriptionBlock = { $0.description }
            vc.selectionBlock = { [weak self] in
                self?.configuration.cipher = $0
                self?.popAndCheckRefresh()
            }
            navigationController?.pushViewController(vc, animated: true)
            
        case .digest:
            let vc = OptionViewController<SessionProxy.Digest>()
            vc.title = settingCell?.leftText
            vc.options = [.sha1, .sha224, .sha256, .sha384, .sha512]
            vc.selectedOption = configuration.digest
            vc.descriptionBlock = { $0.description }
            vc.selectionBlock = { [weak self] in
                self?.configuration.digest = $0
                self?.popAndCheckRefresh()
            }
            navigationController?.pushViewController(vc, animated: true)

//        case .compressionFraming:
//            let vc = OptionViewController<SessionProxy.CompressionFraming>()
//            vc.title = settingCell?.leftText
//            vc.options = [.disabled, .compLZO, .compress]
//            vc.selectedOption = configuration.compressionFraming
//            vc.descriptionBlock = { $0.cellDescription }
//            vc.selectionBlock = { [weak self] in
//                self?.configuration.compressionFraming = $0
//                self?.popAndCheckRefresh()
//            }
//            navigationController?.pushViewController(vc, animated: true)

        case .resetOriginal:
            tableView.deselectRow(at: indexPath, animated: true)
            resetOriginalConfiguration()
            
        default:
            break
        }
    }

    // MARK: Helpers
    
    private func popAndCheckRefresh() {
        itemRefresh.isEnabled = !configuration.canCommunicate(with: initialConfiguration)
        tableView.reloadData()
        navigationController?.popViewController(animated: true)

        delegate?.configuration(didUpdate: configuration.build())
    }
}

// MARK: -

private extension SessionProxy.CompressionFraming {
    var cellDescription: String {
        let V = L10n.Configuration.Cells.self
        switch self {
        case .disabled:
            return V.All.Value.disabled
            
        case .compLZO:
            return V.CompressionFraming.Value.lzo
            
        case .compress:
            return V.CompressionFraming.Value.compress
        }
    }
}

private extension SessionProxy.CompressionAlgorithm {
    var cellDescription: String {
        let V = L10n.Configuration.Cells.self
        switch self {
        case .disabled:
            return V.All.Value.disabled
            
        case .LZO:
            return V.CompressionAlgorithm.Value.lzo
            
        case .other:
            return V.CompressionAlgorithm.Value.other
        }
    }
}
