//
//  CDProfile+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension CDProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDProfile> {
        return NSFetchRequest<CDProfile>(entityName: "CDProfile")
    }

    @NSManaged public var json: Data?
    @NSManaged public var name: String?
    @NSManaged public var providerName: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var lastUpdate: Date?

}

extension CDProfile: Identifiable {

}
