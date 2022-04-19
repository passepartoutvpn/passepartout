//
//  EditableTextList.swift
//  Passepartout
//
//  Created by Davide De Rosa on 3/31/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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

struct IdentifiableString: Identifiable, Equatable {
    var id = UUID()

    var string: String
}

struct EditableTextList<Field: View, ActionLabel: View>: View {
    typealias FieldCallback = (
        isNewElement: Bool,
        text: Binding<String>,
        onEditingChanged: (Bool) -> Void,
        onCommit: () -> Void
    )
    
    @Binding var elements: [String]

    var allowsDuplicates = true
    
    var mapping: ([IdentifiableString]) -> [IdentifiableString] = { $0 }
    
    var onAdd: ((Binding<String>) -> Void)?
    
    let textField: (FieldCallback) -> Field

    let addLabel: () -> ActionLabel
    
    var commitLabel: (() -> ActionLabel)?
    
    @State private var isLoaded = false

    @State private var identifiableElements: [IdentifiableString] = []

    @State private var editedTextStrings: [UUID: String] = [:]

    private let addedUUID = UUID()
    
    private var addedText: Binding<String> {
        .init {
            editedTextStrings[addedUUID] ?? ""
        } set: {
            editedTextStrings[addedUUID] = $0
        }
    }
    
    var body: some View {
        debugChanges()
        return Group {
            ForEach(mapping(identifiableElements), content: existingRow)
                .onDelete(perform: onDelete)
                .onMove(perform: onMove)

            newRow
        }.onAppear {
            guard !isLoaded else {
                return
            }
            isLoaded = true
            identifiableElements = elements.map {
                IdentifiableString(string: $0)
            }
        }.onChange(of: elements, perform: remapElements)
    }
    
    private func existingRow(_ element: IdentifiableString) -> some View {
        let editedText = binding(toEditedElement: element)

        return textField((false, editedText, {
            if $0 {
                editedTextStrings.removeValue(forKey: element.id)
//                print(">>> editing: '\(text.wrappedValue.string)' (\(text.wrappedValue.id))")
            }
        }, {
            replaceElement(at: element.id, with: editedText)
        }))
    }
    
    private var newRow: some View {
        AddingTextField(
            onAdd: {
                addedText.wrappedValue = ""
                onAdd?(addedText)
            },
            onCommit: addElement,
            textField: {
                textField((true, addedText, { _ in }, $0))
            },
            addLabel: addLabel,
            commitLabel: commitLabel
        )
    }
}

// MARK: View model

extension EditableTextList {
    private func remapElements(_ newElements: [String]) {
        var oldIdentifiableElements = identifiableElements
        var newIdentifiableElements: [IdentifiableString] = []

        newElements.forEach { newString in
            let id: UUID
            if let found = oldIdentifiableElements.firstIndex(where: {
                $0.string == newString
            }) {
                id = oldIdentifiableElements[found].id
                oldIdentifiableElements.remove(at: found)
            } else {
                id = UUID()
            }
            newIdentifiableElements.append(.init(id: id, string: newString))
        }

        guard newIdentifiableElements != identifiableElements else {
            return
        }
        withAnimation {
            identifiableElements = newIdentifiableElements
        }
    }
    
    private func addElement() {
        guard allowsDuplicates || !identifiableElements.contains(where: {
            $0.string == addedText.wrappedValue
        }) else {
            return
        }
//        print(">>> + \(addedElement.wrappedValue)")
        identifiableElements.append(.init(string: addedText.wrappedValue))
        commit()
    }
    
    private func binding(toEditedElement element: IdentifiableString) -> Binding<String> {
//        print(">>> <-> \(element)")
        return .init {
            editedTextStrings[element.id] ?? element.string
        } set: {
            editedTextStrings[element.id] = $0
        }
    }

    private func replaceElement(at id: UUID, with editedText: Binding<String>) {
//        print(">>> \(identifiableElements[id].string) -> \(editedText.wrappedValue)")
        guard let i = identifiableElements.firstIndex(where: {
            $0.id == id
        }) else {
            assertionFailure("Editing removed element?")
            return
        }
        guard allowsDuplicates || !identifiableElements.contains(where: {
            $0.string == editedText.wrappedValue
        }) else {
            editedText.wrappedValue = identifiableElements[i].string
            return
        }
        withAnimation {
            identifiableElements[i].string = editedText.wrappedValue
        }
        commit()
    }
    
    private func onDelete(offsets: IndexSet) {
        var mapped = mapping(identifiableElements)
        mapped.remove(atOffsets: offsets)
        identifiableElements = mapped
        commit()
    }
    
    private func onMove(indexSet: IndexSet, to: Int) {
        var mapped = mapping(identifiableElements)
        mapped.move(fromOffsets: indexSet, toOffset: to)
        identifiableElements = mapped
        commit()
    }

    private func commit() {
//        print(">>> identifiableElements = \(identifiableElements.map { "\($0.string) (\($0.id))" })")
        elements = identifiableElements.map(\.string)
    }
}
