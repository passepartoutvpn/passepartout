//
//  ConfigurationViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/2/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
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
        model.add(.other)

        // headers
        model.setHeader(L10n.Configuration.Sections.Communication.header, for: .communication)
        model.setHeader(L10n.Configuration.Sections.Tls.header, for: .tls)
        model.setHeader(L10n.Configuration.Sections.Other.header, for: .other)

        // footers
        if isEditable {
            model.setFooter(L10n.Configuration.Sections.Reset.footer, for: .reset)
        }
        
        // rows
        model.set([.cipher, .digest, .compressionFrame], in: .communication)
        if isEditable {
            model.set([.resetOriginal], in: .reset)
        }
        model.set([.client, .tlsWrapping], in: .tls)
        model.set([.compressionAlgorithm, .keepAlive, .renegSeconds], in: .other)

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
        let parsedFile: ParsedFile
        do {
            parsedFile = try TunnelKitProvider.Configuration.parsed(from: originalURL)
        } catch let e {
            log.error("Could not parse original configuration: \(e)")
            return
        }
        configuration = parsedFile.configuration.sessionConfiguration.builder()
        itemRefresh.isEnabled = !configuration.canCommunicate(with: initialConfiguration)
        initialConfiguration = parsedFile.configuration.sessionConfiguration
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
        
        case other
    }
    
    enum RowType: Int {
        case cipher
        
        case digest
        
        case compressionFrame
        
        case resetOriginal

        case client
        
        case tlsWrapping
        
        case compressionAlgorithm
        
        case keepAlive
        
        case renegSeconds
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
        guard let title = model.header(for: section) else {
            return 1.0
        }
        guard !title.isEmpty else {
            return 0.0
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = model.row(at: indexPath)

        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        if !isEditable {
            cell.accessoryType = .none
        }
        cell.isTappable = isEditable
        switch row {
        case .cipher:
            cell.leftText = L10n.Configuration.Cells.Cipher.caption
            cell.rightText = configuration.cipher.description
            
        case .digest:
            cell.leftText = L10n.Configuration.Cells.Digest.caption
            if !configuration.cipher.embedsDigest {
                cell.rightText = configuration.digest.description
            } else {
                cell.rightText = L10n.Configuration.Cells.Digest.Value.embedded
                cell.accessoryType = .none
                cell.isTappable = false
            }

        case .compressionFrame:
            cell.leftText = L10n.Configuration.Cells.CompressionFrame.caption
            cell.rightText = configuration.compressionFraming.cellDescription
            
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
            let V = L10n.Configuration.Cells.TlsWrapping.Value.self
            if let strategy = configuration.tlsWrap?.strategy {
                switch strategy {
                case .auth:
                    cell.rightText = V.auth

                case .crypt:
                    cell.rightText = V.crypt
                }
            } else {
                cell.rightText = V.disabled
            }
            cell.accessoryType = .none
            cell.isTappable = false

        case .compressionAlgorithm:
            cell.leftText = L10n.Configuration.Cells.CompressionAlgorithm.caption
            cell.rightText = L10n.Configuration.Cells.CompressionAlgorithm.Value.disabled // hardcoded because compression unsupported
            cell.accessoryType = .none
            cell.isTappable = false
            
        case .keepAlive:
            cell.leftText = L10n.Configuration.Cells.KeepAlive.caption
            let V = L10n.Configuration.Cells.KeepAlive.Value.self
            if let keepAlive = configuration.keepAliveInterval, keepAlive > 0 {
                cell.rightText = V.seconds(Int(keepAlive))
            } else {
                cell.rightText = V.never
            }
            cell.accessoryType = .none
            cell.isTappable = false

        case .renegSeconds:
            cell.leftText = L10n.Configuration.Cells.RenegotiationSeconds.caption
            let V = L10n.Configuration.Cells.RenegotiationSeconds.Value.self
            if let reneg = configuration.renegotiatesAfter, reneg > 0 {
                cell.rightText = V.after(TimeInterval(reneg).localized)
            } else {
                cell.rightText = V.never
            }
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
            guard !configuration.cipher.embedsDigest else {
                return
            }
            
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

        case .compressionFrame:
            let vc = OptionViewController<SessionProxy.CompressionFraming>()
            vc.title = settingCell?.leftText
            vc.options = [.disabled, .compLZO, .compress]
            vc.selectedOption = configuration.compressionFraming
            vc.descriptionBlock = { $0.cellDescription }
            vc.selectionBlock = { [weak self] in
                self?.configuration.compressionFraming = $0
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

// MARK: -

private extension SessionProxy.CompressionFraming {
    var cellDescription: String {
        let V = L10n.Configuration.Cells.CompressionFrame.Value.self
        switch self {
        case .disabled:
            return V.disabled
            
        case .compLZO:
            return V.lzo
            
        case .compress:
            return V.compress
        }
    }
}
