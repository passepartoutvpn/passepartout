//
//  CDInfrastructureCategory+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension CDInfrastructureCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDInfrastructureCategory> {
        return NSFetchRequest<CDInfrastructureCategory>(entityName: "CDInfrastructureCategory")
    }

    @NSManaged public var name: String?
    @NSManaged public var infrastructure: CDInfrastructure?
    @NSManaged public var locations: NSSet?
    @NSManaged public var presets: NSSet?
    @NSManaged public var servers: NSSet?

}

// MARK: Generated accessors for locations
extension CDInfrastructureCategory {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: CDInfrastructureLocation)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: CDInfrastructureLocation)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}

// MARK: Generated accessors for presets
extension CDInfrastructureCategory {

    @objc(addPresetsObject:)
    @NSManaged public func addToPresets(_ value: CDInfrastructurePreset)

    @objc(removePresetsObject:)
    @NSManaged public func removeFromPresets(_ value: CDInfrastructurePreset)

    @objc(addPresets:)
    @NSManaged public func addToPresets(_ values: NSSet)

    @objc(removePresets:)
    @NSManaged public func removeFromPresets(_ values: NSSet)

}

// MARK: Generated accessors for servers
extension CDInfrastructureCategory {

    @objc(addServersObject:)
    @NSManaged public func addToServers(_ value: CDInfrastructureServer)

    @objc(removeServersObject:)
    @NSManaged public func removeFromServers(_ value: CDInfrastructureServer)

    @objc(addServers:)
    @NSManaged public func addToServers(_ values: NSSet)

    @objc(removeServers:)
    @NSManaged public func removeFromServers(_ values: NSSet)

}

extension CDInfrastructureCategory: Identifiable {

}
