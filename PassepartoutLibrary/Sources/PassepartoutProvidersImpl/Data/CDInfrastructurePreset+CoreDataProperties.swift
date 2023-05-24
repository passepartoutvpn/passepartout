//
//  CDInfrastructurePreset+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import CoreData
import Foundation

extension CDInfrastructurePreset {

    @nonobjc class func fetchRequest() -> NSFetchRequest<CDInfrastructurePreset> {
        return NSFetchRequest<CDInfrastructurePreset>(entityName: "CDInfrastructurePreset")
    }

    @NSManaged var comment: String?
    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var vpnConfiguration: Data?
    @NSManaged var vpnProtocol: String?
    @NSManaged var category: NSSet?

}

// MARK: Generated accessors for category
extension CDInfrastructurePreset {

    @objc(addCategoryObject:)
    @NSManaged func addToCategory(_ value: CDInfrastructureCategory)

    @objc(removeCategoryObject:)
    @NSManaged func removeFromCategory(_ value: CDInfrastructureCategory)

    @objc(addCategory:)
    @NSManaged func addToCategory(_ values: NSSet)

    @objc(removeCategory:)
    @NSManaged func removeFromCategory(_ values: NSSet)

}

extension CDInfrastructurePreset: Identifiable {

}
