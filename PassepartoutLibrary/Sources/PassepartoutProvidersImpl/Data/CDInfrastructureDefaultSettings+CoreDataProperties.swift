//
//  CDInfrastructureDefaultSettings+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import CoreData
import Foundation

extension CDInfrastructureDefaultSettings {

    @nonobjc class func fetchRequest() -> NSFetchRequest<CDInfrastructureDefaultSettings> {
        return NSFetchRequest<CDInfrastructureDefaultSettings>(entityName: "CDInfrastructureDefaultSettings")
    }

    @NSManaged var countryCode: String?
    @NSManaged var usernamePlaceholder: String?
    @NSManaged var infrastructure: CDInfrastructure?

}

extension CDInfrastructureDefaultSettings: Identifiable {

}
