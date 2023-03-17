//
//  CDInfrastructure+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension CDInfrastructure {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDInfrastructure> {
        return NSFetchRequest<CDInfrastructure>(entityName: "CDInfrastructure")
    }

    @NSManaged public var lastUpdate: Date?
    @NSManaged public var vpnProtocol: String?
    @NSManaged public var categories: NSSet?
    @NSManaged public var defaults: CDInfrastructureDefaultSettings?
    @NSManaged public var provider: CDProvider?

}

// MARK: Generated accessors for categories
extension CDInfrastructure {

    @objc(addCategoriesObject:)
    @NSManaged public func addToCategories(_ value: CDInfrastructureCategory)

    @objc(removeCategoriesObject:)
    @NSManaged public func removeFromCategories(_ value: CDInfrastructureCategory)

    @objc(addCategories:)
    @NSManaged public func addToCategories(_ values: NSSet)

    @objc(removeCategories:)
    @NSManaged public func removeFromCategories(_ values: NSSet)

}

extension CDInfrastructure: Identifiable {

}
