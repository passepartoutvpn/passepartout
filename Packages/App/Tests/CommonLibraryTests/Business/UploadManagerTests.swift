//
//  UploadManagerTests.swift
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

@testable import CommonLibrary
import Foundation
import XCTest

final class UploadManagerTests: XCTestCase {
}

@MainActor
extension UploadManagerTests {
    func test_givenUploader_whenStart_thenReceivesFiles() async throws {
        let webUploader = MockWebUploader(file: UploadManager.File(name: "name", contents: "contents"))
        let sut = UploadManager(webUploader: webUploader)
        let stream = sut.files
        let expReceive = expectation(description: "UploadReceive")
        let expEnd = expectation(description: "UploadEnd")
        Task {
            for await file in stream {
                XCTAssertEqual(file.name, "name")
                XCTAssertEqual(file.contents, "contents")
                expReceive.fulfill()
            }
            expEnd.fulfill()
        }
        try sut.start()
        await fulfillment(of: [expReceive])
        sut.destroy()
        await fulfillment(of: [expEnd])
    }
}

private final class MockWebUploader: WebUploader {
    private let file: UploadManager.File

    init(file: UploadManager.File) {
        self.file = file
    }

    func start(passcode: String?, onReceive: @escaping (String, String) -> Void) throws -> URL {
        onReceive(file.name, file.contents)
        return URL(fileURLWithPath: "")
    }

    func stop() {
    }
}
