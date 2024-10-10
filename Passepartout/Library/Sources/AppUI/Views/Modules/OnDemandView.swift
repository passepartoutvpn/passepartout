//
//  OnDemandView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/23/24.
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

import PassepartoutKit
import SwiftUI
import UtilsLibrary

extension OnDemandModule.Builder: ModuleViewProviding {
    func moduleView(with editor: ProfileEditor) -> some View {
        OnDemandView(editor: editor, module: self)
    }
}

private struct OnDemandView: View {

    @EnvironmentObject
    private var theme: Theme

    @EnvironmentObject
    private var iapManager: IAPManager

    @ObservedObject
    private var editor: ProfileEditor

    private let wifi: Wifi

    @Binding
    private var draft: OnDemandModule.Builder

    @State
    private var paywallReason: PaywallReason?

    init(
        editor: ProfileEditor,
        module: OnDemandModule.Builder,
        observer: WifiObserver? = nil
    ) {
        self.editor = editor
        wifi = Wifi(observer: observer ?? CoreLocationWifiObserver())
        _draft = editor.binding(forModule: module)
    }

    var body: some View {
        Group {
            enabledSection
            restrictedArea
        }
        .moduleView(editor: editor, draft: draft)
        .modifier(PaywallModifier(reason: $paywallReason))
    }
}

private extension OnDemandView {
    static let allPolicies: [OnDemandModule.Policy] = [
        .any,
        .excluding,
        .including
    ]

    var enabledSection: some View {
        Section {
            Toggle(Strings.Global.enabled, isOn: $draft.isEnabled)
        }
    }

    @ViewBuilder
    var restrictedArea: some View {
        switch iapManager.paywallReason(forFeature: .onDemand) {
        case .purchase(let appFeature):
            Button(Strings.Modules.OnDemand.purchase) {
                paywallReason = .purchase(appFeature)
            }

        case .restricted:
            EmptyView()

        default:
            if draft.isEnabled {
                policySection
                if draft.policy != .any {
                    networkSection
                    wifiSection
                }
            }
        }
    }

    var policySection: some View {
        Picker(Strings.Modules.OnDemand.policy, selection: $draft.policy) {
            ForEach(Self.allPolicies, id: \.self) {
                Text($0.localizedDescription)
            }
        }
        .themeSection(footer: policyFooterDescription)
    }

    var policyFooterDescription: String {
        guard draft.isEnabled else {
            return "" // better animation than removing footer completely
        }
        let suffix: String
        switch draft.policy {
        case .any:
            suffix = Strings.Modules.OnDemand.Policy.Footer.any

        case .including, .excluding:
            if draft.policy == .including {
                suffix = Strings.Modules.OnDemand.Policy.Footer.including
            } else {
                suffix = Strings.Modules.OnDemand.Policy.Footer.excluding
            }
        }
        return Strings.Modules.OnDemand.Policy.footer(suffix)
    }

    var networkSection: some View {
        Group {
            if Utils.hasCellularData() {
                Toggle(Strings.Modules.OnDemand.mobile, isOn: $draft.withMobileNetwork)
            } else if Utils.hasEthernet() {
                Toggle(Strings.Modules.OnDemand.ethernet, isOn: $draft.withEthernetNetwork)
            }
        }
        .themeSection(header: Strings.Global.networks)
    }

    var wifiSection: some View {
        theme.listSection(
            Strings.Unlocalized.wifi,
            addTitle: Strings.Modules.OnDemand.Ssid.add,
            originalItems: allSSIDs,
            emptyValue: {
                do {
                    return try await wifi.currentSSID()
                } catch {
                    return ""
                }
            },
            itemLabel: { isEditing, binding in
                if isEditing {
                    Text(binding.wrappedValue)
                } else {
                    HStack {
                        ThemeTextField("", text: binding, placeholder: Strings.Placeholders.OnDemand.ssid)
                            .frame(maxWidth: .infinity)
                            .themeManualInput()
                        Spacer()
                        Toggle("", isOn: isSSIDOn(binding.wrappedValue))
                    }
                    .labelsHidden()
                }
            }
        )
    }
}

private extension OnDemandView {
    var allSSIDs: Binding<[String]> {
        .init {
            Array(draft.withSSIDs.keys)
        } set: { newValue in
            draft.withSSIDs.forEach {
                guard newValue.contains($0.key) else {
                    draft.withSSIDs.removeValue(forKey: $0.key)
                    return
                }
            }
            newValue.forEach {
                guard draft.withSSIDs[$0] == nil else {
                    return
                }
                draft.withSSIDs[$0] = false
            }
//            print(">>> withSSIDs (allSSIDs): \(withSSIDs)")
        }
    }

    var onSSIDs: Binding<Set<String>> {
        .init {
            Set(draft.withSSIDs.filter {
                $0.value
            }.map(\.key))
        } set: { newValue in
            draft.withSSIDs.forEach {
                guard newValue.contains($0.key) else {
                    if draft.withSSIDs[$0.key] != nil {
                        draft.withSSIDs[$0.key] = false
                    } else {
                        draft.withSSIDs.removeValue(forKey: $0.key)
                    }
                    return
                }
            }
            newValue.forEach {
                guard !(draft.withSSIDs[$0] ?? false) else {
                    return
                }
                draft.withSSIDs[$0] = true
            }
//            print(">>> withSSIDs (onSSIDs): \(withSSIDs)")
        }
    }

    func isSSIDOn(_ ssid: String) -> Binding<Bool> {
        .init {
            draft.withSSIDs[ssid] ?? false
        } set: {
            draft.withSSIDs[ssid] = $0
        }
    }
}

private extension OnDemandView {
    func requestSSID(_ text: Binding<String>) {
        Task { @MainActor in
            let ssid = try await wifi.currentSSID()
            if !draft.withSSIDs.keys.contains(ssid) {
                text.wrappedValue = ssid
            }
        }
    }
}

// MARK: - Previews

#Preview {
    var module = OnDemandModule.Builder()
    module.policy = .excluding
    module.withMobileNetwork = true
    module.withSSIDs = [
        "One": true,
        "Two": false,
        "Three": false
    ]
    return module.preview {
        OnDemandView(
            editor: $0,
            module: $1,
            observer: MockWifi()
        )
    }
}

private class MockWifi: WifiObserver {
    func currentSSID() async throws -> String {
        ""
    }
}
