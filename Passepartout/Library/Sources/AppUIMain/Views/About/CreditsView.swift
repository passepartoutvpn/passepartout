//
//  CreditsView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/27/24.
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

import CommonLibrary
import CommonUtils
import SwiftUI

struct CreditsView: View {
    var body: some View {
        GenericCreditsView(
            credits: Self.credits,
            licensesHeader: Strings.Views.About.Credits.licenses,
            noticesHeader: Strings.Views.About.Credits.notices,
            translationsHeader: Strings.Views.About.Credits.translations,
            errorDescription: {
                AppError($0)
                    .localizedDescription
            }
        )
        .navigationTitle(Strings.Views.About.Credits.title)
        .themeForm()
    }
}

private extension CreditsView {
    static let credits = Bundle.module.unsafeDecode(Credits.self, filename: "Credits")
}
