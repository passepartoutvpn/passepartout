//
//  GenericCreditsView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/27/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

struct GenericCreditsView: View {
    struct License {
        let name: String

        let licenseName: String

        let licenseURL: URL

        init(_ name: String, _ licenseName: String, _ licenseURL: URL) {
            self.name = name
            self.licenseName = licenseName
            self.licenseURL = licenseURL
        }
    }

    struct Notice {
        let name: String

        let noticeString: String

        init(_ name: String, _ noticeString: String) {
            self.name = name
            self.noticeString = noticeString
        }
    }

    var licensesHeader: String? = "Licenses"

    var noticesHeader: String? = "Notices"

    var translationsHeader: String? = "Translations"

    let licenses: [License]

    let notices: [Notice]

    let translations: [String: String]

    @State private var contentForLicense: [String: String] = [:]

    var body: some View {
        List {
            if !licenses.isEmpty {
                licensesSection
            }
            if !notices.isEmpty {
                noticesSection
            }
            if !translations.isEmpty {
                translationsSection
            }
        }
    }

    private var sortedLicenses: [License] {
        licenses.sorted {
            $0.name.lowercased() < $1.name.lowercased()
        }
    }

    private var sortedNotices: [Notice] {
        notices.sorted {
            $0.name.lowercased() < $1.name.lowercased()
        }
    }

    private var sortedLanguages: [String] {
        translations.keys.sorted {
            $0.localizedAsCountryCode < $1.localizedAsCountryCode
        }
    }

    private var licensesSection: some View {
        Section(
            header: licensesHeader.map(Text.init)
        ) {
            ForEach(sortedLicenses, id: \.name) { license in
                NavigationLink {
                    LicenseView(
                        url: license.licenseURL,
                        content: $contentForLicense[license.name]
                    ).navigationTitle(license.name)
                } label: {
                    HStack {
                        Text(license.name)
                        Spacer()
                        Text(license.licenseName)
                    }
                }
            }
        }
    }

    private var noticesSection: some View {
        Section(
            header: noticesHeader.map(Text.init)
        ) {
            ForEach(sortedNotices, id: \.name) { notice in
                NavigationLink(notice.name, destination: noticeView(notice))
            }
        }
    }

    private var translationsSection: some View {
        Section(
            header: translationsHeader.map(Text.init)
        ) {
            ForEach(sortedLanguages, id: \.self) { code in
                HStack {
                    Text(code.localizedAsCountryCode)
                    Spacer()
                    translations[code].map { author in
                        Text(author)
                            .padding()
                    }
                }
            }
        }
    }

    private func noticeView(_ content: Notice) -> some View {
        VStack {
            Text(content.noticeString)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
        }.navigationTitle(content.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension GenericCreditsView {
    struct LicenseView: View {
        let url: URL

        @Binding var content: String?

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
                }
            }.onAppear(perform: loadURL)
        }

        private func loadURL() {
            guard content == nil else {
                return
            }
            Task { @MainActor in
                withAnimation {
                    do {
                        content = try String(contentsOf: url)
                    } catch {
                        content = error.localizedDescription
                    }
                }
            }
        }
    }
}

private extension String {
    var localizedAsCountryCode: String {
        Locale.current.localizedString(forLanguageCode: self)?.capitalized ?? self
    }
}
