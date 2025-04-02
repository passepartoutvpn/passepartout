//
//  WebView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 4/2/25.
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

#if !os(tvOS)

import SwiftUI
import WebKit

public struct WebView<Coordinator> {
    private let make: () -> Coordinator

    private let update: (WKWebView, Coordinator) -> Void

    public init(
        make: @escaping () -> Coordinator,
        update: @escaping (WKWebView, Coordinator) -> Void
    ) {
        self.make = make
        self.update = update
    }
}

#if os(iOS)

extension WebView: UIViewRepresentable {
    public func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    public func makeCoordinator() -> Coordinator {
        make()
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
        update(uiView, context.coordinator)
    }
}

#else

extension WebView: NSViewRepresentable {
    public func makeNSView(context: Context) -> WKWebView {
        WKWebView()
    }

    public func makeCoordinator() -> Coordinator {
        make()
    }

    public func updateNSView(_ nsView: WKWebView, context: Context) {
        update(nsView, context.coordinator)
    }
}

#endif

#endif
