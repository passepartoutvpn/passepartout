//
//  MultipartFormTests.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/12/24.
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
import XCTest

final class MultipartFormTests: XCTestCase {
    func test_givenBody_whenParseForm_thenReturnsFields() throws {
        let passcode = "123"
        let fileName = "some-filename.txt"
        let fileContents = "This is the file content"

        let body = """
------WebKitFormBoundaryUtFggDFvBDn88T9z\r
Content-Disposition: form-data; name=\"passcode\"\r
\r
\(passcode)\r
------WebKitFormBoundaryUtFggDFvBDn88T9z\r
Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r
Content-Type: application/octet-stream\r
\r
\(fileContents)\r
------WebKitFormBoundaryUtFggDFvBDn88T9z--\r
"""

        let sut = try XCTUnwrap(MultipartForm(body: body))

        XCTAssertNil(sut.fields["passcode"]?.filename)
        XCTAssertEqual(sut.fields["passcode"]?.value, passcode)
        XCTAssertEqual(sut.fields["file"]?.filename, fileName)
        XCTAssertEqual(sut.fields["file"]?.value, fileContents)
    }
}
