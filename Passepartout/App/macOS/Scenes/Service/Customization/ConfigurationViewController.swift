//
//  ConfigurationViewController.swift
//  Passepartout
//
//  Created by Davide De Rosa on 5/31/19.
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

import Cocoa
import PassepartoutConstants
import PassepartoutCore
import TunnelKitOpenVPN

class ConfigurationViewController: NSViewController, ProfileCustomization {
    private struct Columns {
        static let name = NSUserInterfaceItemIdentifier("Name")

        static let value = NSUserInterfaceItemIdentifier("Value")
    }

    @IBOutlet private weak var labelPresetCaption: NSTextField!

    @IBOutlet private weak var popupPreset: NSPopUpButton!
    
    @IBOutlet private weak var tableConfiguration: NSTableView!
    
    private lazy var allPresets: [InfrastructurePreset] = {
        guard let providerProfile = profile as? ProviderConnectionProfile else {
            return []
        }
        let infra = providerProfile.infrastructure
        return providerProfile.pool?.supportedPresetIds(in: infra).map {
            return infra.preset(for: $0)!
        } ?? []
    }()
    
    private var preset: InfrastructurePreset? {
        didSet {
            guard let preset = preset else {
                return
            }
            configuration = preset.configuration.sessionConfiguration.builder()
        }
    }
    
    private var configuration = OpenVPN.ConfigurationBuilder()
    
    private let rows: [RowType] = [
        .cipher,
        .digest,
        .xorMask,
        .compressionFraming,
        .compressionAlgorithm,
        .client,
        .tlsWrapping,
        .eku,
        .keepAlive,
        .renegSeconds,
        .randomEndpoint
    ]
    
    private var rowMenus: [RowType: NSMenu] = [:]

    // MARK: ProfileCustomization
    
    var profile: ConnectionProfile? {
        didSet {
            if let providerProfile = profile as? ProviderConnectionProfile {
                preset = providerProfile.preset
            } else if let hostProfile = profile as? HostConnectionProfile {
                configuration = hostProfile.parameters.sessionConfiguration.builder()
            }
        }
    }
    
    weak var delegate: ProfileCustomizationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelPresetCaption.stringValue = L10n.Service.Cells.Provider.Preset.caption.asCaption
        popupPreset.removeAllItems()
        if !allPresets.isEmpty {
            for preset in allPresets {
                popupPreset.addItem(withTitle: preset.name)
            }
        } else {
            popupPreset.addItem(withTitle: L10n.Global.Values.default)
            popupPreset.isEnabled = false
        }
        
        reloadModel()
    }
    
    private func reloadModel() {
        if let index = allPresets.firstIndex(where: { $0.id == preset?.id }) {
            popupPreset.selectItem(at: index)
        }
        var availableCiphers: [OpenVPN.Cipher]
        let availableDigests: [OpenVPN.Digest]
        let availableCF: [OpenVPN.CompressionFraming]
        let availableCA: [OpenVPN.CompressionAlgorithm]
        if let _ = profile as? HostConnectionProfile {
            availableCiphers = configuration.dataCiphers ?? []
            if !availableCiphers.isEmpty {
                if let cipher = configuration.cipher, !availableCiphers.contains(cipher) {
                    availableCiphers.append(cipher)
                }
            } else {
                availableCiphers.append(contentsOf: OpenVPN.Cipher.available)
            }
            availableDigests = OpenVPN.Digest.available
            availableCF = OpenVPN.CompressionFraming.available
            availableCA = OpenVPN.CompressionAlgorithm.available
        } else {
            availableCiphers = [configuration.fallbackCipher]
            availableDigests = [configuration.fallbackDigest]
            availableCF = [configuration.fallbackCompressionFraming]
            availableCA = [configuration.fallbackCompressionAlgorithm]
        }

        // editable
        rowMenus[.cipher] = NSMenu.withDescriptibles(availableCiphers)
        rowMenus[.digest] = NSMenu.withDescriptibles(availableDigests)
        rowMenus[.compressionFraming] = NSMenu.withDescriptibles(availableCF)
        rowMenus[.compressionAlgorithm] = NSMenu.withDescriptibles(availableCA)

        // single-option menus (unselectable)
        rowMenus[.client] = NSMenu.withString(configuration.uiDescriptionForClientCertificate)
        rowMenus[.tlsWrapping] = NSMenu.withString(configuration.uiDescriptionForTLSWrap)
        rowMenus[.eku] = NSMenu.withString(configuration.uiDescriptionForEKU)
        rowMenus[.keepAlive] = NSMenu.withString(configuration.uiDescriptionForKeepAlive)
        rowMenus[.renegSeconds] = NSMenu.withString(configuration.uiDescriptionForRenegotiatesAfter)
        rowMenus[.randomEndpoint] = NSMenu.withString(configuration.uiDescriptionForRandomizeEndpoint)
        rowMenus[.xorMask] = NSMenu.withString(configuration.uiDescriptionForXOR)
    }

    // MARK: Actions

    @IBAction private func selectPreset(_ sender: Any?) {
        let preset = allPresets[popupPreset.indexOfSelectedItem]
        self.preset = preset
        reloadModel()
        delegate?.profileCustomization(self, didUpdatePreset: preset)
        tableConfiguration.reloadData()
    }
}

extension ConfigurationViewController: NSTableViewDataSource, NSTableViewDelegate {
    enum RowType: Int {
//        case resetOriginal

        case cipher
        
        case digest
        
        case compressionFraming
        
        case compressionAlgorithm
        
        case client
        
        case tlsWrapping
        
        case eku

        case keepAlive
        
        case renegSeconds

        case randomEndpoint
        
        case xorMask
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let V = L10n.Configuration.Cells.self
        let rowObject = rows[row]

        switch tableColumn?.identifier {
        case Columns.name:
            switch rowObject {
            case .cipher:
                return V.Cipher.caption
                
            case .digest:
                return V.Digest.caption
                
            case .compressionFraming:
                return V.CompressionFraming.caption
                
            case .compressionAlgorithm:
                return V.CompressionAlgorithm.caption
                
            case .client:
                return V.Client.caption
                
            case .tlsWrapping:
                return V.TlsWrapping.caption
                
            case .eku:
                return V.Eku.caption
                
            case .keepAlive:
                return V.KeepAlive.caption
                
            case .renegSeconds:
                return V.RenegotiationSeconds.caption
            
            case .randomEndpoint:
                return V.RandomEndpoint.caption
                
            case .xorMask:
                return "XOR"
            }
            
        case Columns.value:
            guard let menu = rowMenus[rowObject], let cell = tableColumn?.dataCell(forRow: row) as? NSPopUpButtonCell else {
                break
            }
            cell.menu = menu
            cell.imageDimsWhenDisabled = false
            if menu.numberOfItems > 1 {
                cell.arrowPosition = .arrowAtBottom
                cell.isEnabled = true
            } else {
                cell.arrowPosition = .noArrow
                cell.isEnabled = false
            }
            switch rowObject {
            case .cipher:
                return menu.indexOfItem(withRepresentedObject: configuration.fallbackCipher)

            case .digest:
                return menu.indexOfItem(withRepresentedObject: configuration.fallbackDigest)

            case .compressionFraming:
                return menu.indexOfItem(withRepresentedObject: configuration.fallbackCompressionFraming)

            case .compressionAlgorithm:
                return menu.indexOfItem(withRepresentedObject: configuration.fallbackCompressionAlgorithm)

            default:
                return 0
            }
            
        default:
            break
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        switch tableColumn?.identifier {
        case Columns.value:
            let rowObject = rows[row]
            guard let menu = rowMenus[rowObject], let optionIndex = object as? Int else {
                return
            }
            let optionObject = menu.item(at: optionIndex)?.representedObject
            switch rowObject {
            case .cipher:
                configuration.cipher = optionObject as? OpenVPN.Cipher

            case .digest:
                configuration.digest = optionObject as? OpenVPN.Digest

            case .compressionFraming:
                guard let option = optionObject as? OpenVPN.CompressionFraming else {
                    return
                }
                configuration.compressionFraming = option
                if option == .disabled {
                    configuration.compressionAlgorithm = .disabled
                }

            case .compressionAlgorithm:
                guard let option = optionObject as? OpenVPN.CompressionAlgorithm else {
                    return
                }
                if configuration.compressionFraming == .disabled && option != .disabled {
                    configuration.compressionFraming = .compLZO
                }
                configuration.compressionAlgorithm = option

            default:
                break
            }
            delegate?.profileCustomization(self, didUpdateConfiguration: configuration)

        default:
            break
        }
    }
}
