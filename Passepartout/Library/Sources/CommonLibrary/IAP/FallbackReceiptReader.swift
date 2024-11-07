//
//  FallbackReceiptReader.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/6/24.
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

import CommonUtils
import Foundation
import Kvitto
import PassepartoutKit

public actor FallbackReceiptReader: AppReceiptReader {
    private let reader: InAppReceiptReader?

    private let localReader: (URL) -> InAppReceiptReader?

    public init(
        reader: (InAppReceiptReader & Sendable)?,
        localReader: @escaping @Sendable (URL) -> InAppReceiptReader & Sendable
    ) {
        self.reader = reader
        self.localReader = localReader
    }

    public func receipt(at userLevel: AppUserLevel) async -> InAppReceipt? {
        let localURL = Bundle.main.appStoreReceiptURL

        pp_log(.app, .info, "Parse receipt for user level \(userLevel)")

        // in TestFlight, rely on release receipt
        let releaseReceipt: InAppReceipt? = await {
            guard userLevel == .beta, let localURL else {
                return nil
            }
            let releaseURL = localURL
                .deletingLastPathComponent()
                .appendingPathComponent("receipt")

            guard releaseURL != localURL else {
#if !os(macOS) && !targetEnvironment(simulator)
                assertionFailure("How can release URL be equal to Sandbox URL in TestFlight?")
#endif
                return nil
            }
            pp_log(.app, .info, "\tTestFlight build, look for release receipt")
            let release = localReader(releaseURL)
            return await release?.receipt()
        }()

        if let releaseReceipt {
            return releaseReceipt
        }

        // primary reader
        pp_log(.app, .info, "\tNo release receipt, read primary receipt")
        let receipt = await reader?.receipt()

        let localReceiptBlock: () async -> InAppReceipt? = { [weak self] in
            guard let localURL, let local = self?.localReader(localURL) else {
                return nil
            }
            pp_log(.app, .info, "\tRead local receipt")
            return await local.receipt()
        }

        // primary receipt + build from local receipt
        if let receipt {
            if let build = await localReceiptBlock()?.originalBuildNumber {
                pp_log(.app, .info, "\tRead build number from local receipt: \(build)")
                return receipt.withBuildNumber(build)
            }
            return receipt
        }
        // fall back to local receipt
        else {
            return await localReceiptBlock()
        }
    }
}
