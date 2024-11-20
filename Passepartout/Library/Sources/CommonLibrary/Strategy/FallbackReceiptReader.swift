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
import PassepartoutKit

public actor FallbackReceiptReader: AppReceiptReader {
    private let mainReader: InAppReceiptReader

    private nonisolated let betaReader: InAppReceiptReader?

    private var pendingTask: Task<InAppReceipt?, Never>?

    public init(
        main mainReader: InAppReceiptReader & Sendable,
        beta betaReader: (InAppReceiptReader & Sendable)?
    ) {
        self.mainReader = mainReader
        self.betaReader = betaReader
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
        pp_log(.App.iap, .debug, "\tParse receipt for user level \(userLevel)")
        if userLevel == .beta, let betaReader {
            pp_log(.App.iap, .debug, "\tTestFlight, read beta receipt")
            return await betaReader.receipt()
        }
        pp_log(.App.iap, .debug, "\tProduction, read main receipt")
        return await mainReader.receipt()
    }
}
