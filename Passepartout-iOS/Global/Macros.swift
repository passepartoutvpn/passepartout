//
//  Macros.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 6/16/18.
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

class Macros {
    static func alert(_ title: String?, _ message: String?) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
    
    static func actionSheet(_ title: String?, _ message: String?) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    }

    static var isDeviceNonPlus: Bool {
        return (UI_USER_INTERFACE_IDIOM() == .phone) && (UIScreen.main.scale < 3.0)
    }
}

extension UIAlertController {
    func addDefaultAction(_ title: String, handler: @escaping () -> Void) {
        let action = UIAlertAction(title: title, style: .default) { (action) in
            handler()
        }
        addAction(action)
        preferredAction = action
    }
    
    func addCancelAction(_ title: String, handler: (() -> Void)? = nil) {
        let action = UIAlertAction(title: title, style: .cancel) { (action) in
            handler?()
        }
        addAction(action)
        if actions.count == 1 {
            preferredAction = action
        }
    }
    
    func addDestructiveAction(_ title: String, handler: @escaping () -> Void) {
        let action = UIAlertAction(title: title, style: .destructive) { (action) in
            handler()
        }
        addAction(action)
        preferredAction = action
    }
}
