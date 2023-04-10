//
//  OnDemandView+SSID.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/23/22.
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

import SwiftUI
import PassepartoutLibrary

extension OnDemandView {
    struct SSIDList: View {
        @Binding var withSSIDs: [String: Bool]

        @StateObject private var reader = SSIDReader()

        var body: some View {
            EditableTextList(elements: allSSIDs, allowsDuplicates: false, mapping: mapElements) { text in
                requestSSID(text)
            } textField: {
                ssidRow(callback: $0)
            } addLabel: {
                Text(L10n.OnDemand.Items.AddSsid.caption)
            } commitLabel: {
                Text(L10n.Global.Strings.add)
            }
        }

        private func mapElements(elements: [IdentifiableString]) -> [IdentifiableString] {
            elements
                .filter { !$0.string.isEmpty }
                .sorted { $0.string.lowercased() < $1.string.lowercased() }
        }

        private func ssidRow(callback: EditableTextFieldCallback) -> some View {
            Group {
                if callback.isNewElement {
                    ssidField(callback: callback)
                } else {
                    Toggle(isOn: isSSIDOn(callback.text.wrappedValue)) {
                        ssidField(callback: callback)
                    }
                }
            }
        }

        private func ssidField(callback: EditableTextFieldCallback) -> some View {
            TextField(
                Unlocalized.Network.ssid,
                text: callback.text,
                onEditingChanged: callback.onEditingChanged,
                onCommit: callback.onCommit
            ).themeValidSSID(callback.text.wrappedValue)
        }

        private func requestSSID(_ text: Binding<String>) {
            Task { @MainActor in
                let ssid = try await reader.requestCurrentSSID()
                if !withSSIDs.keys.contains(ssid) {
                    text.wrappedValue = ssid
                }
            }
        }
    }
}

extension OnDemandView.SSIDList {
    private var allSSIDs: Binding<[String]> {
        .init {
            Array(withSSIDs.keys)
        } set: { newValue in
            withSSIDs.forEach {
                guard newValue.contains($0.key) else {
                    withSSIDs.removeValue(forKey: $0.key)
                    return
                }
            }
            newValue.forEach {
                guard withSSIDs[$0] == nil else {
                    return
                }
                withSSIDs[$0] = false
            }
//            print(">>> withSSIDs (allSSIDs): \(withSSIDs)")
        }
    }

    private var onSSIDs: Binding<Set<String>> {
        .init {
            Set(withSSIDs.filter {
                $0.value
            }.map(\.key))
        } set: { newValue in
            withSSIDs.forEach {
                guard newValue.contains($0.key) else {
                    if withSSIDs[$0.key] != nil {
                        withSSIDs[$0.key] = false
                    } else {
                        withSSIDs.removeValue(forKey: $0.key)
                    }
                    return
                }
            }
            newValue.forEach {
                guard !(withSSIDs[$0] ?? false) else {
                    return
                }
                withSSIDs[$0] = true
            }
//            print(">>> withSSIDs (onSSIDs): \(withSSIDs)")
        }
    }

    private func isSSIDOn(_ ssid: String) -> Binding<Bool> {
        .init {
            withSSIDs[ssid] ?? false
        } set: {
            withSSIDs[ssid] = $0
        }
    }
}
