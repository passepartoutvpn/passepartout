//
//  AppError.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/27/24.
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

import CommonUtils
import Foundation

public enum AppError: Error {
    case couldNotLaunch(reason: Error)

    case emptyProducts

    case emptyProfileName

    case ineligibleProfile(Set<AppFeature>)

    case interactiveLogin

    case malformedModule(any ModuleBuilder, error: Error)

    case notFound

    case partout(PartoutError)

    case permissionDenied

    case rateLimit

    case systemExtension(SystemExtensionManager.Result)

    case timeout

    case unknown

    case verificationReceiptIsLoading

    case verificationRequiredFeatures(Set<AppFeature>)

    case webReceiver(Error? = nil)

    case webUploader(Int?, Error?)

    public init(_ error: Error) {
        if let spError = error as? AppError {
            self = spError
        } else {
            self = .partout(PartoutError(error))
        }
    }
}

extension PartoutError.Code {
    public enum App {
        public static let ineligibleProfile = PartoutError.Code("App.ineligibleProfile")

        public static let multipleTunnels = PartoutError.Code("App.multipleTunnels")
    }
}
