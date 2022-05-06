import Foundation
import CoreData
import UIKit

class CoreDataProvider {
    
    static func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext ?? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }
    
    static func saveContext(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}
