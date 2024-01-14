//
//  DebugLogView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/22.
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

import Combine
import PassepartoutLibrary
import SwiftUI

struct DebugLogView: View {
    private let title: String

    private let url: URL

    private let shareFilename: String

    private let timer: AnyPublisher<Date, Never>

    @State private var logLines: [String] = []

    @State private var isSharing = false

    private let maxBytes = UInt64(Constants.Log.maxBytes)

    private let appName = Constants.Global.appName

    private let appVersion = Constants.Global.appVersionString

    init(title: String, url: URL, filename: String, refreshInterval: TimeInterval?) {
        self.title = title
        self.url = url
        shareFilename = filename
        if let refreshInterval {
            timer = Timer.TimerPublisher(interval: refreshInterval, runLoop: .main, mode: .common)
                .autoconnect()
                .eraseToAnyPublisher()
        } else {
            timer = Empty(outputType: Date.self, failureType: Never.self)
                .eraseToAnyPublisher()
        }
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(showsIndicators: true) {
                contentView
            }.onAppear {
                refreshLog(scrollingToLatestWith: scrollProxy)
            }
        }
        #if !os(tvOS)
        #if targetEnvironment(macCatalyst)
        .toolbar {
            Button(action: copyDebugLog) {
                themeCopyImage.asSystemImage
            }.disabled(logLines.isEmpty)
        }
        #else
        .toolbar {
            if !isSharing {
                Button(action: shareDebugLog) {
                    themeShareImage.asSystemImage
                }.disabled(logLines.isEmpty)
            } else {
                ProgressView()
            }
        }
        .sheet(isPresented: $isSharing, content: sharingActivityView)
        #endif
        #endif
        .edgesIgnoringSafeArea([.leading, .trailing])
        .onReceive(timer, perform: refreshLog)
        .navigationTitle(title)
        .themeDebugLogStyle()
    }
}

// MARK: -

private extension DebugLogView {
    var contentView: some View {
        LazyVStack {
            ForEach(logLines.indices, id: \.self) {
                Text(logLines[$0])
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }// .padding()
        // TODO: layout, a slight padding would be nice, but it glitches on first touch
    }

    #if !os(tvOS)
    func sharingActivityView() -> some View {
        ActivityView(activityItems: sharingItems)
    }
    #endif

    var sharingItems: [Any] {
        let raw = logLines.joined(separator: "\n")
        let data = DebugLog(content: raw)
            .decoratedData(appName, appVersion)

        let path = NSTemporaryDirectory().appending(shareFilename)
        let url = URL(fileURLWithPath: path)
        do {
            try data.write(to: url)
            return [url]
        } catch {
            // highly unlikely to happen
            assertionFailure("Unable to save temporary debug log file: \(error)")
            return []
        }
    }
}

// MARK: -

private extension DebugLogView {
    func refreshLog(_: Date) {
        refreshLog(scrollingToLatestWith: nil)
    }

    func refreshLog(scrollingToLatestWith scrollProxy: ScrollViewProxy?) {
        logLines = url.trailingLines(bytes: maxBytes)
        if let scrollProxy = scrollProxy {
            scrollToLatestUpdate(scrollProxy)
        }
    }

    #if !os(tvOS)
    func shareDebugLog() {
        guard !logLines.isEmpty else {
            assertionFailure("Log is empty, why could it share?")
            return
        }
        isSharing = true
    }

    func copyDebugLog() {
        guard !logLines.isEmpty else {
            assertionFailure("Log is empty, why could it copy?")
            return
        }
        let raw = logLines.joined(separator: "\n")
        let content = DebugLog(content: raw)
            .decoratedString(appName, appVersion)

        Utils.copyToPasteboard(content)
    }
    #endif

    func scrollToLatestUpdate(_ proxy: ScrollViewProxy) {
        proxy.maybeScrollTo(logLines.count - 1, anchor: .bottomLeading)
    }
}
