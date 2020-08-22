//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import CoreData

/**
 Abstracts the producer of a background context into a protocol
 to allow framework consumers to provide any source of a context
 */
public protocol MakesBackgroundManagedObjectContext {

    func newBackgroundContext() -> NSManagedObjectContext
}

extension NSPersistentContainer: MakesBackgroundManagedObjectContext { }

extension NSManagedObjectContext: MakesBackgroundManagedObjectContext {

    public func newBackgroundContext() -> NSManagedObjectContext {

        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = self
        moc.undoManager = nil
        return moc
    }
}

extension NSPersistentStoreCoordinator: MakesBackgroundManagedObjectContext {

    public func newBackgroundContext() -> NSManagedObjectContext {

        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = self
        return moc
    }
}


