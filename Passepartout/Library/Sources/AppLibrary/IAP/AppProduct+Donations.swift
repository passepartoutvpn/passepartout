//
//  AppProduct+Donations.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/10/24.
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

import Foundation

extension AppProduct {
    public enum Donations {
        public static let tiny = AppProduct(donationId: "Tiny")

        public static let small = AppProduct(donationId: "Small")

        public static let medium = AppProduct(donationId: "Medium")

        public static let big = AppProduct(donationId: "Big")

        public static let huge = AppProduct(donationId: "Huge")

        public static let maxi = AppProduct(donationId: "Maxi")

        static let all: [AppProduct] = [
            .Donations.tiny,
            .Donations.small,
            .Donations.medium,
            .Donations.big,
            .Donations.huge,
            .Donations.maxi
        ]
    }

    private init(donationId: String) {
        self.init(rawValue: "donations.\(donationId)")!
    }

    var isDonation: Bool {
        rawValue.hasPrefix("donations")
    }
}
