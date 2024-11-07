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

    private var pendingTask: Task<InAppReceipt?, Never>?

    public init(
        reader: (InAppReceiptReader & Sendable)?,
        localReader: @escaping @Sendable (URL) -> InAppReceiptReader & Sendable
    ) {
        self.reader = reader
        self.localReader = localReader
    }

    public func receipt(at userLevel: AppUserLevel) async -> InAppReceipt? {
        if let pendingTask {
            _ = await pendingTask.value
        }
        pendingTask = Task {
            await asyncReceipt(at: userLevel)
        }
        let receipt = await pendingTask?.value
        pendingTask = nil
        return receipt
    }
}

private extension FallbackReceiptReader {
    func asyncReceipt(at userLevel: AppUserLevel) async -> InAppReceipt? {
        let localURL = Bundle.main.appStoreReceiptURL

        pp_log(.iap, .debug, "\tParse receipt for user level \(userLevel)")

        // 1. TestFlight, look for release receipt
        let releaseReceipt: InAppReceipt? = await {
            guard userLevel == .beta, let localURL else {
                return nil
            }
            pp_log(.iap, .debug, "\tTestFlight, look for release receipt")
            let releaseURL = localURL
                .deletingLastPathComponent()
                .appendingPathComponent("receipt")

            guard releaseURL != localURL else {
#if !os(macOS) && !targetEnvironment(simulator)
                assertionFailure("How can release URL be equal to Sandbox URL in TestFlight?")
#endif
                return nil
            }
            let release = localReader(releaseURL)
            return await release?.receipt()
        }()

        if let releaseReceipt {
            pp_log(.iap, .debug, "\tTestFlight, return release receipt")
            return releaseReceipt
        }

        let localReceiptBlock: () async -> InAppReceipt? = { [weak self] in
            guard let localURL, let local = self?.localReader(localURL) else {
                return nil
            }
            return await local.receipt()
        }

        // 2. primary receipt + build from local receipt
        pp_log(.iap, .debug, "\tNo release receipt, read primary receipt")
        if let receipt = await reader?.receipt() {
            if let build = await localReceiptBlock()?.originalBuildNumber {
                pp_log(.iap, .debug, "\tReturn primary receipt with local build: \(build)")
                return receipt.withBuildNumber(build)
            }
            pp_log(.iap, .debug, "\tReturn primary receipt without local build")
            return receipt
        }

        // 3. fall back to local receipt
        pp_log(.iap, .debug, "\tReturn local receipt")
        return await localReceiptBlock()
    }
}
