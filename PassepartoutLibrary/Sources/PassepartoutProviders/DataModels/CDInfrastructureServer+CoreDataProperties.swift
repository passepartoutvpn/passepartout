//
//  CDInfrastructureServer+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension CDInfrastructureServer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDInfrastructureServer> {
        return NSFetchRequest<CDInfrastructureServer>(entityName: "CDInfrastructureServer")
    }

    @NSManaged public var area: String?
    @NSManaged public var countryCode: String?
    @NSManaged public var extraCountryCodes: String?
    @NSManaged public var hostname: String?
    @NSManaged public var ipAddresses: String?
    @NSManaged public var apiId: String?
    @NSManaged public var serverIndex: Int16
    @NSManaged public var tags: String?
    @NSManaged public var uniqueId: String?
    @NSManaged public var category: CDInfrastructureCategory?
    @NSManaged public var location: CDInfrastructureLocation?

}

extension CDInfrastructureServer: Identifiable {

}
