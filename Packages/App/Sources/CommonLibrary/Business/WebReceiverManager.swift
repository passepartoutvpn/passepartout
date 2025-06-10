//
//  WebReceiverManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/4/25.
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

@MainActor
public final class WebReceiverManager: ObservableObject {
    public struct Website: Sendable {
        public let url: URL

        public let passcode: String?
    }

    public struct File: Sendable {
        public let name: String

        public let contents: String
    }

    public typealias PasscodeGenerator = () -> String

    private let webReceiver: WebReceiver

    private let passcodeGenerator: PasscodeGenerator?

    private let filesStream: PassthroughStream<File>

    public var isStarted: Bool {
        website != nil
    }

    @Published
    public private(set) var website: Website?

    public var files: AsyncStream<File> {
        filesStream.subscribe()
    }

    public init(
        webReceiver: WebReceiver,
        passcodeGenerator: PasscodeGenerator? = nil
    ) {
        self.webReceiver = webReceiver
        self.passcodeGenerator = passcodeGenerator
        filesStream = PassthroughStream()
    }

    public func start() throws {
        let passcode = passcodeGenerator?()
        let url = try webReceiver.start(passcode: passcode) { [weak self] in
            self?.filesStream.send(File(name: $0, contents: $1))
        }
        website = Website(url: url, passcode: passcode)
    }

    public func renewPasscode() {
        stop()
        try? start()
    }

    public func stop() {
        webReceiver.stop()
        website = nil
    }

    public func destroy() {
        stop()
        filesStream.finish()
    }
}
