//
//  OnDemandView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/23/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

import CommonLibrary
import CommonUtils
import SwiftUI

struct OnDemandView: View, ModuleDraftEditing {

    @EnvironmentObject
    private var theme: Theme

    @Environment(\.distributionTarget)
    private var distributionTarget

    @ObservedObject
    var draft: ModuleDraft<OnDemandModule.Builder>

    @State
    private var paywallReason: PaywallReason?

    private let wifi: Wifi

    init(
        draft: ModuleDraft<OnDemandModule.Builder>,
        parameters: ModuleViewParameters,
        observer: WifiObserver? = nil
    ) {
        self.draft = draft
        wifi = Wifi(observer: observer ?? CoreLocationWifiObserver())
    }

    var body: some View {
        Group {
            rulesArea
        }
        .moduleView(draft: draft)
        .modifier(PaywallModifier(reason: $paywallReason))
    }
}

private extension OnDemandView {
    var allPolicies: [OnDemandModule.Policy] {
        if distributionTarget.supportsPaidFeatures {
            return [.any, .excluding, .including]
        } else {
            return [.any]
        }
    }

    @ViewBuilder
    var rulesArea: some View {
        policySection
        if draft.module.policy != .any {
            networkSection
            wifiSection
        }
    }

    var policySection: some View {
        Picker(selection: $draft.module.policy) {
            ForEach(allPolicies, id: \.self) {
                Text($0.localizedDescription)
            }
        } label: {
            HStack {
                Text(Strings.Modules.OnDemand.policy)
                PurchaseRequiredView(
                    for: draft.module,
                    reason: $paywallReason
                )
            }
        }
        .themeContainerWithSingleEntry(footer: policyFooterDescription)
    }

    var policyFooterDescription: String {
        let suffix: String
        switch draft.module.policy {
        case .any:
            suffix = Strings.Modules.OnDemand.Policy.Footer.any

        case .including, .excluding:
            if draft.module.policy == .including {
                suffix = Strings.Modules.OnDemand.Policy.Footer.including
            } else {
                suffix = Strings.Modules.OnDemand.Policy.Footer.excluding
            }

        @unknown default:
            suffix = Strings.Modules.OnDemand.Policy.Footer.any
        }
        return Strings.Modules.OnDemand.Policy.footer(suffix)
    }

    var networkSection: some View {
        Group {
            Toggle(Strings.Modules.OnDemand.mobile, isOn: $draft.module.withMobileNetwork)
            Toggle("\(Strings.Modules.OnDemand.ethernet) (Mac/TV)", isOn: $draft.module.withEthernetNetwork)
        }
        .themeSection(
            header: Strings.Global.Nouns.networks,
            footer: Strings.Modules.OnDemand.Networks.footer
        )
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
            Array(draft.module.withSSIDs.keys)
        } set: { newValue in
            draft.module.withSSIDs.forEach {
                guard newValue.contains($0.key) else {
                    draft.module.withSSIDs.removeValue(forKey: $0.key)
                    return
                }
            }
            newValue.forEach {
                guard draft.module.withSSIDs[$0] == nil else {
                    return
                }
                draft.module.withSSIDs[$0] = false
            }
        }
    }

    var onSSIDs: Binding<Set<String>> {
        .init {
            Set(draft.module.withSSIDs.filter {
                $0.value
            }.map(\.key))
        } set: { newValue in
            draft.module.withSSIDs.forEach {
                guard newValue.contains($0.key) else {
                    if draft.module.withSSIDs[$0.key] != nil {
                        draft.module.withSSIDs[$0.key] = false
                    } else {
                        draft.module.withSSIDs.removeValue(forKey: $0.key)
                    }
                    return
                }
            }
            newValue.forEach {
                guard !(draft.module.withSSIDs[$0] ?? false) else {
                    return
                }
                draft.module.withSSIDs[$0] = true
            }
        }
    }

    func isSSIDOn(_ ssid: String) -> Binding<Bool> {
        .init {
            draft.module.withSSIDs[ssid] ?? false
        } set: {
            draft.module.withSSIDs[ssid] = $0
        }
    }
}

private extension OnDemandView {
    func requestSSID(_ text: Binding<String>) {
        Task { @MainActor in
            let ssid = try await wifi.currentSSID()
            if !draft.module.withSSIDs.keys.contains(ssid) {
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
    return module.preview()
//    return module.preview {
//        OnDemandView(
//            draft: $1[$0],
//            parameters: .init(
//                registry: Registry(),
//                editor: $1,
//                impl: nil
//            ),
//            observer: MockWifi()
//        )
//    }
}

private class MockWifi: WifiObserver {
    func currentSSID() async throws -> String {
        ""
    }
}
