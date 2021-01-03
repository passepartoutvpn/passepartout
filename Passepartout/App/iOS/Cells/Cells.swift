//
//  Cells.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/25/18.
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

struct Cells {
}

extension UITableView {
    func dequeue<T: UITableViewCell>(_ type: T.Type, identifier: String, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Not a \(T.description())")
        }
        return cell
    }
}

protocol CellProvider {
    associatedtype T: UITableViewCell
    
    static var identifier: String { get }
    
    func register(with tableView: UITableView)

    func dequeue(from tableView: UITableView, for indexPath: IndexPath) -> T
}

extension CellProvider {
    static var identifier: String {
        return String(describing: T.self)
    }
    
    func register(with tableView: UITableView) {
        tableView.register(T.self, forCellReuseIdentifier: Self.identifier)
    }
}
