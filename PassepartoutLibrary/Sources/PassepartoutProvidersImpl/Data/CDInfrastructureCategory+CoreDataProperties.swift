//
//  CDInfrastructureCategory+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import CoreData
import Foundation

extension CDInfrastructureCategory {

    @nonobjc class func fetchRequest() -> NSFetchRequest<CDInfrastructureCategory> {
        return NSFetchRequest<CDInfrastructureCategory>(entityName: "CDInfrastructureCategory")
    }

    @NSManaged var name: String?
    @NSManaged var infrastructure: CDInfrastructure?
    @NSManaged var locations: NSSet?
    @NSManaged var presets: NSSet?
    @NSManaged var servers: NSSet?

}

// MARK: Generated accessors for locations
extension CDInfrastructureCategory {

    @objc(addLocationsObject:)
    @NSManaged func addToLocations(_ value: CDInfrastructureLocation)

    @objc(removeLocationsObject:)
    @NSManaged func removeFromLocations(_ value: CDInfrastructureLocation)

    @objc(addLocations:)
    @NSManaged func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged func removeFromLocations(_ values: NSSet)

}

// MARK: Generated accessors for presets
extension CDInfrastructureCategory {

    @objc(addPresetsObject:)
    @NSManaged func addToPresets(_ value: CDInfrastructurePreset)

    @objc(removePresetsObject:)
    @NSManaged func removeFromPresets(_ value: CDInfrastructurePreset)

    @objc(addPresets:)
    @NSManaged func addToPresets(_ values: NSSet)

    @objc(removePresets:)
    @NSManaged func removeFromPresets(_ values: NSSet)

}

// MARK: Generated accessors for servers
extension CDInfrastructureCategory {

    @objc(addServersObject:)
    @NSManaged func addToServers(_ value: CDInfrastructureServer)

    @objc(removeServersObject:)
    @NSManaged func removeFromServers(_ value: CDInfrastructureServer)

    @objc(addServers:)
    @NSManaged func addToServers(_ values: NSSet)

    @objc(removeServers:)
    @NSManaged func removeFromServers(_ values: NSSet)

}

extension CDInfrastructureCategory: Identifiable {

}
