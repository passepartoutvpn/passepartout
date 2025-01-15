//
//  EndpointCardView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 1/5/25.
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

import PassepartoutKit
import SwiftUI

public struct EndpointCardView: View {
    private let endpoint: ExtendedEndpoint

    public init(endpoint: ExtendedEndpoint) {
        self.endpoint = endpoint
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(endpoint.address.rawValue)
                .font(.headline)

            Text("\(endpoint.proto.socketType.rawValue):\(endpoint.proto.port.description)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
