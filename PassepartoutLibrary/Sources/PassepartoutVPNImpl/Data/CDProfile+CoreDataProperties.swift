//
//  CDProfile+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import CoreData
import Foundation

extension CDProfile {

    @nonobjc class func fetchRequest() -> NSFetchRequest<CDProfile> {
        return NSFetchRequest<CDProfile>(entityName: "CDProfile")
    }

    @NSManaged var json: Data?
    @NSManaged var encryptedJSON: Data?
    @NSManaged var name: String?
    @NSManaged var providerName: String?
    @NSManaged var uuid: UUID?
    @NSManaged var lastUpdate: Date?

}

extension CDProfile: Identifiable {

}
