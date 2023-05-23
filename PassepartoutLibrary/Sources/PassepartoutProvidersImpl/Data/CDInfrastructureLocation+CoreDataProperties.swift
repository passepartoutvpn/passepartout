//
//  CDInfrastructureLocation+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import CoreData
import Foundation

extension CDInfrastructureLocation {

    @nonobjc class func fetchRequest() -> NSFetchRequest<CDInfrastructureLocation> {
        return NSFetchRequest<CDInfrastructureLocation>(entityName: "CDInfrastructureLocation")
    }

    @NSManaged var countryCode: String?
    @NSManaged var category: CDInfrastructureCategory?
    @NSManaged var servers: NSSet?

}

// MARK: Generated accessors for servers
extension CDInfrastructureLocation {

    @objc(addServersObject:)
    @NSManaged func addToServers(_ value: CDInfrastructureServer)

    @objc(removeServersObject:)
    @NSManaged func removeFromServers(_ value: CDInfrastructureServer)

    @objc(addServers:)
    @NSManaged func addToServers(_ values: NSSet)

    @objc(removeServers:)
    @NSManaged func removeFromServers(_ values: NSSet)

}

extension CDInfrastructureLocation: Identifiable {

}
