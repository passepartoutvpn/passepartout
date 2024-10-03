import CoreData
import Foundation

@objc(CDProfile)
final class CDProfile: NSManagedObject {
    @nonobjc static func fetchRequest() -> NSFetchRequest<CDProfile> {
        return NSFetchRequest<CDProfile>(entityName: "CDProfile")
    }

    @NSManaged var json: Data?
    @NSManaged var encryptedJSON: Data?
    @NSManaged var name: String?
    @NSManaged var providerName: String?
    @NSManaged var uuid: UUID?
    @NSManaged var lastUpdate: Date?
}
