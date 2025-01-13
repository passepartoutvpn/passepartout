//
//  ContentView.swift
//  PassepartoutKit
//
//  Created by Davide De Rosa on 2/22/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of PassepartoutKit.
//
//  PassepartoutKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  PassepartoutKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with PassepartoutKit.  If not, see <http://www.gnu.org/licenses/>.
//

import PassepartoutKit
import SwiftUI

private enum ButtonAction {
    case connect

    case disconnect
}

struct ContentView: View {
    @State
    private var profile: Profile = .demo

    @StateObject
    private var vpn: Tunnel = .shared

    @State
    private var buttonAction: ButtonAction = .connect

    @State
    private var dataCount: DataCount?

    @State
    private var isLoadingDebugLog = false

    @State
    private var isDebugLogPresented = false

    @State
    private var debugLog: [String] = []

    private let timer = Timer.publish(every: 2.0, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        List {
            modulesSection
            vpnSection
            advancedSection
        }
        .navigationTitle("Passepartout")
        .onReceive(vpn.$status) {
            buttonAction = ButtonAction(forStatus: $0)
        }
        .onReceive(timer) { _ in
            guard vpn.status == .active else {
                dataCount = nil
                return
            }
            dataCount = Demo.environment.environmentValue(forKey: TunnelEnvironmentKeys.dataCount)
        }
        .sheet(isPresented: $isDebugLogPresented) {
            debugLogView
        }
        .task {
            do {
                try await vpn.prepare(purge: false)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

private extension ContentView {
    var modulesSection: some View {
        Section {
            ForEach(profile.modules, id: \.id) { module in
                HStack {
                    Button(module.moduleHandler.id.name) {
                        onTapModule(module)
                    }
                    if profile.isActiveModule(withId: module.id) {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }
        } header: {
            Text("Modules")
        }
    }

    var vpnSection: some View {
        Section {
            Button(buttonAction.title) {
                onButton()
            }
            HStack {
                Text("Status")
                Spacer()
                Text(vpn.status.localizedDescription)
            }
            dataCountDescription.map(Text.init)
        } header: {
            Text("VPN")
        }
    }

    var advancedSection: some View {
        Section {
            HStack {
                Button("Debug log") {
                    onDebugLog()
                }
                .disabled(isLoadingDebugLog)
                if isLoadingDebugLog {
                    Spacer()
                    ProgressView()
                }
            }
#if !os(tvOS)
            if profile.firstConnectionModule(ofType: OpenVPNModule.self, ifActive: true) != nil {
                NavigationLink("Server configuration") {
                    serverConfigurationView
                }
            }
#endif
        } header: {
            Text("Advanced")
        }
    }
}

private extension ContentView {
    var debugLogView: some View {
        NavigationStack {
            List {
                ForEach(Array(debugLog.enumerated()), id: \.offset) { entry in
                    Text(entry.element)
                }
            }
            .navigationTitle("Debug log")
            .toolbar {
                Button {
                    isDebugLogPresented = false
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .monospaced()
#if os(macOS)
            .frame(minWidth: 600.0, minHeight: 400.0)
#endif
        }
    }

#if !os(tvOS)
    var serverConfigurationView: some View {
        Demo.environment.environmentValue(forKey: TunnelEnvironmentKeys.OpenVPN.serverConfiguration)
            .map {
                TextEditor(text: .constant(String(describing: $0)))
                    .monospaced()
                    .padding()
            }
    }
#endif
}

// MARK: - Actions

private extension ContentView {
    func onTapModule(_ module: Module) {
        var builder = profile.builder()
        if module is ConnectionModule {
            builder.toggleExclusiveModule(withId: module.id) {
                $0 is ConnectionModule
            }
        } else {
            builder.toggleModule(withId: module.id)
        }
        do {
            profile = try builder.tryBuild()
        } catch {
            print("Unable to toggle module: \(error)")
        }
    }

    func onButton() {
        Task {
            do {
                switch buttonAction {
                case .connect:
                    try await vpn.install(profile, connect: true) {
                        "PassepartoutKitDemo: \($0.name)"
                    }

                case .disconnect:
                    try await vpn.disconnect()
                }
            } catch {
                print("Unable to start VPN: \(error.localizedDescription)")
            }
        }
    }

    func onDebugLog() {
        isLoadingDebugLog = true
        Task {
            defer {
                isLoadingDebugLog = false
            }
            do {
                try await fetchDebugLog()
                isDebugLogPresented = true
            } catch {
                print("Unable to fetch debug log: \(error)")
            }
        }
    }

    func fetchDebugLog() async throws {
        guard vpn.status != .inactive else {
            if PassepartoutConfiguration.shared.hasLocalLogger {
                debugLog = try String(contentsOf: Demo.Log.tunnelURL)
                    .split(separator: "\n")
                    .map(String.init)
            }
            return
        }

        let interval: TimeInterval = 24 * 60 * 60 // 1 day
        let message: Message.Input

        message = .localLog(sinceLast: interval, maxLevel: Demo.Log.maxLevel)

        guard let output = try await vpn.sendMessage(message) else {
            return
        }
        guard case .debugLog(let log) = output else {
            debugLog = []
            return
        }
        debugLog = log
            .lines
            .map(Demo.Log.formattedLine)
    }
}

private extension ButtonAction {
    init(forStatus status: TunnelStatus) {
        switch status {
        case .inactive:
            self = .connect

        default:
            self = .disconnect
        }
    }
}

// MARK: - L10n

private extension ButtonAction {
    var title: String {
        switch self {
        case .connect:
            return "Connect"

        case .disconnect:
            return "Disconnect"
        }
    }
}

private extension TunnelStatus {
    var localizedDescription: String {
        switch self {
        case .inactive:
            return "Inactive"

        case .activating:
            return "Activating"

        case .active:
            return "Active"

        case .deactivating:
            return "Deactivating"
        }
    }
}

private extension ContentView {
    var dataCountDescription: String? {
        guard vpn.status == .active, let dataCount else {
            return nil
        }
        let down = dataCount.received.descriptionAsDataUnit
        let up = dataCount.sent.descriptionAsDataUnit
        return "↓\(down) ↑\(up)"
    }
}

// MARK: - Previews

#Preview {
    ContentView()
}
