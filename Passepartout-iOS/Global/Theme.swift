//
//  Theme.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 6/14/18.
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
import MessageUI
import StoreKit
import Passepartout_Core

extension UIColor {
    convenience init(rgb: UInt32, alpha: CGFloat) {
        let r = CGFloat((rgb & 0xff0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0xff00) >> 8) / 255.0
        let b = CGFloat(rgb & 0xff) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

struct Theme {
    struct Palette {
        var primaryBackground = UIColor(rgb: 0x515d71, alpha: 1.0)
        
        var accent1 = UIColor(rgb: 0xd69c68, alpha: 1.0)

        var primaryText: UIColor = .darkText
        
        var primaryLightText: UIColor = .white
        
        var secondaryText: UIColor = .gray

        var on: UIColor {
            return accent1
        }
        
        var indeterminate: UIColor {
            return secondaryText
        }
        
        var off: UIColor {
            return secondaryText
        }
        
//        var action = UIColor(red: 214.0 / 255.0, green: 156.0 / 255.0, blue: 104.0 / 255.0, alpha: 1.0)
        var action: UIColor {
            return accent1
        }

        var accessory: UIColor {
            return accent1.withAlphaComponent(0.7)
        }
        
        var destructive = UIColor(red: 0.8, green: 0.27, blue: 0.2, alpha: 1.0)
    }

    static let current = Theme()
    
    var palette: Palette

    var masterTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode

    var detailTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode
    
    var modalPresentationStyle: UIModalPresentationStyle
    
    private init() {
        palette = Palette()
        masterTitleDisplayMode = .never
        detailTitleDisplayMode = .never
        modalPresentationStyle = .formSheet
    }
}

extension Theme {
    func applyAppearance() {
        let bar = UINavigationBar.appearance()
        bar.barTintColor = palette.primaryBackground
        bar.tintColor = palette.primaryLightText
        bar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: palette.primaryLightText]
        bar.largeTitleTextAttributes = bar.titleTextAttributes

        let toolbar = UIToolbar.appearance()
        toolbar.barTintColor = palette.primaryBackground
        toolbar.tintColor = palette.primaryLightText
        
        let toggle = UISwitch.appearance()
        toggle.onTintColor = palette.accessory
        
        let activity = UIActivityIndicatorView.appearance()
        activity.color = palette.accessory
    }
}

extension UIView {
    func applyPrimaryBackground(_ theme: Theme) {
        backgroundColor = theme.palette.primaryBackground
    }
}

extension UILabel {
    func apply(_ theme: Theme) {
        textColor = theme.palette.primaryText
    }

    func applyLight(_ theme: Theme) {
        textColor = theme.palette.primaryLightText
    }
}

extension UIButton {
    func apply(_ theme: Theme) {
        tintColor = theme.palette.action
    }
}

extension UITextField {
    func applyProfileId(_ theme: Theme) {
        placeholder = L10n.Global.Host.TitleInput.placeholder
        clearButtonMode = .always
        keyboardType = .asciiCapable
        returnKeyType = .done
        autocapitalizationType = .none
        autocorrectionType = .no
    }
}

extension UIActivityIndicatorView {
    func applyAccent(_ theme: Theme) {
        color = theme.palette.accent1
    }
}

// XXX: status bar is broken
extension MFMailComposeViewController {
    func apply(_ theme: Theme) {
        modalPresentationStyle = theme.modalPresentationStyle
        
        let bar = navigationBar
        bar.barTintColor = theme.palette.primaryBackground
        bar.tintColor = theme.palette.primaryLightText
        bar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.palette.primaryLightText]
        bar.largeTitleTextAttributes = bar.titleTextAttributes
    }
}

extension Infrastructure.Name {
    var logo: UIImage? {
        return ImageAsset(name: rawValue.lowercased()).image
    }
}

extension PoolGroup {
    var logo: UIImage? {
        return ImageAsset(name: country.lowercased()).image
    }
}

extension SKProduct {
    var localizedPrice: String? {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.locale = priceLocale
        return fmt.string(from: price)
    }
}
