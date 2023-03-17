//
//  CDInfrastructurePreset+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension CDInfrastructurePreset {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDInfrastructurePreset> {
        return NSFetchRequest<CDInfrastructurePreset>(entityName: "CDInfrastructurePreset")
    }

    @NSManaged public var comment: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var vpnConfiguration: Data?
    @NSManaged public var vpnProtocol: String?
    @NSManaged public var category: NSSet?

}

// MARK: Generated accessors for category
extension CDInfrastructurePreset {

    @objc(addCategoryObject:)
    @NSManaged public func addToCategory(_ value: CDInfrastructureCategory)

    @objc(removeCategoryObject:)
    @NSManaged public func removeFromCategory(_ value: CDInfrastructureCategory)

    @objc(addCategory:)
    @NSManaged public func addToCategory(_ values: NSSet)

    @objc(removeCategory:)
    @NSManaged public func removeFromCategory(_ values: NSSet)

}

extension CDInfrastructurePreset: Identifiable {

}
