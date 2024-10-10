//
//  GenericCreditsView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/27/22.
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

import SwiftUI

public struct Credits: Decodable {
    public struct License: Decodable {
        public let name: String

        public let licenseName: String

        public let licenseURL: URL
    }

    public struct Notice: Decodable {
        public let name: String

        public let message: String
    }

    public let author: String

    public let licenses: [License]

    public let notices: [Notice]

    public let translations: [String: [String]]
}

public struct GenericCreditsView: View {
    private let credits: Credits

    private var licensesHeader: String?

    private var noticesHeader: String?

    private var translationsHeader: String?

    private let errorDescription: (Error) -> String

    @State
    private var contentForLicense: [String: String] = [:]

    public init(
        credits: Credits,
        licensesHeader: String? = nil,
        noticesHeader: String? = nil,
        translationsHeader: String? = nil,
        errorDescription: @escaping (Error) -> String
    ) {
        self.credits = credits
        self.licensesHeader = licensesHeader
        self.noticesHeader = noticesHeader
        self.translationsHeader = translationsHeader
        self.errorDescription = errorDescription
    }

    public var body: some View {
        Form {
            if !credits.licenses.isEmpty {
                licensesSection
            }
            if !credits.notices.isEmpty {
                noticesSection
            }
            if !credits.translations.isEmpty {
                translationsSection
            }
        }
    }
}

private extension GenericCreditsView {
    struct LicenseView: View {
        let url: URL

        let errorDescription: (Error) -> String

        @Binding
        var content: String?

        var body: some View {
            ZStack {
                content.map { unwrapped in
                    ScrollView {
                        Text(unwrapped)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding()
                    }
                }
                if content == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .onAppear(perform: loadURL)
        }
    }
}

// MARK: -

private extension GenericCreditsView {
    var sortedLicenses: [Credits.License] {
        credits.licenses.sorted {
            $0.name.lowercased() < $1.name.lowercased()
        }
    }

    var sortedNotices: [Credits.Notice] {
        credits.notices.sorted {
            $0.name.lowercased() < $1.name.lowercased()
        }
    }

    var sortedLanguages: [String] {
        credits.translations.keys.sorted {
            ($0.localizedAsLanguageCode ?? $0) < ($1.localizedAsLanguageCode ?? $1)
        }
    }

    var licensesSection: some View {
        Section {
            ForEach(sortedLicenses, id: \.name) { license in
                NavigationLink {
                    LicenseView(
                        url: license.licenseURL,
                        errorDescription: errorDescription,
                        content: $contentForLicense[license.name]
                    )
                    .navigationTitle(license.name)
                } label: {
                    HStack {
                        Text(license.name)
                        Spacer()
                        Text(license.licenseName)
                    }
                }
            }
        } header: {
            licensesHeader.map(Text.init)
        }
    }

    var noticesSection: some View {
        Section {
            ForEach(sortedNotices, id: \.name) { notice in
                NavigationLink(notice.name, destination: noticeView(notice))
            }
        } header: {
            noticesHeader.map(Text.init)
        }
    }

    var translationsSection: some View {
        Section {
            ForEach(sortedLanguages, id: \.self) { code in
                HStack {
                    Text(code.localizedAsLanguageCode ?? code)
                    Spacer()
                    credits.translations[code].map { authors in
                        VStack(spacing: 4) {
                            ForEach(authors, id: \.self) {
                                Text($0)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                    }
                }
            }
        } header: {
            translationsHeader.map(Text.init)
        }
    }

    func noticeView(_ content: Credits.Notice) -> some View {
        VStack {
            Text(content.message)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
        }
        .navigationTitle(content.name)
    }
}

// MARK: -

@MainActor
private extension GenericCreditsView.LicenseView {
    func loadURL() {
        guard content == nil else {
            return
        }
        Task {
            do {
                let session = URLSession(configuration: .ephemeral)
                let response = try await session.data(from: url)
                let string = String(data: response.0, encoding: .utf8)
                withAnimation {
                    content = string
                }
            } catch {
                withAnimation {
                    content = errorDescription(error)
                }
            }
        }
    }
}
