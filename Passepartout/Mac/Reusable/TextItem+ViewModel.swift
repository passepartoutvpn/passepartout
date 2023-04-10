//
//  TextItem+ViewModel.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/2/22.
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
import Combine

extension TextItem {
    class ViewModel {
        let title: CurrentValueSubject<String, Never>

        let state: CurrentValueSubject<State, Never>

        private let action: (() -> Void)?

        var hasAction: Bool {
            action != nil
        }

        private var subscriptions: Set<AnyCancellable> = []

        init(_ title: String, state: State = .none, action: (() -> Void)? = nil) {
            self.title = CurrentValueSubject(title)
            self.state = CurrentValueSubject(state)
            self.action = action
        }

        @objc func representedAction() {
            action?()
        }

        func subscribeTitle(_ block: @escaping (String) -> Void) {
            title
                .removeDuplicates()
                .sink(receiveValue: block)
                .store(in: &subscriptions)
        }

        func subscribeState(_ block: @escaping (State) -> Void) {
            state
                .removeDuplicates()
                .sink(receiveValue: block)
                .store(in: &subscriptions)
        }
    }
}
