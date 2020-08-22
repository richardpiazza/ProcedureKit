//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
#if canImport(CoreData)
import CoreData

/**
 Makes a FetchResultsController, using the viewContext from a NSPersistentContainer
 which is injected before execution, but after initialization. For example:

 ```swift
 let coreDataStack = LoadCoreDataProcedure(name: "CoreDataEntities")
 let makeFRC = MakeFetchedResultControllerProcedure(for: "MyEntity")
     .injectResult(from: coreDataStack)
 ```
 */
open class MakeFetchedResultControllerProcedure<Result: NSFetchRequestResult>: TransformProcedure<NSPersistentContainer, NSFetchedResultsController<Result>> {

    static func transform(fetchRequest: NSFetchRequest<Result>, sectionNameKeyPath: String? = nil, cacheName: String? = nil) -> (NSPersistentContainer) throws -> NSFetchedResultsController<Result> {
        return { (container) in

            let frc = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: container.viewContext,
                sectionNameKeyPath: sectionNameKeyPath,
                cacheName: cacheName)

            try container.viewContext.performAndWait(block: frc.performFetch)

            return frc
        }
    }

    /// Initializes the FetchedResultsController with a NSFetchRequest
    public init(fetchRequest: NSFetchRequest<Result>, sectionNameKeyPath: String? = nil, cacheName: String? = nil) {
        super.init(transform: MakeFetchedResultControllerProcedure<Result>.transform(fetchRequest: fetchRequest, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName))
        name = "Make FRC \(fetchRequest.entityName ?? "")".trimmingCharacters(in: .whitespaces)
    }

    /// Convenience initalizer using just the entity name, fetch limit (default is 50) and sort descriptors (default is empty).
    public init(for entityName: String, fetchLimit: Int = 50, sortDescriptors: [NSSortDescriptor] = [], sectionNameKeyPath: String? = nil, cacheName: String? = nil) {

        let fetchRequest: NSFetchRequest<Result> = NSFetchRequest(entityName: entityName)
        fetchRequest.fetchLimit = fetchLimit
        fetchRequest.sortDescriptors = sortDescriptors

        super.init(transform: MakeFetchedResultControllerProcedure<Result>.transform(fetchRequest: fetchRequest, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName))
        name = "Make FRC \(fetchRequest.entityName ?? "")".trimmingCharacters(in: .whitespaces)
    }
}

public extension MakeFetchedResultControllerProcedure where Result: NSManagedObject {

    convenience init(fetchLimit: Int = 50, sortDescriptors: [NSSortDescriptor] = [], sectionNameKeyPath: String? = nil, cacheName: String? = nil) {
        self.init(for: Result.entityName, fetchLimit: fetchLimit, sortDescriptors: sortDescriptors, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
    }
}

#endif
