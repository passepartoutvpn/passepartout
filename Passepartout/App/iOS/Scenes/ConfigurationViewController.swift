//
//  ConfigurationViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/2/18.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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

class ConfigurationViewController: UIViewController, StrongTableHost {
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var itemRefresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))

    var initialConfiguration: OpenVPN.Configuration!
    
    private lazy var configuration: OpenVPN.ConfigurationBuilder = initialConfiguration.builder()
    
    var originalConfigurationURL: URL?

    private var isEditable: Bool {
        return originalConfigurationURL != nil
    }
        
    var isServerPushed = false

    weak var delegate: ConfigurationModificationDelegate?
    
    // MARK: StrongTableHost

    let model: StrongTableModel<SectionType, RowType> = StrongTableModel()

    func reloadModel() {
        model.clear()
        
        // sections
        if isEditable {
            model.add(.reset)
            model.setHeader("", forSection: .reset)
        }

        // headers
        model.setHeader(L10n.Configuration.Sections.Communication.header, forSection: .communication)
        model.setHeader(L10n.Configuration.Sections.Tls.header, forSection: .tls)
        model.setHeader(L10n.Configuration.Sections.Compression.header, forSection: .compression)
        model.setHeader(L10n.Configuration.Sections.Other.header, forSection: .other)

        // footers
        if isEditable {
            model.setFooter(L10n.Configuration.Sections.Reset.footer, forSection: .reset)
        }
        
        // rows
        if isServerPushed {
            var rows: [RowType]

            rows = []
            if let _ = configuration.cipher {
                rows.append(.cipher)
            }
            if let _ = configuration.digest {
                rows.append(.digest)
            }
            if !rows.isEmpty {
                model.add(.communication)
                model.set(rows, forSection: .communication)
            }

            rows = []
            if let _ = configuration.compressionFraming {
                rows.append(.compressionFraming)
            }
            if let _ = configuration.compressionAlgorithm {
                rows.append(.compressionAlgorithm)
            }
            if !rows.isEmpty {
                model.add(.compression)
                model.set(rows, forSection: .compression)
            }

            rows = []
            if let _ = configuration.keepAliveInterval {
                rows.append(.keepAlive)
            }
            if let _ = configuration.renegotiatesAfter {
                rows.append(.renegSeconds)
            }
            if let _ = configuration.randomizeEndpoint {
                rows.append(.randomEndpoint)
            }
            if !rows.isEmpty {
                model.add(.other)
                model.set(rows, forSection: .other)
            }
        } else {
            model.add(.communication)
            model.add(.compression)
            model.add(.tls)
            model.add(.other)
            model.set([.cipher, .digest, .xorMask], forSection: .communication)
            model.set([.compressionFraming, .compressionAlgorithm], forSection: .compression)
            model.set([.keepAlive, .renegSeconds, .randomEndpoint], forSection: .other)
        }
        if isEditable {
            model.set([.resetOriginal], forSection: .reset)
        }
        model.set([.client, .tlsWrapping, .eku], forSection: .tls)
    }
    
    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = initialConfiguration else {
            fatalError("Initial configuration not set")
        }
        reloadModel()

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

    private func resetOriginalConfiguration(passphrase: String? = nil) {
        guard let originalURL = originalConfigurationURL else {
            log.warning("Resetting with no original configuration set? Bad table model?")
            return
        }
        let parsingResult: OpenVPN.ConfigurationParser.Result
        do {
            parsingResult = try OpenVPN.ConfigurationParser.parsed(fromURL: originalURL, passphrase: passphrase)
        } catch let e as ConfigurationError {
            switch e {
            case .encryptionPassphrase:
                log.warning("Configuration is encrypted, ask for passphrase")
                askForResetConfigurationWithPassphrase(originalURL)

            default:
                log.error("Could not parse original configuration: \(e)")
            }
            return
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
    
    private func askForResetConfigurationWithPassphrase(_ originalURL: URL) {
        let alert = UIAlertController.asAlert(nil, L10n.ParsedFile.Alerts.EncryptionPassphrase.message)
        alert.addTextField { (field) in
            field.isSecureTextEntry = true
        }
        alert.addPreferredAction(L10n.Global.ok) {
            guard let passphrase = alert.textFields?.first?.text else {
                return
            }
            self.resetOriginalConfiguration(passphrase: passphrase)
        }
        alert.addCancelAction(L10n.Global.cancel) {
        }
        present(alert, animated: true, completion: nil)
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
        
        case xorMask
        
        case keepAlive
        
        case renegSeconds

        case randomEndpoint
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.header(forSection: section)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model.footer(forSection: section)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return model.headerHeight(for: section)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(forSection: section)
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
        case .resetOriginal:
            cell.leftText = V.ResetOriginal.caption
            cell.applyAction(.current)
            
        case .cipher:
            cell.leftText = V.Cipher.caption
            cell.rightText = configuration.fallbackCipher.uiDescription
            
        case .digest:
            cell.leftText = V.Digest.caption
            cell.rightText = configuration.fallbackDigest.uiDescription

        case .compressionFraming:
            cell.leftText = V.CompressionFraming.caption
            cell.rightText = configuration.fallbackCompressionFraming.uiDescription
            
        case .compressionAlgorithm:
            cell.leftText = V.CompressionAlgorithm.caption
            cell.rightText = configuration.fallbackCompressionAlgorithm.uiDescription
            cell.isTappable = (configuration.compressionFraming != .disabled)
            
        case .client:
            cell.leftText = V.Client.caption
            cell.rightText = configuration.uiDescriptionForClientCertificate
            cell.accessoryType = .none
            cell.isTappable = false
            
        case .tlsWrapping:
            cell.leftText = V.TlsWrapping.caption
            cell.rightText = configuration.uiDescriptionForTLSWrap
            cell.accessoryType = .none
            cell.isTappable = false
            
        case .eku:
            cell.leftText = V.Eku.caption
            cell.rightText = configuration.uiDescriptionForEKU
            cell.accessoryType = .none
            cell.isTappable = false

        case .keepAlive:
            cell.leftText = V.KeepAlive.caption
            cell.rightText = configuration.uiDescriptionForKeepAlive
            cell.accessoryType = .none
            cell.isTappable = false

        case .renegSeconds:
            cell.leftText = V.RenegotiationSeconds.caption
            cell.rightText = configuration.uiDescriptionForRenegotiatesAfter
            cell.accessoryType = .none
            cell.isTappable = false

        case .randomEndpoint:
            cell.leftText = V.RandomEndpoint.caption
            cell.rightText = configuration.uiDescriptionForRandomizeEndpoint
            cell.accessoryType = .none
            cell.isTappable = false

        case .xorMask:
            cell.leftText = "XOR"
            cell.rightText = configuration.uiDescriptionForXOR
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
            var options: [OpenVPN.Cipher] = configuration.dataCiphers ?? []
            if !options.isEmpty {
                if let cipher = configuration.cipher, !options.contains(cipher) {
                    options.append(cipher)
                }
            } else {
                options.append(contentsOf: OpenVPN.Cipher.available)
            }
            
            let vc = SingleOptionViewController<OpenVPN.Cipher>()
            vc.applyTint(.current)
            vc.title = settingCell?.leftText
            vc.options = options
            vc.selectedOption = configuration.cipher
            vc.descriptionBlock = { $0.uiDescription }
            vc.selectionBlock = { [weak self] in
                self?.configuration.cipher = $0
                self?.popAndCheckRefresh()
            }
            navigationController?.pushViewController(vc, animated: true)
            
        case .digest:
            let vc = SingleOptionViewController<OpenVPN.Digest>()
            vc.applyTint(.current)
            vc.title = settingCell?.leftText
            vc.options = OpenVPN.Digest.available
            vc.selectedOption = configuration.digest
            vc.descriptionBlock = { $0.uiDescription }
            vc.selectionBlock = { [weak self] in
                self?.configuration.digest = $0
                self?.popAndCheckRefresh()
            }
            navigationController?.pushViewController(vc, animated: true)

        case .compressionFraming:
            let vc = SingleOptionViewController<OpenVPN.CompressionFraming>()
            vc.applyTint(.current)
            vc.title = settingCell?.leftText
            vc.options = OpenVPN.CompressionFraming.available
            vc.selectedOption = configuration.compressionFraming ?? .disabled
            vc.descriptionBlock = { $0.uiDescription }
            vc.selectionBlock = { [weak self] in
                self?.configuration.compressionFraming = $0
                if $0 == .disabled {
                    self?.configuration.compressionAlgorithm = .disabled
                }
                self?.popAndCheckRefresh()
            }
            navigationController?.pushViewController(vc, animated: true)

        case .compressionAlgorithm:
            guard configuration.compressionFraming != .disabled else {
                return
            }
            
            let vc = SingleOptionViewController<OpenVPN.CompressionAlgorithm>()
            vc.applyTint(.current)
            vc.title = settingCell?.leftText
            vc.options = OpenVPN.CompressionAlgorithm.available
            vc.selectedOption = configuration.compressionAlgorithm ?? .disabled
            vc.descriptionBlock = { $0.uiDescription }
            vc.selectionBlock = { [weak self] in
                self?.configuration.compressionAlgorithm = $0
                self?.popAndCheckRefresh()
            }
            navigationController?.pushViewController(vc, animated: true)
            
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
