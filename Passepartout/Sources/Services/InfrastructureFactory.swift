//
//  InfrastructureFactory.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/2/18.
//  Copyright (c) 2018 Davide De Rosa. All rights reserved.
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
import SwiftyBeaver

private let log = SwiftyBeaver.self

class InfrastructureFactory {
    private static func embedded(withName name: Infrastructure.Name) -> Infrastructure {
        guard let url = Bundle.main.url(forResource: name.webName, withExtension: "json") else {
            fatalError("Cannot find JSON for infrastructure '\(name)'")
        }
        do {
            return try Infrastructure.loaded(from: url)
        } catch let e {
            fatalError("Cannot parse JSON for infrastructure '\(name)': \(e)")
        }
    }
    
    private static func isNewer(cachedEntry: URL, thanBundleWithName name: Infrastructure.Name) -> Bool {
        guard let cacheDate = FileManager.default.modificationDate(of: cachedEntry.path) else {
            return false
        }
        guard let bundleURL = Bundle.main.url(forResource: name.webName, withExtension: "json") else {
            return true
        }
        guard let bundleDate = FileManager.default.modificationDate(of: bundleURL.path) else {
            return true
        }
        return cacheDate > bundleDate
    }
    
    static let shared = InfrastructureFactory(withCacheDirectory: AppConstants.Store.infrastructureCacheDirectory)

    let allNames: [Infrastructure.Name] = [
        .pia
    ]
    
    private let bundle: [Infrastructure.Name: Infrastructure]

    private let cachePath: URL
    
    private var cache: [Infrastructure.Name: Infrastructure]

    private var lastUpdate: [Infrastructure.Name: Date]

    private init(withCacheDirectory cacheDirectory: String) {
        var bundle: [Infrastructure.Name: Infrastructure] = [:]
        allNames.forEach {
            bundle[$0] = InfrastructureFactory.embedded(withName: $0)
        }
        self.bundle = bundle

        cachePath = FileManager.default.userURL(for: .cachesDirectory, appending: cacheDirectory)
        cache = [:]
        lastUpdate = [:]
    }
    
    func loadCache() {
        let cacheEntries: [URL]
        do {
            cacheEntries = try FileManager.default.contentsOfDirectory(at: cachePath, includingPropertiesForKeys: nil)
        } catch let e {
            log.verbose("Error loading cache: \(e)")
            return
        }

        let decoder = JSONDecoder()
        for entry in cacheEntries {
            guard let data = try? Data(contentsOf: entry) else {
                continue
            }
            guard let infra = try? decoder.decode(Infrastructure.self, from: data) else {
                continue
            }

            // supersede if older than embedded
            guard InfrastructureFactory.isNewer(cachedEntry: entry, thanBundleWithName: infra.name) else {
                log.warning("Bundle is newer than cache, superseding cache for \(infra.name)")
                cache[infra.name] = bundle[infra.name]
                continue
            }

            cache[infra.name] = infra
            log.debug("Loading cache for \(infra.name)")
        }
    }
    
    func get(_ name: Infrastructure.Name) -> Infrastructure {
        guard let infra = cache[name] ?? bundle[name] else {
            fatalError("No infrastructure embedded nor cached for '\(name)'")
        }
        return infra
    }

    func update(_ name: Infrastructure.Name, notBeforeInterval minInterval: TimeInterval?, completionHandler: @escaping ((Infrastructure, Date)?, Error?) -> Void) -> Bool {
        let ifModifiedSince = modificationDate(for: name)
        
        if let lastInfrastructureUpdate = lastUpdate[name] {
            log.debug("Last update for \(name): \(lastUpdate)")

            if let minInterval = minInterval {
                let elapsed = -lastInfrastructureUpdate.timeIntervalSinceNow
                guard elapsed >= minInterval else {
                    log.warning("Skipping update, only \(elapsed) seconds elapsed (< \(minInterval))")
                    return false
                }
            }
        }
        
        WebServices.shared.network(with: name, ifModifiedSince: ifModifiedSince) { (response, error) in
            if error == nil {
                self.lastUpdate[name] = Date()
            }

            guard let response = response, let infra = response.value, let lastModified = response.lastModified else {
                log.error("No response from web service or missing Last-Modified")
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            let appBuild = GroupConstants.App.buildNumber
            guard appBuild >= infra.build else {
                log.error("Response requires app build >= \(infra.build) (found \(appBuild))")
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            var isNewer = true
            if let bundleDate = self.bundleModificationDate(for: name) {
                log.verbose("Bundle date: \(bundleDate)")
                log.verbose("Web date:    \(lastModified)")

                isNewer = lastModified > bundleDate
            }
            guard isNewer else {
                log.warning("Web service infrastructure is older than bundle, discarding")
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }

            self.save(name, with: infra, lastModified: lastModified)

            DispatchQueue.main.async {
                completionHandler((infra, lastModified), nil)
            }
        }
        return true
    }

    func modificationDate(for name: Infrastructure.Name) -> Date? {
        let optBundleDate = bundleModificationDate(for: name)
        guard let cacheDate = cacheModificationDate(for: name) else {
            return optBundleDate
        }
        guard let bundleDate = optBundleDate else {
            return cacheDate
        }
        return max(cacheDate, bundleDate)
    }
    
    private func save(_ name: Infrastructure.Name, with infrastructure: Infrastructure, lastModified: Date) {
        cache[name] = infrastructure
        
        let fm = FileManager.default
        let url = cacheURL(for: name)
        do {
            try fm.createDirectory(at: cachePath, withIntermediateDirectories: true, attributes: nil)
            let data = try JSONEncoder().encode(infrastructure)
            try data.write(to: url)
            try fm.setAttributes([.modificationDate: lastModified], ofItemAtPath: url.path)
        } catch let e {
            log.error("Error saving cache: \(e)")
        }
    }
    
    private func cacheURL(for name: Infrastructure.Name) -> URL {
        return cachePath.appendingPathComponent(name.webName).appendingPathExtension("json")
    }

    private func cacheModificationDate(for name: Infrastructure.Name) -> Date? {
        let url = cacheURL(for: name)
        return FileManager.default.modificationDate(of: url.path)
    }

    private func bundleURL(for name: Infrastructure.Name) -> URL {
        return Bundle.main.url(forResource: name.webName, withExtension: "json")!
    }

    private func bundleModificationDate(for name: Infrastructure.Name) -> Date? {
        let url = bundleURL(for: name)
        return FileManager.default.modificationDate(of: url.path)
    }
}
