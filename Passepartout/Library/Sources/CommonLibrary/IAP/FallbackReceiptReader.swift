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

        if let receipt = await reader?.receipt() {

            // fetch build number from local receipt
            if let localURL,
               let local = localReader(localURL),
               let localReceipt = await local.receipt(),
               let build = localReceipt.originalBuildNumber {

                return receipt.withBuildNumber(build)
            }
            return receipt
        }

        // fall back to release/sandbox receipt
        guard let localURL else {
            return nil
        }

        // attempt fallback from primary to local receipt
        pp_log(.app, .error, "Primary receipt not found, falling back to local receipt")
        if let local = localReader(localURL), let localReceipt = await local.receipt() {
            return localReceipt
        }

        // in TestFlight, attempt fallback from sandbox to release receipt
        if userLevel == .beta {
            let releaseURL = localURL
                .deletingLastPathComponent()
                .appendingPathComponent("receipt")

            guard releaseURL != localURL else {
#if !os(macOS) && !targetEnvironment(simulator)
                assertionFailure("How can release URL be equal to sandbox URL in TestFlight?")
#endif
                return nil
            }
            pp_log(.app, .error, "Sandbox receipt not found, falling back to Release receipt")
            let release = localReader(releaseURL)
            return await release?.receipt()
        }

        return nil
    }
}
