//
//  Theme.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 6/14/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
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
        var colorPrimaryBackground = UIColor(rgb: 0x515d71, alpha: 1.0)
        
        var colorAccent1 = UIColor(rgb: 0xd69c68, alpha: 1.0)

        var colorPrimaryText: UIColor = .darkText
        
        var colorPrimaryLightText: UIColor = .white
        
        var colorSecondaryText: UIColor = .gray

        var colorOn: UIColor {
            return colorAccent1
        }
        
        var colorIndeterminate: UIColor {
            return colorSecondaryText
        }
        
        var colorOff: UIColor {
            return colorSecondaryText
        }
        
//        var colorAction = UIColor(red: 214.0 / 255.0, green: 156.0 / 255.0, blue: 104.0 / 255.0, alpha: 1.0)
        var colorAction: UIColor {
            return colorAccent1
        }

        var colorAccessory: UIColor {
            return colorAccent1.withAlphaComponent(0.7)
        }
        
        var colorDestructive = UIColor(red: 0.8, green: 0.27, blue: 0.2, alpha: 1.0)
    }

    static let current = Theme()
    
    var palette: Palette

    var masterTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode

    var detailTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode
    
    private init() {
        palette = Palette()
        masterTitleDisplayMode = .never
        detailTitleDisplayMode = .never
    }
}

extension Theme {
    func applyAppearance() {
        let bar = UINavigationBar.appearance()
        bar.barTintColor = palette.colorPrimaryBackground
        bar.tintColor = palette.colorPrimaryLightText
        bar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: palette.colorPrimaryLightText]
        bar.largeTitleTextAttributes = bar.titleTextAttributes

        let toolbar = UIToolbar.appearance()
        toolbar.barTintColor = palette.colorPrimaryBackground
        toolbar.tintColor = palette.colorPrimaryLightText
        
        let toggle = UISwitch.appearance()
        toggle.onTintColor = palette.colorAccessory
    }
}

extension UIView {
    func applyPrimaryBackground(_ theme: Theme) {
        backgroundColor = theme.palette.colorPrimaryBackground
    }
}

extension UILabel {
    func apply(_ theme: Theme) {
        textColor = theme.palette.colorPrimaryText
    }

    func applyLight(_ theme: Theme) {
        textColor = theme.palette.colorPrimaryLightText
    }
}

extension UIButton {
    func apply(_ theme: Theme) {
        tintColor = theme.palette.colorAction
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

// XXX: status bar is broken
extension MFMailComposeViewController {
    func apply(_ theme: Theme) {
        let bar = navigationBar
        bar.barTintColor = theme.palette.colorPrimaryBackground
        bar.tintColor = theme.palette.colorPrimaryLightText
        bar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.palette.colorPrimaryLightText]
        bar.largeTitleTextAttributes = bar.titleTextAttributes
    }
}
