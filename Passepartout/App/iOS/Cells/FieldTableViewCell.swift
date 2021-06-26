//
//  FieldTableViewCell.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/13/18.
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

import UIKit

extension Cells {
    static let field = FieldTableViewCell.Provider()
}

protocol FieldTableViewCellDelegate: AnyObject {
    func fieldCellDidEdit(_: FieldTableViewCell)

    func fieldCellDidEnter(_: FieldTableViewCell)
}

class FieldTableViewCell: UITableViewCell {
    var caption: String? {
        get {
            return textLabel?.text
        }
        set {
            textLabel?.text = newValue
        }
    }
    
    var captionColor: UIColor? {
        get {
            return textLabel?.textColor
        }
        set {
            textLabel?.textColor = newValue
        }
    }
    
    var captionWidth: CGFloat = 0.0 {
        didSet {
            layoutSubviews()
        }
    }
    
    var allowedCharset: CharacterSet? {
        didSet {
            illegalCharset = allowedCharset?.inverted
        }
    }

    private var illegalCharset: CharacterSet?

    private(set) lazy var field = UITextField()
    
    weak var delegate: FieldTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.textAlignment = .left
        field.delegate = self
        selectionStyle = .none
        contentView.addSubview(field)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        var frame: CGRect
        let label: UILabel = textLabel!

        frame = label.frame
        frame.size.width = captionWidth
        label.frame = frame

        let offset: CGFloat = 15.0
        field.frame = CGRect(
            x: label.frame.maxX,
            y: 0.0,
            width: bounds.size.width - label.frame.maxX - offset,
            height: bounds.size.height
        )
    }
}

extension FieldTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let illegalCharset = illegalCharset else {
            return true
        }
        guard string.rangeOfCharacter(from: illegalCharset) == nil else {
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.fieldCellDidEdit(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.fieldCellDidEnter(self)
        return true
    }
}

extension FieldTableViewCell {
    class Provider: CellProvider {
        typealias T = FieldTableViewCell
        
        func dequeue(from tableView: UITableView, for indexPath: IndexPath) -> FieldTableViewCell {
            let cell = tableView.dequeue(T.self, identifier: Provider.identifier, for: indexPath)
            cell.apply(.current)
            return cell
        }
    }
}
