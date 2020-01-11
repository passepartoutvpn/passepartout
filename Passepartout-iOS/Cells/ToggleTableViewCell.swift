//
//  ToggleTableViewCell.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 6/13/18.
//  Copyright (c) 2020 Davide De Rosa. All rights reserved.
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
    static let toggle = ToggleTableViewCell.Provider()
}

protocol ToggleTableViewCellDelegate: class {
    func toggleCell(_: ToggleTableViewCell, didToggleToValue value: Bool)
}

class ToggleTableViewCell: UITableViewCell {
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
    
    var toggle: UISwitch {
        return accessoryView as! UISwitch
    }
    
    var isOn: Bool {
        get {
            return toggle.isOn
        }
        set {
            guard newValue != toggle.isOn else {
                return
            }
            toggle.isOn = newValue
        }
    }
    
    func setOn(_ on: Bool, animated: Bool) {
        guard on != toggle.isOn else {
            return
        }
        toggle.setOn(on, animated: animated)
    }
    
    weak var delegate: ToggleTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(toggleMoved), for: .valueChanged)
        accessoryView = toggle
        selectionStyle = .none
    }
    
    @objc private func toggleMoved() {
        delegate?.toggleCell(self, didToggleToValue: toggle.isOn)
    }
}

extension ToggleTableViewCell {
    class Provider: CellProvider {
        typealias T = ToggleTableViewCell
        
        func dequeue(from tableView: UITableView, for indexPath: IndexPath) -> ToggleTableViewCell {
            let cell = tableView.dequeue(T.self, identifier: Provider.identifier, for: indexPath)
            cell.apply(.current)
            return cell
        }

        func dequeue(from tableView: UITableView, for indexPath: IndexPath, tag: Int, delegate: ToggleTableViewCellDelegate) -> ToggleTableViewCell {
            let cell = tableView.dequeue(T.self, identifier: Provider.identifier, for: indexPath)
            cell.apply(.current)
            cell.tag = tag
            cell.delegate = delegate
            return cell
        }
    }
}
