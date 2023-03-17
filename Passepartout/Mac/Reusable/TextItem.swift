//
//  TextItem.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/28/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

import Foundation
import AppKit

struct TextItem: Item {
    enum State {
        case none

        case checked

        case unchecked
    }

    private let viewModel: ViewModel

    private let key: String?

    let children: [Item]

    init(_ title: String, state: State = .none, key: String? = nil, _ children: [Item] = [], action: (() -> Void)? = nil) {
        self.init(ViewModel(title, state: state, action: action), key: key, children)
    }

    init(_ viewModel: ViewModel, key: String? = nil, _ children: [Item] = []) {
        self.viewModel = viewModel
        self.key = key
        self.children = children
    }

    func asMenuItem(withParent parent: NSMenu) -> NSMenuItem {
        let item = NSMenuItem(
            title: viewModel.title.value,
            action: viewModel.hasAction ? #selector(viewModel.representedAction) : nil,
            keyEquivalent: key ?? ""
        )
        if viewModel.hasAction {
            item.target = viewModel
        }
        item.state = state
        item.representedObject = viewModel

        if !children.isEmpty {
            let submenu = NSMenu()
            children.forEach {
                submenu.addItem($0.asMenuItem(withParent: submenu))
            }
            item.submenu = submenu
        }

        viewModel.subscribeTitle {
            item.title = $0
        }
        viewModel.subscribeState { _ in
            item.state = state
        }

        return item
    }

    private var state: NSControl.StateValue {
        switch viewModel.state.value {
        case .none, .unchecked:
            return .off

        case .checked:
            return .on
        }
    }
}
