//
//  CDProvider+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import CoreData
import Foundation

extension CDProvider {

    @nonobjc class func fetchRequest() -> NSFetchRequest<CDProvider> {
        return NSFetchRequest<CDProvider>(entityName: "CDProvider")
    }

    @NSManaged var fullName: String?
    @NSManaged var name: String?
    @NSManaged var infrastructures: NSSet?
    @NSManaged var lastUpdate: Date?

}

// MARK: Generated accessors for infrastructures
extension CDProvider {

    @objc(addInfrastructuresObject:)
    @NSManaged func addToInfrastructures(_ value: CDInfrastructure)

    @objc(removeInfrastructuresObject:)
    @NSManaged func removeFromInfrastructures(_ value: CDInfrastructure)

    @objc(addInfrastructures:)
    @NSManaged func addToInfrastructures(_ values: NSSet)

    @objc(removeInfrastructures:)
    @NSManaged func removeFromInfrastructures(_ values: NSSet)

}

extension CDProvider: Identifiable {

}
