//
//  RemovableItemRow.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/3/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

import SwiftUI

public struct RemovableItemRow<ItemView, RemoveView>: View where ItemView: View,
                                                                 RemoveView: View {
    private let isEditing: Bool

    private let itemView: () -> ItemView

    private let removeView: () -> RemoveView

    public init(
        isEditing: Bool,
        @ViewBuilder itemView: @escaping () -> ItemView,
        @ViewBuilder removeView: @escaping () -> RemoveView
    ) {
        self.isEditing = isEditing
        self.itemView = itemView
        self.removeView = removeView
    }

    public var body: some View {
        HStack {
            if isEditing {
                removeView()
            }
            itemView()
        }
    }
}
