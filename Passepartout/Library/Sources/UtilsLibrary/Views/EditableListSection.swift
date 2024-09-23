//
//  EditableListSection.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/19/24.
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

public protocol EditableValue: Hashable, CustomStringConvertible {
    static var emptyValue: Self { get }

    var isEmptyValue: Bool { get }
}

extension String: EditableValue {
    public static var emptyValue: String {
        ""
    }

    public var isEmptyValue: Bool {
        trimmingCharacters(in: .whitespaces) == ""
    }
}

public struct EditableListSection<ItemView: View, RemoveView: View, EditView: View, T: EditableValue>: View {
    private let title: String

    private let addTitle: String

    @Binding
    private var originalItems: [T]

    private let emptyValue: (() async -> T)?

    private let itemLabel: (Bool, Binding<T>) -> ItemView

    private let removeLabel: (@escaping () -> Void) -> RemoveView

    private let editLabel: () -> EditView

    @State
    private var items: [Item] = []

    @State
    private var draggingItem: Item?

    @State
    private var isEditing = false

    public init(
        _ title: String,
        addTitle: String,
        originalItems: Binding<[T]>,
        emptyValue: (() async -> T)? = nil,
        @ViewBuilder itemLabel: @escaping (Bool, Binding<T>) -> ItemView,
        @ViewBuilder removeLabel: @escaping (@escaping () -> Void) -> RemoveView,
        @ViewBuilder editLabel: @escaping () -> EditView
    ) {
        self.title = title
        self.addTitle = addTitle
        _originalItems = originalItems
        self.emptyValue = emptyValue
        self.itemLabel = itemLabel
        self.removeLabel = removeLabel
        self.editLabel = editLabel
    }

    public var body: some View {
        ForEach(items, id: \.id) { item in
            RemovableItemRow(isEditing: isEditing) {
                itemView(for: item)
            } removeView: {
                removeView(for: item)
            }
            .onDrag {
                draggingItem = item
                return NSItemProvider(object: item.value.description as NSString)
            }
            .onDrop(of: [.text], delegate: ItemDropDelegate(
                item: item,
                items: $items,
                draggingItem: $draggingItem
            ))
        }
        .onMove {
            items.move(fromOffsets: $0, toOffset: $1)
        }
        .onDelete {
            items.remove(atOffsets: $0)
        }
        .onChange(of: items, perform: exportItems)
        .asSectionWithHeader(title) {
#if os(iOS)
            addButton
#elseif os(macOS)
            editButton
            addButton
#endif
        }
        .onLoad(perform: importItems)
    }
}

private extension EditableListSection {
    struct Item: Identifiable, Hashable {
        let id = UUID()

        var value: T

        var isEmpty: Bool {
            value.isEmptyValue
        }
    }

    struct ItemDropDelegate: DropDelegate {
        let item: Item

        @Binding
        var items: [Item]

        @Binding
        var draggingItem: Item?

        func performDrop(info: DropInfo) -> Bool {
            draggingItem = nil
            return true
        }

        func dropEntered(info: DropInfo) {
            guard let draggingItem = draggingItem, draggingItem != item else {
                return
            }
            guard let fromIndex = items.firstIndex(of: draggingItem) else {
                return
            }
            guard let toIndex = items.firstIndex(of: item) else {
                return
            }
            guard fromIndex != toIndex else {
                return
            }
            withAnimation {
                items.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
    }
}

private extension EditableListSection {
    var canAdd: Bool {
        if let lastItem = items.last {
            return !lastItem.isEmpty
        }
        return true
    }

    var canEdit: Bool {
        !items.isEmpty
    }

    func itemView(for item: Item) -> some View {
        itemLabel(isEditing, itemValueBinding(for: item))
    }

    func itemValueBinding(for item: Item) -> Binding<T> {
        Binding {
            item.value
        } set: {
            guard let itemIndex = items.firstIndex(where: { $0.id == item.id }) else {
                return
            }
            items[itemIndex].value = $0
        }
    }

    func removeView(for item: Item) -> some View {
        removeLabel {
            withAnimation {
                items.removeAll {
                    $0.id == item.id
                }
            }
        }
    }

    var addButton: some View {
        Button(addTitle) {
            Task {
                let newValue = await emptyValue?() ?? T.emptyValue
                withAnimation {
                    items.append(Item(value: newValue))
                }
            }
        }
        .disabled(!canAdd)
    }

    var editButton: some View {
        Toggle(isOn: $isEditing, label: editLabel)
            .toggleStyle(.button)
            .disabled(!canEdit)
    }
}

private extension EditableListSection {
    func importItems() {
        items = originalItems.map(Item.init)
    }

    func exportItems(_ newItems: [Item]) {
        let newOriginalItems = newItems.map(\.value)
        guard newOriginalItems != originalItems else {
            return
        }
        originalItems = newOriginalItems
    }
}

#Preview {
    @State
    var originalItems = ["One", "Two", "Three"]

    return Form {
        EditableListSection(
            "Title",
            addTitle: "Add item",
            originalItems: $originalItems
        ) {
            if $0 {
                Text($1.wrappedValue)
            } else {
                TextField("", text: $1)
            }
        } removeLabel: { action in
            Button("Remove", action: action)
        } editLabel: {
            Image(systemName: "arrow.up.arrow.down")
        }
    }
}
