//
//  InfrastructureFactory.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/2/18.
//  Copyright (c) 2021 Davide De Rosa. All rights reserved.
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

// TODO: retain max N infrastructures at a time (LRU)

public class InfrastructureFactory {
    public static let shared = InfrastructureFactory()

    private let cachePath: URL
    
    fileprivate var cachedMetadata: [Infrastructure.Metadata]

    private var cachedInfrastructures: [Infrastructure.Name: Infrastructure]

    private var lastUpdate: [Infrastructure.Name: Date]

    private init() {
        cachePath = GroupConstants.App.cachesURL
        cachedMetadata = []
        cachedInfrastructures = [:]
        lastUpdate = [:]
    }
    
    // MARK: Storage
    
    public func preload() {
        loadMetadata()
        loadInfrastructures()
    }
    
    public func loadMetadata() {
        let decoder = JSONDecoder()

        // pick cache if newer
        if Utils.isFile(at: cacheMetadataURL, newerThanFileAt: bundledMetadataURL) {
            do {
                let indexData = try Data(contentsOf: cacheMetadataURL)
                cachedMetadata = try decoder.decode([Infrastructure.Metadata].self, from: indexData)
                log.debug("Loaded metadata from cache: \(cachedMetadata)")
                return
            } catch let e {
                log.warning("No index in cache: \(e)")
            }
        } else {
            log.warning("Bundle is newer than cache, superseding cache for index")
        }
    
        // fall back to bundled index
        guard let bundleURL = bundledMetadataURL else {
            fatalError("Unable to build index bundleURL")
        }
        do {
            let indexData = try Data(contentsOf: bundleURL)
            cachedMetadata = try decoder.decode([Infrastructure.Metadata].self, from: indexData)
            log.debug("Loaded index from bundle: \(cachedMetadata)")
        } catch let e {
            log.error("Unable to load index from bundle: \(e)")
        }
    }

    public func loadInfrastructures() {
        let apiPath = cachePath.appendingPathComponent(AppConstants.Store.apiDirectory)
        let providersPath = apiPath.appendingPathComponent(WebServices.Group.providers.rawValue)
        
        log.debug("Loading cache from: \(providersPath)")
        let cacheProvidersEntries: [URL]
        do {
            cacheProvidersEntries = try FileManager.default.contentsOfDirectory(at: providersPath, includingPropertiesForKeys: nil)
        } catch let e {
            log.warning("Error loading cache or nothing cached: \(e)")

            cachedMetadata.forEach {
                guard let infra = bundledInfrastructure(withName: $0.name) else {
                    log.warning("Missing infrastructure \($0.name) from bundle")
                    return
                }
                cachedInfrastructures[$0.name] = infra
                log.debug("Loaded infrastructure \($0.name) from bundle")
            }
            return
        }
        
        let decoder = JSONDecoder()
        for entry in cacheProvidersEntries {
            let name = entry.lastPathComponent

            // skip *.json (index.json presumably)
            guard !name.hasSuffix(".json") else {
                continue
            }

            // pick cache if newer
            if Utils.isFile(at: entry, newerThanFileAt: name.bundleURL) {
                let infraPath = WebServices.Endpoint.providerNetwork(name).apiURL(relativeTo: cachePath)
                do {
                    let infraData = try Data(contentsOf: infraPath)
                    let infra = try decoder.decode(Infrastructure.self, from: infraData)
                    cachedInfrastructures[name] = infra
                    log.debug("Loaded infrastructure \(name) from cache")
                    continue
                } catch let e {
                    log.warning("Unable to load infrastructure \(entry.lastPathComponent): \(e)")
//                    if let json = String(data: data, encoding: .utf8) {
//                        log.warning(json)
//                    }
                }
            } else {
                log.warning("Bundle is newer than cache, superseding cache for \(name)")
            }

            // fall back to bundle
            guard let infra = bundledInfrastructure(withName: name) else {
                log.warning("Missing infrastructure \(name) from bundle")
                continue
            }
            cachedInfrastructures[name] = infra
            log.debug("Loaded infrastructure \(name) from bundle")
        }

        // fill up with bundled
        cachedMetadata.forEach {
            if cachedInfrastructures[$0.name] == nil {
                guard let infra = bundledInfrastructure(withName: $0.name) else {
                    log.warning("Missing infrastructure \($0.name) from bundle")
                    return
                }
                cachedInfrastructures[$0.name] = infra
                log.debug("Loaded infrastructure \($0.name) from bundle")
            }
        }
    }
    
    public var allMetadata: [Infrastructure.Metadata] {
        return cachedMetadata
    }
    
    public func metadata(forName name: Infrastructure.Name) -> Infrastructure.Metadata? {
        return cachedMetadata.first(where: { $0.name == name})
    }

    public func infrastructure(forName name: Infrastructure.Name) -> Infrastructure? {
        return cachedInfrastructures[name]
    }
    
    private func bundledInfrastructure(withName name: Infrastructure.Name) -> Infrastructure? {
        guard let url = name.bundleURL else {
            return nil
        }
        do {
            return try Infrastructure.from(url: url)
        } catch let e {
            fatalError("Cannot parse JSON for infrastructure '\(name)': \(e)")
        }
    }
    
    // MARK: Web services

    public func updateIndex(completionHandler: @escaping (Error?) -> Void) {
        WebServices.shared.providersIndex {
            if let response = $0 {
                self.saveIndex(with: response)
            }
            completionHandler($1)
        }
    }

    public func update(_ name: Infrastructure.Name, notBeforeInterval minInterval: TimeInterval?, completionHandler: @escaping ((Infrastructure, Date)?, Error?) -> Void) -> Bool {
        let ifModifiedSince = modificationDate(forName: name)
        
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
        
        WebServices.shared.providerNetwork(with: name, ifModifiedSince: ifModifiedSince) { (response, error) in
            if error == nil {
                self.lastUpdate[name] = Date()
            }

            guard let response = response else {
                log.error("No response from web service")
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            if response.isCached {
                log.debug("Cache is up to date")
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            guard let infra = response.value, let lastModified = response.lastModified else {
                log.error("No response from web service or missing Last-Modified")
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            let appBuild = GroupConstants.App.buildNumber
            guard appBuild >= infra.buildNumber else {
                log.error("Response requires app build >= \(infra.build) (found \(appBuild))")
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            var isNewer = true
            if let bundleDate = self.bundleModificationDate(forName: name) {
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

    private func saveIndex(with metadata: [Infrastructure.Metadata]) {
        cachedMetadata = metadata
        
        let fm = FileManager.default
        let url = cacheMetadataURL
        do {
            let parent = url.deletingLastPathComponent()
            try fm.createDirectory(at: parent, withIntermediateDirectories: true, attributes: nil)
            let data = try JSONEncoder().encode(metadata)
            try data.write(to: url)
        } catch let e {
            log.error("Error saving index to cache: \(e)")
        }
    }

    private func save(_ name: Infrastructure.Name, with infrastructure: Infrastructure, lastModified: Date) {
        cachedInfrastructures[name] = infrastructure
        
        let fm = FileManager.default
        let url = cacheURL(forName: name)
        do {
            let parent = url.deletingLastPathComponent()
            try fm.createDirectory(at: parent, withIntermediateDirectories: true, attributes: nil)
            let data = try JSONEncoder().encode(infrastructure)
            try data.write(to: url)
            try fm.setAttributes([.modificationDate: lastModified], ofItemAtPath: url.path)
        } catch let e {
            log.error("Error saving infrastructure \(name) to cache: \(e)")
        }
    }

    // MARK: URLs
    
    private var cacheMetadataURL: URL {
        return WebServices.Endpoint.providersIndex.apiURL(relativeTo: cachePath)
    }
    
    private func cacheURL(forName name: Infrastructure.Name) -> URL {
        return WebServices.Endpoint.providerNetwork(name).apiURL(relativeTo: cachePath)
    }
    
    private var bundledMetadataURL: URL? {
        return WebServices.Endpoint.providersIndex.bundleURL(in: Bundle(for: InfrastructureFactory.self))
    }

    // MARK: Modification dates

    public func modificationDate(forName name: Infrastructure.Name) -> Date? {
        let optBundleDate = bundleModificationDate(forName: name)
        guard let cacheDate = cacheModificationDate(forName: name) else {
            return optBundleDate
        }
        guard let bundleDate = optBundleDate else {
            return cacheDate
        }
        return max(cacheDate, bundleDate)
    }
    
    private func cacheModificationDate(forName name: Infrastructure.Name) -> Date? {
        let url = cacheURL(forName: name)
        return FileManager.default.modificationDate(of: url.path)
    }

    private func bundleModificationDate(forName name: Infrastructure.Name) -> Date? {
        guard let url = name.bundleURL else {
            return nil
        }
        return FileManager.default.modificationDate(of: url.path)
    }
}

extension Infrastructure {
    public var metadata: Metadata? {
        return InfrastructureFactory.shared.metadata(forName: name)
    }
}

private extension Infrastructure.Name {
    var bundleURL: URL? {
        return WebServices.Endpoint.providerNetwork(self).bundleURL(in: Bundle(for: InfrastructureFactory.self))
    }
}

extension ConnectionService {
    public func availableProviders() -> [Infrastructure.Metadata] {
        let names = Set(ids(forContext: .provider))
        return InfrastructureFactory.shared.cachedMetadata.filter { !names.contains($0.name) }
    }

    public func hasAvailableProviders() -> Bool {
        var allNames = Set(InfrastructureFactory.shared.cachedMetadata.map { $0.name })
        allNames.subtract(ids(forContext: .provider))
        return !allNames.isEmpty
    }
}
