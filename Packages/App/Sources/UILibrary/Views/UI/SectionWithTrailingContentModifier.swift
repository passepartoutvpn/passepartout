//
//  SectionWithTrailingContentModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/1/24.
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

extension View {
    public func asSectionWithTrailingContent<TrailingContent>(@ViewBuilder _ trailing: @escaping () -> TrailingContent) -> some View where TrailingContent: View {
        modifier(SectionWithTrailingContentModifier(header: nil, trailing: trailing))
    }

    public func asSectionWithHeader<TrailingContent>(_ header: String, @ViewBuilder trailing: @escaping () -> TrailingContent) -> some View where TrailingContent: View {
        modifier(SectionWithTrailingContentModifier(header: header, trailing: trailing))
    }
}

public struct SectionWithTrailingContentModifier<TrailingContent>: ViewModifier where TrailingContent: View {
    let header: String?

    let trailing: () -> TrailingContent

    public func body(content: Content) -> some View {
        Section {
            content
#if os(iOS)
            trailing()
#elseif os(macOS)
            HStack {
                Spacer()
                trailing()
            }
#endif
        } header: {
            header.map(Text.init)
        }
    }
}
