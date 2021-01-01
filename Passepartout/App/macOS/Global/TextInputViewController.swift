//
//  TextInputViewController.swift
//  Passepartout-macOS
//
//  Created by Davide De Rosa on 7/3/19.
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

protocol TextInputViewControllerDelegate: class {
    func textInputController(_ textInputController: TextInputViewController, shouldEnterText text: String) -> Bool
    
    func textInputController(_ textInputController: TextInputViewController, didEnterText text: String)
}

class TextInputViewController: NSViewController {
    @IBOutlet private weak var labelTextCaption: NSTextField!

    @IBOutlet private weak var textPlain: NSTextField!
    
    @IBOutlet private weak var textSecure: NSSecureTextField!

    private var textField: NSTextField {
        guard !isSecure else {
            return textSecure
        }
        return textPlain
    }

    @IBOutlet private weak var buttonOK: NSButton!
    
    @IBOutlet private weak var buttonCancel: NSButton!
    
    var caption = ""

    var text = ""
    
    var placeholder: String?
    
    var isSecure = false

    var object: Any?
    
    weak var delegate: TextInputViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        labelTextCaption.stringValue = caption
        textField.stringValue = text
        textField.placeholderString = placeholder
        buttonOK.title = L10n.Core.Global.ok
        buttonCancel.title = L10n.Core.Global.cancel

        textPlain.isHidden = isSecure
        textSecure.isHidden = !isSecure
    }
    
    @IBAction private func confirm(_ sender: Any?) {
        let text = textField.stringValue
        if let delegate = delegate {
            guard delegate.textInputController(self, shouldEnterText: text) else {
                textField.becomeFirstResponder()
                return
            }
        }
        delegate?.textInputController(self, didEnterText: text)
    }

    override func cancelOperation(_ sender: Any?) {
        dismiss(sender)
    }
}
