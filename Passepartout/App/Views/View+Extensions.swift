//
//  View+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/18/22.
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
import SwiftyBeaver

extension View {
    func withoutTitleBar() -> some View {
        #if targetEnvironment(macCatalyst)
        withHostingWindow { window in
            guard let titlebar = window?.windowScene?.titlebar else {
                return
            }
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
        #else
        self
        #endif
    }

    func withLeadingText(_ text: String?, color: Color? = nil, truncationMode: Text.TruncationMode = .tail) -> some View {
        HStack {
            text.map(Text.init)
                .foregroundColor(color)
                .lineLimit(1)
                .truncationMode(truncationMode)
            Spacer()
            self
        }
    }

    func withLeadingLabel(_ text: String, color: Color? = nil, image: String) -> some View {
        HStack {
            Label(text, image: image)
                .foregroundColor(color)
            Spacer()
            self
        }
    }

    func withTrailingText(_ text: String?, truncationMode: Text.TruncationMode = .tail, copyOnTap: Bool = false) -> some View {
        HStack {
            self
            Spacer()
            let trailing = text.map(Text.init)
                .themeSecondaryTextStyle()
                .lineLimit(1)
                .truncationMode(truncationMode)
            if copyOnTap {
                trailing
                    .onTapGesture {
                        text.map(Utils.copyToPasteboard)
                    }
            } else {
                trailing
            }
        }
    }

    func withTrailingCheckmark(when condition: Bool) -> some View {
        HStack {
            self
            if condition {
                Spacer()
                themeCheckmarkImage.asSystemImage
                    .themeAccentForegroundStyle()
            }
        }
    }

    func withTrailingProgress(when condition: Bool) -> some View {
        HStack {
            self
                .disabled(condition)
            if condition {
                Spacer()
                ProgressView()
            }
        }
    }
}

extension View {
    func debugChanges() {
        if SwiftyBeaver.destinations.first?.minLevel == .verbose {
            Self._printChanges()
        }
    }
}

extension ScrollViewProxy {
    func maybeScrollTo<ID: Hashable>(
        _ id: ID?,
        afterMilliseconds millis: Int = Constants.Delays.scrolling,
        animated: Bool = false,
        anchor: UnitPoint = .center
    ) {
        guard let id = id else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(millis)) {
            if animated {
                withAnimation {
                    scrollTo(id, anchor: anchor)
                }
            } else {
                scrollTo(id, anchor: anchor)
            }
        }
    }
}

// https://stackoverflow.com/questions/65238068/hide-title-bar-in-swiftui-app-for-maccatalyst

private extension View {
    func withHostingWindow(_ callback: @escaping (UIWindow?) -> Void) -> some View {
        background(HostingWindowFinder(callback: callback))
    }
}

private struct HostingWindowFinder: UIViewRepresentable {
    var callback: (UIWindow?) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
