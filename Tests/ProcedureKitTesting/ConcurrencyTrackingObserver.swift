//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

// MARK: - ConcurrencyTrackingObserver

open class ConcurrencyTrackingObserver: ProcedureObserver {

    private var registrar: EventConcurrencyTrackingRegistrar!
    public let eventQueue: DispatchQueueProtocol?
    let callbackBlock: (Procedure, EventConcurrencyTrackingRegistrar.ProcedureEvent) -> Void

    public init(registrar: EventConcurrencyTrackingRegistrar? = nil, eventQueue: DispatchQueueProtocol? = nil, callbackBlock: @escaping (Procedure, EventConcurrencyTrackingRegistrar.ProcedureEvent) -> Void = { _, _ in }) {
        if let registrar = registrar {
            self.registrar = registrar
        }
        self.eventQueue = eventQueue
        self.callbackBlock = callbackBlock
    }

    public func didAttach(to procedure: Procedure) {
        if let eventTrackingProcedure = procedure as? EventConcurrencyTrackingProcedureProtocol {
            if registrar == nil {
                registrar = eventTrackingProcedure.concurrencyRegistrar
            }
            doRun(.observer_didAttach, block: { callback in callbackBlock(procedure, callback) })
        }
    }

    public func will(execute procedure: Procedure, pendingExecute: PendingExecuteEvent) {
        doRun(.observer_willExecute, block: { callback in callbackBlock(procedure, callback) })
    }

    public func did(execute procedure: Procedure) {
        doRun(.observer_didExecute, block: { callback in callbackBlock(procedure, callback) })
    }

    public func will(cancel procedure: Procedure, with: Error?) {
        doRun(.observer_willCancel, block: { callback in callbackBlock(procedure, callback) })
    }

    public func did(cancel procedure: Procedure, with: Error?) {
        doRun(.observer_didCancel, block: { callback in callbackBlock(procedure, callback) })
    }

    public func procedure(_ procedure: Procedure, willAdd newOperation: Operation) {
        doRun(.observer_procedureWillAdd(newOperation.operationName), block: { callback in callbackBlock(procedure, callback) })
    }

    public func procedure(_ procedure: Procedure, didAdd newOperation: Operation) {
        doRun(.observer_procedureDidAdd(newOperation.operationName), block: { callback in callbackBlock(procedure, callback) })
    }

    public func will(finish procedure: Procedure, with error: Error?, pendingFinish: PendingFinishEvent) {
        doRun(.observer_willFinish, block: { callback in callbackBlock(procedure, callback) })
    }

    public func did(finish procedure: Procedure, with error: Error?) {
        doRun(.observer_didFinish, block: { callback in callbackBlock(procedure, callback) })
    }

    public func doRun(_ callback: EventConcurrencyTrackingRegistrar.ProcedureEvent, withDelay delay: TimeInterval = 0.0001, block: (EventConcurrencyTrackingRegistrar.ProcedureEvent) -> Void = { _ in }) {
        registrar.doRun(callback, withDelay: delay, block: block)
    }
}
