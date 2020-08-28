//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

// MARK: - EventConcurrencyTrackingProcedure

public protocol EventConcurrencyTrackingProcedureProtocol {
    var concurrencyRegistrar: EventConcurrencyTrackingRegistrar { get }
}

// Tracks the concurrent execution of various user code
// (observers, `execute()` and other function overrides, etc.)
// automatically handles events triggered from within other events
// (as long as everything happens on the same thread)
open class EventConcurrencyTrackingProcedure: Procedure, EventConcurrencyTrackingProcedureProtocol {
    public private(set) var concurrencyRegistrar: EventConcurrencyTrackingRegistrar
    private let delay: TimeInterval
    private let executeBlock: (EventConcurrencyTrackingProcedure) -> Void
    public init(name: String = "EventConcurrencyTrackingProcedure", withDelay delay: TimeInterval = 0, registrar: EventConcurrencyTrackingRegistrar = EventConcurrencyTrackingRegistrar(), baseObserver: ConcurrencyTrackingObserver? = ConcurrencyTrackingObserver(), execute: @escaping (EventConcurrencyTrackingProcedure) -> Void) {
        self.concurrencyRegistrar = registrar
        self.delay = delay
        self.executeBlock = execute
        super.init()
        self.name = name
        if let baseObserver = baseObserver {
            addObserver(baseObserver)
        }
    }
    open override func execute() {
        concurrencyRegistrar.doRun(.do_Execute, withDelay: delay, block: { _ in
            executeBlock(self)
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
}
