//
//  CDInfrastructureDefaultSettings+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension CDInfrastructureDefaultSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDInfrastructureDefaultSettings> {
        return NSFetchRequest<CDInfrastructureDefaultSettings>(entityName: "CDInfrastructureDefaultSettings")
    }

    @NSManaged public var countryCode: String?
    @NSManaged public var usernamePlaceholder: String?
    @NSManaged public var infrastructure: CDInfrastructure?

}

extension CDInfrastructureDefaultSettings: Identifiable {

}
