//
//  CDInfrastructureLocation+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension CDInfrastructureLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDInfrastructureLocation> {
        return NSFetchRequest<CDInfrastructureLocation>(entityName: "CDInfrastructureLocation")
    }

    @NSManaged public var countryCode: String?
    @NSManaged public var category: CDInfrastructureCategory?
    @NSManaged public var servers: NSSet?

}

// MARK: Generated accessors for servers
extension CDInfrastructureLocation {

    @objc(addServersObject:)
    @NSManaged public func addToServers(_ value: CDInfrastructureServer)

    @objc(removeServersObject:)
    @NSManaged public func removeFromServers(_ value: CDInfrastructureServer)

    @objc(addServers:)
    @NSManaged public func addToServers(_ values: NSSet)

    @objc(removeServers:)
    @NSManaged public func removeFromServers(_ values: NSSet)

}

extension CDInfrastructureLocation: Identifiable {

}
