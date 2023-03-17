//
//  MacBundle.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/19/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

import Foundation

class MacBundle {
    static let shared = MacBundle()

    private var bridge: MacBridge!

    private lazy var bridgeDelegate = MacBundleDelegate(bundle: self)

    @MainActor
    func configure() {
        guard let bundleURL = Bundle.main.builtInPlugInsURL?.appendingPathComponent(Constants.Plugins.macBridgeName) else {
            fatalError("Unable to find Mac bundle in plugins")
        }
        guard let bundle = Bundle(url: bundleURL) else {
            fatalError("Unable to build Mac bundle")
        }
        guard let bridgeClass = bundle.principalClass as? MacBridge.Type else {
            fatalError("Unable to find principal class in Mac bundle")
        }
        bridge = bridgeClass.init()
        bridge.menu.delegate = bridgeDelegate
    }

    var utils: MacUtils {
        bridge.utils
    }

    var menu: MacMenu {
        bridge.menu
    }
}
