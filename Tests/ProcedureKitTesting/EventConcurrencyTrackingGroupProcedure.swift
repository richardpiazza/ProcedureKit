//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

open class EventConcurrencyTrackingGroupProcedure: GroupProcedure, EventConcurrencyTrackingProcedureProtocol {
    public private(set) var concurrencyRegistrar: EventConcurrencyTrackingRegistrar
    private let delay: TimeInterval
    public init(dispatchQueue underlyingQueue: DispatchQueue? = nil, operations: [Operation], name: String = "EventConcurrencyTrackingGroupProcedure", withDelay delay: TimeInterval = 0, registrar: EventConcurrencyTrackingRegistrar = EventConcurrencyTrackingRegistrar(), baseObserver: ConcurrencyTrackingObserver? = ConcurrencyTrackingObserver()) {
        self.concurrencyRegistrar = registrar
        self.delay = delay
        super.init(dispatchQueue: underlyingQueue, operations: operations)
        self.name = name
        if let baseObserver = baseObserver {
            addObserver(baseObserver)
        }
        // GroupProcedure transformChildErrorsBlock
        transformChildErrorBlock = { [concurrencyRegistrar] (child, _) in
            concurrencyRegistrar.doRun(.group_transformChildErrorsBlock(child.operationName))
        }
    }
    open override func execute() {
        concurrencyRegistrar.doRun(.do_Execute, withDelay: delay, block: { _ in
            super.execute()
        })
    }
    // Cancellation Handler Overrides
    open override func procedureDidCancel(with error: Error?) {
        concurrencyRegistrar.doRun(.override_procedureDidCancel)
        super.procedureDidCancel(with: error)
    }
    // Finish Handler Overrides
    open override func procedureWillFinish(with error: Error?) {
        concurrencyRegistrar.doRun(.override_procedureWillFinish)
        super.procedureWillFinish(with: error)
    }
    open override func procedureDidFinish(with error: Error?) {
        concurrencyRegistrar.doRun(.override_procedureDidFinish)
        super.procedureDidFinish(with: error)
    }

    // GroupProcedure Overrides
    open override func groupWillAdd(child: Operation) {
        concurrencyRegistrar.doRun(.override_groupWillAdd_child(child.operationName))
        super.groupWillAdd(child: child)
    }
    open override func child(_ child: Procedure, willFinishWithError error: Error?) {
        concurrencyRegistrar.doRun(.override_child_willFinishWithErrors(child.operationName))
        return super.child(child, willFinishWithError: error)
    }
}
