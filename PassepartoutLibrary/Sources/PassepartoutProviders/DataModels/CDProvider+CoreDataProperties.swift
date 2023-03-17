//
//  CDProvider+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension CDProvider {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDProvider> {
        return NSFetchRequest<CDProvider>(entityName: "CDProvider")
    }

    @NSManaged public var fullName: String?
    @NSManaged public var name: String?
    @NSManaged public var infrastructures: NSSet?
    @NSManaged public var lastUpdate: Date?

}

// MARK: Generated accessors for infrastructures
extension CDProvider {

    @objc(addInfrastructuresObject:)
    @NSManaged public func addToInfrastructures(_ value: CDInfrastructure)

    @objc(removeInfrastructuresObject:)
    @NSManaged public func removeFromInfrastructures(_ value: CDInfrastructure)

    @objc(addInfrastructures:)
    @NSManaged public func addToInfrastructures(_ values: NSSet)

    @objc(removeInfrastructures:)
    @NSManaged public func removeFromInfrastructures(_ values: NSSet)

}

extension CDProvider: Identifiable {

}
