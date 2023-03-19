//
//  AddProviderView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/10/22.
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

struct AddProviderView: View {
    @ObservedObject private var providerManager: ProviderManager

    @ObservedObject private var productManager: ProductManager

    private let bindings: AddProfileView.Bindings

    @StateObject private var viewModel = ViewModel()

    init(bindings: AddProfileView.Bindings) {
        providerManager = .shared
        productManager = .shared
        self.bindings = bindings
    }

    private var providers: [ProviderMetadata] {
        providerManager.allProviders()
            .filter {
                $0.supportedVPNProtocols.contains(viewModel.selectedVPNProtocol)
            }.sorted()
    }

    private var availableVPNProtocols: [VPNProtocolType] {
        var protos: Set<VPNProtocolType> = []
        providers.forEach {
            $0.supportedVPNProtocols.forEach {
                protos.insert($0)
            }
        }
        return protos.sorted()
    }

    var body: some View {
        ZStack {
            ForEach(providers, id: \.navigationId, content: hiddenProviderLink)
            ScrollViewReader { scrollProxy in
                List {
                    mainSection
                    if !providers.isEmpty {
                        providersSection
                    }
                }.onAppear {
                    viewModel.updateIndex(providerManager)
                }.onChange(of: viewModel.errorMessage) {
                    onErrorMessage($0, scrollProxy)
                }.themeAnimation(on: providers)
            }
        }.toolbar {
            themeCloseItem(isPresented: bindings.$isPresented)
        }.sheet(isPresented: $viewModel.isPaywallPresented) {
            NavigationView {
                PaywallView(isPresented: $viewModel.isPaywallPresented)
            }.themeGlobal()
        }.navigationTitle(L10n.AddProfile.Shared.title)
        .themeSecondaryView()
    }

    private var mainSection: some View {
        Section {
            let protos = availableVPNProtocols
            if !protos.isEmpty {
                themeTextPicker(
                    L10n.Global.Strings.protocol,
                    selection: $viewModel.selectedVPNProtocol,
                    values: protos,
                    description: \.description
                )
            }
            updateListButton
        } footer: {
            Text(L10n.AddProfile.Provider.Sections.Vpn.footer)
        }
    }

    private var providersSection: some View {
        Section {
            ForEach(providers, content: providerRow)
        } footer: {
            themeErrorMessage(viewModel.errorMessage)
        }.disabled(viewModel.isFetchingAnyProvider)
    }

    private func providerRow(_ metadata: ProviderMetadata) -> some View {
        Button {
            presentOrPurchaseProvider(metadata)
        } label: {
            Label(metadata.fullName, image: themeAssetsProviderImage(metadata.name))
        }.withTrailingProgress(when: viewModel.isFetchingProvider(metadata.name))
    }

    private func hiddenProviderLink(_ metadata: ProviderMetadata) -> some View {
        NavigationLink("", tag: metadata, selection: $viewModel.selectedProvider) {
            NameView(
                profile: $viewModel.pendingProfile,
                providerMetadata: metadata,
                bindings: bindings
            )
        }
    }

    private var updateListButton: some View {
        Button(L10n.AddProfile.Provider.Items.updateList) {
            viewModel.updateIndex(providerManager)
        }.withTrailingProgress(when: viewModel.isUpdatingIndex)
        .disabled(viewModel.isUpdatingIndex)
    }

    // eligibility: select or purchase provider
    private func presentOrPurchaseProvider(_ metadata: ProviderMetadata) {
        guard productManager.isEligible(forProvider: metadata.name) else {
            viewModel.presentPaywall()
            return
        }
        viewModel.selectProvider(metadata, providerManager)
    }

    private func onErrorMessage(_ message: String?, _ scrollProxy: ScrollViewProxy) {
        guard message != nil else {
            return
        }
        scrollToErrorMessage(scrollProxy)
    }
}

extension AddProviderView {
    private func scrollToErrorMessage(_ proxy: ScrollViewProxy) {
        proxy.maybeScrollTo(providers.last?.id, animated: true)
    }
}

private extension ProviderMetadata {
    var navigationId: String {
        "navigation.\(name)"
    }
}
