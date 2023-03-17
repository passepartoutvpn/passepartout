//
//  Utils+Async.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/25/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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
import Combine

// https://medium.com/geekculture/from-combine-to-async-await-c08bf1d15b77

enum AsyncPublisherError: Error {
    case discarded
}

extension Publisher {
    public func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var isResumed = false

            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        if !isResumed {
                            continuation.resume(with: .failure(AsyncPublisherError.discarded))
                        }

                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    continuation.resume(with: .success(value))
                    isResumed = true
                }
        }
    }
}

extension Task where Success == Never, Failure == Never {
    public static func maybeWait(forMilliseconds msec: Int?) async {
        guard let msec = msec else {
            return
        }
        try? await sleep(nanoseconds: UInt64(msec) * NSEC_PER_MSEC)
    }
}
