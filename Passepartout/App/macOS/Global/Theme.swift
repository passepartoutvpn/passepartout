//
//  Theme.swift
//  Passepartout-macOS
//
//  Created by Davide De Rosa on 7/29/18.
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

struct Theme {
    struct Palette {
        var colorPrimaryText: NSColor = .labelColor
        
        var colorSecondaryText: NSColor = .secondaryLabelColor
        
        var colorOff: NSColor = .red
        
        var colorOn = NSColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
        
        var colorIndeterminate: NSColor = .orange
        
        var colorInline = NSColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
    }
    
    static let current = Theme()
    
    var palette: Palette
    
    private init() {
        palette = Palette()
    }
}

// FIXME: load from index JSON
extension Infrastructure.Metadata {
    var logo: NSImage? {
        guard let image = ImageAsset.Image(named: name) else {
            return Asset.Providers.placeholder.image
        }
        return image
    }
}

extension ConnectionProfile {
    var image: NSImage? {
        if let profile = self as? ProviderConnectionProfile {
            return profile.infrastructure.metadata?.logo
        } else {
//            return NSImage(named: NSImage.applicationIconName)//smartBadgeTemplateName)
            return nil
        }
    }
}

extension PoolGroup {
    var logo: NSImage? {
        return ImageAsset(name: country.lowercased()).image
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

extension String {
    var image: NSImage? {
        return ImageAsset(name: lowercased()).image
    }
}
