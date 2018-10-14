//
//  OptionViewController.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 9/5/18.
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

protocol OptionViewControllerDelegate: class {
    func optionController<T: Hashable>(_: OptionViewController<T>, descriptionFor option: T) -> String

    func optionController<T: Hashable>(_: OptionViewController<T>, didSelect option: T)
}

class OptionViewController<T: Hashable>: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private lazy var tableView = UITableView(frame: .zero, style: .grouped)
    
    var options: [T] = []

    var selectedOption: T?
    
    var descriptionBlock: ((T) -> String)?

    var selectionBlock: ((T) -> Void)?
    
    weak var delegate: OptionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.Provider.identifier)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let opt = options[indexPath.row]
        let cell = Cells.setting.dequeue(from: tableView, for: indexPath)
        cell.leftText = descriptionBlock?(opt) ?? delegate?.optionController(self, descriptionFor: opt)
        cell.applyChecked(opt == selectedOption, Theme.current)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let opt = options[indexPath.row]
        selectionBlock?(opt) ?? delegate?.optionController(self, didSelect: opt)
    }
}
