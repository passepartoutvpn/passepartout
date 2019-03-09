//
//  Macros.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 6/16/18.
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

class Macros {
    static func alert(_ title: String?, _ message: String?) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
    
    static func actionSheet(_ title: String?, _ message: String?) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    }
}

extension UIAlertController {
    @discardableResult func addDefaultAction(_ title: String, handler: @escaping () -> Void) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: .default) { (action) in
            handler()
        }
        addAction(action)
        preferredAction = action
        return action
    }
    
    @discardableResult func addCancelAction(_ title: String, handler: (() -> Void)? = nil) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: .cancel) { (action) in
            handler?()
        }
        addAction(action)
        if actions.count == 1 {
            preferredAction = action
        }
        return action
    }
    
    @discardableResult func addAction(_ title: String, handler: @escaping () -> Void) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: .default) { (action) in
            handler()
        }
        addAction(action)
        return action
    }
    
    @discardableResult func addDestructiveAction(_ title: String, handler: @escaping () -> Void) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: .destructive) { (action) in
            handler()
        }
        addAction(action)
        preferredAction = action
        return action
    }
}
