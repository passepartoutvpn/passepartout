//
//  DebugLogView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/22.
//  Copyright (c) 2022 Davide De Rosa. All rights reserved.
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

import SwiftUI
import Combine
import PassepartoutCore

struct DebugLogView: View {
    private let url: URL
    
    private let timer: AnyPublisher<Date, Never>
    
    @State private var logLines: [String] = []
    
    @State private var isSharing = false
    
    private let maxBytes = UInt64(Constants.Log.tunnelLogMaxBytes)

    private let appName = Constants.Global.appName

    private let appVersion = Constants.Global.appVersionString
    
    private let shareFilename = Unlocalized.Issues.Filenames.debugLog
    
    init(url: URL, updateInterval: TimeInterval) {
        self.url = url
        timer = Timer.TimerPublisher(interval: updateInterval, runLoop: .main, mode: .common)
            .autoconnect()
            .eraseToAnyPublisher()
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(showsIndicators: true) {
                contentView
            }.toolbar(content: toolbar)
            .onAppear {
                refreshLog(scrollingToLatestWith: scrollProxy)
            }.onReceive(timer, perform: refreshLog)
        }.sheet(isPresented: $isSharing, content: sharingActivityView)
        .navigationTitle(L10n.DebugLog.title)
        .themeDebugLogFont()
        .edgesIgnoringSafeArea([.leading, .trailing])
    }

    private func toolbar() -> some View {
        Button(action: shareDebugLog) {
            themeShareImage.asSystemImage
        }.replacedWithProgress(when: isSharing)
        .disabled(logLines.isEmpty)
    }
    
    private var contentView: some View {
        LazyVStack {
            ForEach(logLines.indices, id: \.self) {
                Text(logLines[$0])
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }//.padding()
        // FIXME: layout, a slight padding would be nice, but it glitches on first touch
    }
    
    private func refreshLog(scrollingToLatestWith scrollProxy: ScrollViewProxy?) {
        logLines = url.trailingLines(bytes: maxBytes)
        if let scrollProxy = scrollProxy {
            scrollToLatestUpdate(scrollProxy)
        }
    }
    
    private func refreshLog(_: Date) {
        refreshLog(scrollingToLatestWith: nil)
    }
    
    private func shareDebugLog() {
        guard !logLines.isEmpty else {
            assertionFailure("Log is empty, why could it share?")
            return
        }
        isSharing = true
    }
}

extension DebugLogView {
    private func sharingActivityView() -> some View {
        ActivityView(activityItems: sharingItems)
    }

    private var sharingItems: [Any] {
        let raw = logLines.joined(separator: "\n")
        let data = DebugLog(content: raw).decoratedData(appName, appVersion)

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

extension DebugLogView {
    private func scrollToLatestUpdate(_ proxy: ScrollViewProxy) {
        proxy.maybeScrollTo(logLines.count - 1, anchor: .bottomLeading)
    }
}
