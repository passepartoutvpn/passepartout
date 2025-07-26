// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

import SwiftUI

public struct PasscodeInputView: View {
    private let length: Int

    private let onEnter: (String) async throws -> Void

    @FocusState
    private var focusedIndex: Int?

    @State
    private var passcode: [String] = []

    public init(length: Int, onEnter: @escaping (String) async throws -> Void) {
        self.length = length
        self.onEnter = onEnter
    }

    public var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<length, id: \.self) { i in
                TextField("", text: digitBinding(at: i))
#if os(iOS)
                    .keyboardType(.numberPad)
#endif
                    .multilineTextAlignment(.center)
                    .focused($focusedIndex, equals: i)
                    .frame(width: 40, height: 60)
                    .font(.title)
                    .border(.secondary)
                    .onChange(of: digit(at: i)) {
                        handleDigit($0, at: i)
                    }
            }
        }
        .padding()
        .onAppear {
            focusedIndex = 0
        }
    }
}

private extension PasscodeInputView {
    func digit(at i: Int) -> String {
        i < passcode.count ? passcode[i] : ""
    }

    func digitBinding(at i: Int) -> Binding<String> {
        Binding {
            digit(at: i)
        } set: {
            if i >= passcode.count {
                let padding = Array(repeating: "", count: length - passcode.count)
                passcode.append(contentsOf: padding)
            }
            passcode[i] = $0
        }
    }

    func handleDigit(_ digit: String, at i: Int) {
        guard i < passcode.count else {
            return
        }
        passcode[i] = String(digit.prefix(1))
        if !digit.isEmpty && i < length - 1 {
            focusedIndex = i + 1
        } else {
            focusedIndex = nil
        }
        if passcode.count == length,
           passcode.allSatisfy({ !$0.isEmpty }) {
            Task {
                do {
                    try await onEnter(passcode.joined())
                } catch {
                    passcode = []
                    setLater(0, millis: 200) {
                        focusedIndex = $0
                    }
                }
            }
        }
    }
}

#Preview {
    PasscodeInputView(length: 6) {
        print($0)
    }
}
