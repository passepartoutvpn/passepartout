//
//  View+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/18/22.
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
import SwiftyBeaver

extension View {
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

    func withTrailingText(_ text: String?, color: Color? = nil, truncationMode: Text.TruncationMode = .tail, copyOnTap: Bool = false) -> some View {
        HStack {
            self
            Spacer()
            let trailing = text.map(Text.init)
                .foregroundColor(color ?? themeSecondaryColor)
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
                    .foregroundColor(themeAccentColor)
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

    @ViewBuilder
    func replacedWithProgress(when condition: Bool) -> some View {
        if condition {
            ProgressView()
        } else {
            self
        }
    }
}

extension View {
    func debugChanges() {
        if #available(iOS 15, *),
           SwiftyBeaver.destinations.first?.minLevel == .verbose {

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
