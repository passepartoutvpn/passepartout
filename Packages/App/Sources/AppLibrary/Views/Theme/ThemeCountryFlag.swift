//
//  ThemeCountryFlag.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/1/24.
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

import SwiftUI

public struct ThemeCountryFlag: View {
    private let code: String?

    private let placeholderTip: String?

    private let countryTip: ((String) -> String?)?

    public init(_ code: String?, placeholderTip: String? = nil, countryTip: ((String) -> String?)? = nil) {
        self.code = code
        self.placeholderTip = placeholderTip
        self.countryTip = countryTip
    }

    public var body: some View {
        if let code {
            text(withString: code.asCountryCodeEmoji, tip: countryTip?(code))
        } else {
            text(withString: "🌐", tip: placeholderTip)
        }
    }

    @ViewBuilder
    private func text(withString string: String, tip: String?) -> some View {
        if let tip {
            Text(verbatim: string)
                .help(tip)
        } else {
            Text(verbatim: string)
        }
    }
}
