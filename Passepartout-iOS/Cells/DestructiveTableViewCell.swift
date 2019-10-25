//
//  DestructiveTableViewCell.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 6/22/18.
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

extension Cells {
    static let destructive = DestructiveTableViewCell.Provider()
}

class DestructiveTableViewCell: UITableViewCell {
    @IBOutlet private lazy var labelCaption: UILabel? = {
        let label = UILabel()
        label.textAlignment = .center
        contentView.addSubview(label)
        return label
    }()

    var caption: String? {
        get {
            return labelCaption?.text
        }
        set {
            labelCaption?.text = newValue
        }
    }
    
    var captionColor: UIColor? {
        get {
            return labelCaption?.textColor
        }
        set {
            labelCaption?.textColor = newValue
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        labelCaption?.frame = contentView.bounds
    }
}

extension DestructiveTableViewCell {
    class Provider: CellProvider {
        typealias T = DestructiveTableViewCell
        
        func dequeue(from tableView: UITableView, for indexPath: IndexPath) -> DestructiveTableViewCell {
            let cell = tableView.dequeue(T.self, identifier: Provider.identifier, for: indexPath)
            cell.apply(.current)
            return cell
        }
    }
}
