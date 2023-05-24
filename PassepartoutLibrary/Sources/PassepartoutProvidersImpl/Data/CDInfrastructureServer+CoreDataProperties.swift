//
//  CDInfrastructureServer+CoreDataProperties.swift
//  
//
//  Created by Davide De Rosa on 27/03/22.
//
//  This file was automatically generated and should not be edited.
//

import CoreData
import Foundation

extension CDInfrastructureServer {

    @nonobjc class func fetchRequest() -> NSFetchRequest<CDInfrastructureServer> {
        return NSFetchRequest<CDInfrastructureServer>(entityName: "CDInfrastructureServer")
    }

    @NSManaged var area: String?
    @NSManaged var countryCode: String?
    @NSManaged var extraCountryCodes: String?
    @NSManaged var hostname: String?
    @NSManaged var ipAddresses: String?
    @NSManaged var apiId: String?
    @NSManaged var serverIndex: Int16
    @NSManaged var tags: String?
    @NSManaged var uniqueId: String?
    @NSManaged var category: CDInfrastructureCategory?
    @NSManaged var location: CDInfrastructureLocation?

}

extension CDInfrastructureServer: Identifiable {

}
