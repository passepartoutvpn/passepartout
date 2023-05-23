//
//  CDInfrastructure+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import CoreData
import Foundation

extension CDInfrastructure {

    @nonobjc class func fetchRequest() -> NSFetchRequest<CDInfrastructure> {
        return NSFetchRequest<CDInfrastructure>(entityName: "CDInfrastructure")
    }

    @NSManaged var lastUpdate: Date?
    @NSManaged var vpnProtocol: String?
    @NSManaged var categories: NSSet?
    @NSManaged var defaults: CDInfrastructureDefaultSettings?
    @NSManaged var provider: CDProvider?

}

// MARK: Generated accessors for categories
extension CDInfrastructure {

    @objc(addCategoriesObject:)
    @NSManaged func addToCategories(_ value: CDInfrastructureCategory)

    @objc(removeCategoriesObject:)
    @NSManaged func removeFromCategories(_ value: CDInfrastructureCategory)

    @objc(addCategories:)
    @NSManaged func addToCategories(_ values: NSSet)

    @objc(removeCategories:)
    @NSManaged func removeFromCategories(_ values: NSSet)

}

extension CDInfrastructure: Identifiable {

}
