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
import PassepartoutCore
import TunnelKit

class ConfigurationViewController: NSViewController, ProfileCustomization {
    @IBOutlet private weak var labelPresetCaption: NSTextField!

    @IBOutlet private weak var popupPreset: NSPopUpButton!
    
    @IBOutlet private weak var boxCommunication: NSBox!

    @IBOutlet private weak var labelCipherCaption: NSTextField!
    
    @IBOutlet private weak var popupCipher: NSPopUpButton!
    
    @IBOutlet private weak var labelDigestCaption: NSTextField!
    
    @IBOutlet private weak var popupDigest: NSPopUpButton!
    
    @IBOutlet private weak var boxCompression: NSBox!
    
    @IBOutlet private weak var labelCompressionFramingCaption: NSTextField!
    
    @IBOutlet private weak var popupCompressionFraming: NSPopUpButton!
    
    @IBOutlet private weak var labelCompressionAlgorithmCaption: NSTextField!
    
    @IBOutlet private weak var popupCompressionAlgorithm: NSPopUpButton!

    @IBOutlet private weak var boxTLS: NSBox!
    
    @IBOutlet private weak var labelClientCertificateCaption: NSTextField!
    
    @IBOutlet private weak var labelClientCertificate: NSTextField!
    
    @IBOutlet private weak var labelWrappingCaption: NSTextField!
    
    @IBOutlet private weak var labelWrapping: NSTextField!

    @IBOutlet private weak var labelExtendedVerificationCaption: NSTextField!
    
    @IBOutlet private weak var labelExtendedVerification: NSTextField!
    
    @IBOutlet private weak var boxOther: NSBox!
    
    @IBOutlet private weak var labelKeepAliveCaption: NSTextField!
    
    @IBOutlet private weak var labelKeepAlive: NSTextField!
    
    @IBOutlet private weak var labelRenegotiationCaption: NSTextField!
    
    @IBOutlet private weak var labelRenegotiation: NSTextField!
    
    @IBOutlet private weak var labelRandomizeEndpointCaption: NSTextField!
    
    @IBOutlet private weak var labelRandomizeEndpoint: NSTextField!
    
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
        
        let V = L10n.Core.Configuration.Cells.self
        
        labelPresetCaption.stringValue = L10n.Core.Service.Cells.Provider.Preset.caption.asCaption
        popupPreset.removeAllItems()
        if !allPresets.isEmpty {
            for preset in allPresets {
                popupPreset.addItem(withTitle: preset.name)
            }
            popupCipher.isEnabled = false
            popupDigest.isEnabled = false
            popupCompressionFraming.isEnabled = false
            popupCompressionAlgorithm.isEnabled = false
        } else {
            popupPreset.addItem(withTitle: L10n.App.Global.Values.default)
            popupPreset.isEnabled = false
        }
        
        boxCommunication.title = L10n.Core.Configuration.Sections.Communication.header
        boxCompression.title = L10n.Core.Configuration.Sections.Compression.header
        boxTLS.title = L10n.Core.Configuration.Sections.Tls.header
        boxOther.title = L10n.Core.Configuration.Sections.Other.header

        labelCipherCaption.stringValue = V.Cipher.caption.asCaption
        labelDigestCaption.stringValue = V.Digest.caption.asCaption
        labelCompressionFramingCaption.stringValue = V.CompressionFraming.caption.asCaption
        labelCompressionAlgorithmCaption.stringValue = V.CompressionAlgorithm.caption.asCaption
        labelClientCertificateCaption.stringValue = V.Client.caption.asCaption
        labelWrappingCaption.stringValue = V.TlsWrapping.caption.asCaption
        labelExtendedVerificationCaption.stringValue = V.Eku.caption.asCaption
        labelKeepAliveCaption.stringValue = V.KeepAlive.caption.asCaption
        labelRenegotiationCaption.stringValue = V.RenegotiationSeconds.caption.asCaption
        labelRandomizeEndpointCaption.stringValue = V.RandomEndpoint.caption.asCaption

        popupCipher.removeAllItems()
        popupDigest.removeAllItems()
        popupCompressionFraming.removeAllItems()
        popupCompressionAlgorithm.removeAllItems()
        for cipher in OpenVPN.Cipher.available {
            popupCipher.addItem(withTitle: cipher.rawValue)
        }
        for digest in OpenVPN.Digest.available {
            popupDigest.addItem(withTitle: digest.rawValue)
        }
        for framing in OpenVPN.CompressionFraming.available {
            popupCompressionFraming.addItem(withTitle: framing.itemDescription)
        }
        for algorithm in OpenVPN.CompressionAlgorithm.available {
            popupCompressionAlgorithm.addItem(withTitle: algorithm.itemDescription)
        }
        
        reloadModel()
    }
    
    private func reloadModel() {
        let V = L10n.Core.Configuration.Cells.self

        if let index = allPresets.firstIndex(where: { $0.id == preset?.id }) {
            popupPreset.selectItem(at: index)
        }
        if let index = OpenVPN.Cipher.available.firstIndex(of: configuration.fallbackCipher) {
            popupCipher.selectItem(at: index)
        }
        if let index = OpenVPN.Digest.available.firstIndex(of: configuration.fallbackDigest) {
            popupDigest.selectItem(at: index)
        }
        if let index = OpenVPN.CompressionFraming.available.firstIndex(of: configuration.compressionFraming ?? .disabled) {
            popupCompressionFraming.selectItem(at: index)
        }
        if let index = OpenVPN.CompressionAlgorithm.available.firstIndex(of: configuration.compressionAlgorithm ?? .disabled) {
            popupCompressionAlgorithm.selectItem(at: index)
        }

        // enforce item constraints
        selectCompressionFraming(nil)
        selectCompressionAlgorithm(nil)
        
        labelClientCertificate.stringValue = (configuration.clientCertificate != nil) ? V.Client.Value.enabled : V.Client.Value.disabled
        if let strategy = configuration.tlsWrap?.strategy {
            switch strategy {
            case .auth:
                labelWrapping.stringValue = V.TlsWrapping.Value.auth
                
            case .crypt:
                labelWrapping.stringValue = V.TlsWrapping.Value.crypt
            }
        } else {
            labelWrapping.stringValue = L10n.Core.Global.Values.disabled
        }
        labelExtendedVerification.stringValue = (configuration.checksEKU ?? false) ? L10n.Core.Global.Values.enabled : L10n.Core.Global.Values.disabled
        
        if let keepAlive = configuration.keepAliveInterval, keepAlive > 0 {
            labelKeepAlive.stringValue = V.KeepAlive.Value.seconds(Int(keepAlive))
        } else {
            labelKeepAlive.stringValue = L10n.Core.Global.Values.disabled
        }
        if let reneg = configuration.renegotiatesAfter, reneg > 0 {
            labelRenegotiation.stringValue = V.RenegotiationSeconds.Value.after(TimeInterval(reneg).localized)
        } else {
            labelRenegotiation.stringValue = L10n.Core.Global.Values.disabled
        }
        labelRandomizeEndpoint.stringValue = (configuration.randomizeEndpoint ?? false) ? L10n.Core.Global.Values.enabled : L10n.Core.Global.Values.disabled
    }
    
    // MARK: Actions

    @IBAction private func selectPreset(_ sender: Any?) {
        let preset = allPresets[popupPreset.indexOfSelectedItem]
        self.preset = preset
        reloadModel()
        delegate?.profileCustomization(self, didUpdatePreset: preset)
    }

    @IBAction private func selectCipher(_ sender: Any?) {
        configuration.cipher = OpenVPN.Cipher.available[popupCipher.indexOfSelectedItem]
        delegate?.profileCustomization(self, didUpdateConfiguration: configuration)
    }

    @IBAction private func selectDigest(_ sender: Any?) {
        configuration.digest = OpenVPN.Digest.available[popupDigest.indexOfSelectedItem]
        delegate?.profileCustomization(self, didUpdateConfiguration: configuration)
    }
    
    @IBAction private func selectCompressionFraming(_ sender: Any?) {

        // if framing is disabled, disable algorithm
        if popupCompressionFraming.indexOfSelectedItem == 0 {
            popupCompressionAlgorithm.selectItem(at: 0)
        }

        configuration.compressionFraming = OpenVPN.CompressionFraming.available[popupCompressionFraming.indexOfSelectedItem]
        configuration.compressionAlgorithm = OpenVPN.CompressionAlgorithm.available[popupCompressionAlgorithm.indexOfSelectedItem]
        delegate?.profileCustomization(self, didUpdateConfiguration: configuration)
    }

    @IBAction private func selectCompressionAlgorithm(_ sender: Any?) {

        // if framing is disabled and algorithm is not disabled, enable --comp-lzo framing
        if popupCompressionFraming.indexOfSelectedItem == 0 && popupCompressionAlgorithm.indexOfSelectedItem != 0 {
            popupCompressionFraming.selectItem(at: 1)
        }

        configuration.compressionFraming = OpenVPN.CompressionFraming.available[popupCompressionFraming.indexOfSelectedItem]
        configuration.compressionAlgorithm = OpenVPN.CompressionAlgorithm.available[popupCompressionAlgorithm.indexOfSelectedItem]
        delegate?.profileCustomization(self, didUpdateConfiguration: configuration)
    }
}

// MARK: -

private extension OpenVPN.CompressionFraming {
    var itemDescription: String {
        let V = L10n.Core.Configuration.Cells.self
        switch self {
        case .disabled:
            return L10n.Core.Global.Values.disabled
            
        case .compLZO:
            return V.CompressionFraming.Value.lzo
            
        case .compress:
            return V.CompressionFraming.Value.compress
        }
    }
}

private extension OpenVPN.CompressionAlgorithm {
    var itemDescription: String {
        let V = L10n.Core.Configuration.Cells.self
        switch self {
        case .disabled:
            return L10n.Core.Global.Values.disabled
            
        case .LZO:
            return V.CompressionAlgorithm.Value.lzo
            
        case .other:
            return V.CompressionAlgorithm.Value.other
        }
    }
}
