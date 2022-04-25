//
//  Theme.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/24/22.
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
import PassepartoutCore

extension Color {
    init(red: Double, green: Double, blue: Double, brightness: Double) {
        self.init(
            red: red * brightness,
            green: green * brightness,
            blue: blue * brightness
        )
    }
}

extension View {
    var themeIdiom: UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }
}

// MARK: Styles

extension View {
    func themeGlobal() -> some View {
        let color = themeAccentColor
        return accentColor(color)
            .toggleStyle(SwitchToggleStyle(tint: color))
            .listStyle(.insetGrouped)
            .themeNavigationViewStyle()
    }
    
    @ViewBuilder
    private func themeNavigationViewStyle() -> some View {
        switch themeIdiom {
        case .phone:
            navigationViewStyle(.stack)

        default:
            navigationViewStyle(.automatic)
        }
    }
    
    func themePrimaryView() -> some View {
        navigationBarTitleDisplayMode(.large)
    }

    func themeSecondaryView() -> some View {
        navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: Colors

extension View {
    fileprivate var themeAccentColor: Color {
        Color(Asset.Assets.accentColor.color)
    }
    
    fileprivate var themePrimaryBackgroundColor: Color {
        Color(Asset.Assets.primaryColor.color)
    }
    
    fileprivate var themeSecondaryColor: Color {
        .secondary
    }
    
    fileprivate var themeLightTextColor: Color {
        Color(Asset.Assets.lightTextColor.color)
    }
    
    fileprivate var themeErrorColor: Color {
        .red
    }

    private func themeColor(_ string: String?, validator: (String) throws -> Void) -> Color? {
        guard let string = string else {
            return nil
        }
        do {
            try validator(string)
            return nil
        } catch {
            return themeErrorColor
        }
    }
}

// MARK: Images

extension View {
    var themeAssetsLogoImage: String {
        "logo"
    }
    
    func themeAssetsProviderImage(_ providerName: ProviderName) -> String {
        "providers/\(providerName)"
    }
    
    func themeAssetsCountryImage(_ countryCode: String) -> String {
        "flags/\(countryCode.lowercased())"
    }

    var themeProviderImage: String {
        "externaldrive.connected.to.line.below.fill"
    }
    
    var themeHostFilesImage: String {
        "folder.fill"
    }
    
    var themeHostTextImage: String {
        "text.justify"
    }
    
    var themeSettingsMenuImage: String {
        "ellipsis.circle"
    }

    var themeAddMenuImage: String {
        "plus"
    }

    var themeCheckmarkImage: String {
        "checkmark"
    }
    
    var themeStatusImage: String {
        "network"
    }

    var themeShortcutsImage: String {
        "mic.fill"
    }

    var themeDonateImage: String {
        "giftcard.fill"
    }

    var themeRedditImage: String {
        "person.3.fill"
    }

    var themeWriteReviewImage: String {
        "heart.fill"
    }
    
    var themeCloseImage: String {
        "xmark"
    }
    
    var themeDeleteImage: String {
        "trash.fill"
    }
    
    var themeRenameProfileImage: String {
        "highlighter"
//        "character.cursor.ibeam"
    }
    
    var themeVPNProtocolImage: String {
        "bolt.fill"
//        "waveform.path.ecg"
//        "message.and.waveform.fill"
//        "pc"
//        "captions.bubble.fill"
    }
    
    var themeEndpointImage: String {
        "link"
    }
    
    var themeAccountImage: String {
        "person.fill"
    }
    
    var themeProviderLocationImage: String {
        "location.fill"
    }
    
    var themeProviderPresetImage: String {
        "slider.horizontal.3"
    }
    
    var themeProviderRefreshImage: String {
        "arrow.clockwise"
    }
    
    var themeNetworkSettingsImage: String {
//        "network"
        "globe"
    }
    
    var themeOnDemandImage: String {
        "wifi"
    }
    
    var themeDiagnosticsImage: String {
        "bandage.fill"
    }
    
    var themeFAQImage: String {
        "questionmark.diamond.fill"
    }

    var themeConceilImage: String {
        "eye.slash.fill"
    }

    var themeRevealImage: String {
        "eye.fill"
    }

    var themeShareImage: String {
        "square.and.arrow.up"
    }
    
    func themeFavoritesImage(_ active: Bool) -> String {
        active ? "bookmark.fill" : "bookmark"
    }

    func themeFavoriteActionImage(_ doFavorite: Bool) -> String {
        doFavorite ? "bookmark" : "bookmark.slash.fill"
    }
}

extension String {
    var asAssetImage: Image {
        Image(self)
    }

    var asSystemImage: Image {
        Image(systemName: self)
    }
}

// MARK: Styles

extension View {
    var themePrimaryBackground: some View {
        themePrimaryBackgroundColor
            .ignoresSafeArea()
    }

    func themeAccentForegroundStyle() -> some View {
        foregroundColor(themeAccentColor)
    }

    func themeSecondaryTextStyle() -> some View {
        foregroundColor(themeSecondaryColor)
    }
    
    func themeLightTextStyle() -> some View {
        foregroundColor(themeLightTextColor)
    }
    
    func themeDestructiveButtonStyle() -> some View {
        foregroundColor(themeErrorColor)
    }

    @available(iOS 15, *)
    func themePrimaryTintStyle() -> some View {
        tint(themePrimaryBackgroundColor)
    }

    func themeTextButtonStyle() -> some View {
        accentColor(.primary)
    }

    func themeLongTextStyle() -> some View {
        lineLimit(1)
            .truncationMode(.middle)
    }
    
    func themeInformativeTextStyle() -> some View {
        multilineTextAlignment(.center)
            .font(.title)
            .foregroundColor(themeSecondaryColor)
    }

    func themeDebugLogStyle() -> some View {
        font(.system(size: 13, weight: .medium, design: .monospaced))
    }
}

// MARK: Animations
    
extension View {
    func themeAnimation<V: Equatable>(on value: V) -> some View {
        animation(.default, value: value)
    }
}

extension Binding {
    func themeAnimation() -> Binding<Value> {
        animation(.default)
    }
}

// MARK: Shortcuts

extension View {
    func themeCloseItem(presentationMode: Binding<PresentationMode>) -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                themeCloseImage.asSystemImage
            }
        }
    }

    func themeCloseItem(isPresented: Binding<Bool>) -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                isPresented.wrappedValue = false
            } label: {
                themeCloseImage.asSystemImage
            }
        }
    }
    
    func themeSaveButtonLabel() -> some View {
//        themeCheckmarkImage.asSystemImage
        Text(L10n.Global.Strings.save)
    }

//    func themeDoneButtonLabel() -> some View {
////        themeCheckmarkImage.asSystemImage
//        Text(L10n.Global.Strings.ok)
//    }

    func themeTextPicker<T: Hashable>(_ title: String, selection: Binding<T>, values: [T], description: @escaping (T) -> String) -> some View {
        StyledPicker(title: title, selection: selection, values: values) {
            Text(description($0))
        } selectionLabel: {
            Text(description($0))
                .foregroundColor(themeSecondaryColor)
        } listStyle: {
            .insetGrouped
        }
    }

    func themeLongContentLinkDefault(_ title: String, content: Binding<String>) -> some View {
        LongContentLink(title, content: content) {
            Text($0)
                .foregroundColor(themeSecondaryColor)
        }
    }

    func themeLongContentLink(_ title: String, content: Binding<String>, withPreview preview: String? = nil) -> some View {
        LongContentLink(title, content: content, preview: preview) {
            Text(preview != nil ? $0 : "")
                .foregroundColor(themeSecondaryColor)
        }
    }
    
    @ViewBuilder
    func themeErrorMessage(_ message: String?) -> some View {
        if let message = message {
            if message.last != "." {
                Text("\(message).")
                    .foregroundColor(themeErrorColor)
            } else {
                Text(message)
                    .foregroundColor(themeErrorColor)
            }
        } else {
            EmptyView()
        }
    }
}

// MARK: Validation

extension View {
    func themeProfileName() -> some View {
        autocapitalization(.none)
            .disableAutocorrection(true)
    }

    func themeURL(_ urlString: String?) -> some View {
        themeValidating(urlString, validator: Validators.url)
            .keyboardType(.asciiCapable)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
    
    func themeIPAddress(_ ipAddress: String?) -> some View {
        themeValidating(ipAddress, validator: Validators.ipAddress)
            .keyboardType(.numbersAndPunctuation)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
    
    func themeSocketPort() -> some View {
        keyboardType(.numberPad)
    }

    func themeDomainName(_ domainName: String?) -> some View {
        themeValidating(domainName, validator: Validators.domainName)
            .keyboardType(.asciiCapable)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }

    func themeSSID(_ text: String?) -> some View {
        themeValidating(text, validator: Validators.notEmpty)
            .keyboardType(.asciiCapable)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }

    private func themeValidating(_ string: String?, validator: (String) throws -> Void) -> some View {
        foregroundColor(themeColor(string, validator: validator))
    }
}

// MARK: Hacks

extension View {
//    @available(*, deprecated, message: "mitigates multiline text truncation (1.0 does not work though)")
    func xxxThemeTruncation() -> some View {
        minimumScaleFactor(0.5)
    }
}
