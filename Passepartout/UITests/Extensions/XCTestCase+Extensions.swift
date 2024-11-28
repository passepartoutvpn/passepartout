//
//  XCTestCase+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/28/24.
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

import Foundation
import SwiftUI
import XCTest

extension XCTestCase {
    enum ScreenshotDestination {
        case attachment

        case temporary
    }

    enum ScreenshotTarget {
        case sheet

        case window
    }
}

extension XCTestCase.ScreenshotDestination {
    var url: URL {
        switch self {
        case .attachment:
            fatalError("Can this be found?")
        case .temporary:
            return URL(fileURLWithPath: NSTemporaryDirectory())
        }
    }
}

@MainActor
extension XCUIApplicationProviding where Self: XCTestCase {
    func snapshot(
        _ name: String,
        destination: ScreenshotDestination = .temporary,
        target: ScreenshotTarget = .window
    ) throws {
        let container = container(for: target)
        let screenshot = container.screenshot()

        switch destination {
        case .attachment:
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)

        case .temporary:
            let filename = deviceFilename(for: name)
            let url = URL(fileURLWithPath: filename, relativeTo: destination.url)
            try screenshot.pngRepresentation.write(to: url)
        }
    }

    private func deviceFilename(for name: String) -> String {
#if os(iOS)
        let device = UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone"
#elseif os(macOS)
        let device = "Mac"
#elseif os(tvOS)
        let device = "AppleTV"
#endif
        return "\(name)_\(device).png"
    }

    private func container(for target: ScreenshotTarget) -> XCUIElement {
#if os(iOS)
        app.windows.firstMatch
#else
        switch target {
        case .sheet:
            return app.sheets.firstMatch
        case .window:
            return app.windows.firstMatch
        }
#endif
    }
}
