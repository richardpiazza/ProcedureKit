//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKitTesting
@testable import ProcedureKit
import Dispatch

class BlockObserverTests: ProcedureKitTestCase {

    static var allTests = [
        ("test__did_attach_is_called", test__did_attach_is_called),
        ("test__will_execute_is_called", test__will_execute_is_called),
        ("test__did_execute_is_called", test__did_execute_is_called),
        ("test__did_cancel_is_called", test__did_cancel_is_called),
        ("test__will_add_operation_is_called", test__will_add_operation_is_called),
        ("test__did_add_operation_is_called", test__did_add_operation_is_called),
        ("test__will_finish_is_called", test__will_finish_is_called),
        ("test__did_finish_is_called", test__did_finish_is_called),
    ]
    
    func test__did_attach_is_called() {
        let didAttachCalled = Protector<Procedure?>(nil)
        procedure.addObserver(BlockObserver(didAttach: { didAttachCalled.overwrite(with: $0) }))
        wait(for: procedure)
        XCTAssertEqual(didAttachCalled.access, procedure)
    }

    func test__will_execute_is_called() {
        let willExecuteCalled = Protector<Procedure?>(nil)
        procedure.addObserver(BlockObserver(willExecute: { procedure, _ in
            willExecuteCalled.overwrite(with: procedure)
        }))
        wait(for: procedure)
        XCTAssertEqual(willExecuteCalled.access, procedure)
    }

    func test__did_execute_is_called() {
        let didExecuteCalled = Protector<Procedure?>(nil)
        procedure.addObserver(BlockObserver(didExecute: { didExecuteCalled.overwrite(with: $0) }))
        wait(for: procedure)
        XCTAssertEqual(didExecuteCalled.access, procedure)
    }

    func test__did_cancel_is_called() {
        let didCancelCalled = Protector<(Procedure, Error?)?>(nil)
        let error = TestError()
        let cancelWaitGroup = DispatchGroup()
        cancelWaitGroup.enter()
        let procedure = BlockProcedure { this in
            // Wait for the Procedure to be cancelled by the test
            // (and for all didCancel observers to be triggered)
            // to avoid a race condition in which the Procedure finishes
            // before the check block below can cancel it and/or the DidCancel
            // observers can be called.
            cancelWaitGroup.notify(queue: DispatchQueue.global()) {
                this.finish()
            }
        }
        procedure.addObserver(BlockObserver(didCancel: {
            didCancelCalled.overwrite(with: ($0, $1))
            cancelWaitGroup.leave()
        }))
        check(procedure: procedure) { procedure in
            procedure.cancel(with: error)
        }
        XCTAssertEqual(didCancelCalled.access?.0, procedure)
        XCTAssertEqual(didCancelCalled.access?.1 as? TestError, error)
    }

    func test__will_add_operation_is_called() {
        let willAddCalled = Protector<(Procedure, Operation)?>(nil)
        var didExecuteProducedOperation = false
        let producingProcedure = TestProcedure(produced: BlockOperation { didExecuteProducedOperation = true })
        producingProcedure.addObserver(BlockObserver(willAdd: { willAddCalled.overwrite(with: ($0, $1)) }))
        wait(for: producingProcedure)
        XCTAssertTrue(didExecuteProducedOperation)
        XCTAssertEqual(willAddCalled.access?.0, producingProcedure)
        XCTAssertNotNil(willAddCalled.access?.1)
    }

    func test__did_add_operation_is_called() {
        let didAddCalled = Protector<(Procedure, Operation)?>(nil)
        var didExecuteProducedOperation = false
        let producingProcedure = TestProcedure(produced: BlockOperation { didExecuteProducedOperation = true })
        producingProcedure.addObserver(BlockObserver(didAdd: { didAddCalled.overwrite(with: ($0, $1)) }))
        wait(for: producingProcedure)
        XCTAssertTrue(didExecuteProducedOperation)
        XCTAssertEqual(didAddCalled.access?.0, producingProcedure)
        XCTAssertNotNil(didAddCalled.access?.1)
    }

    func test__will_finish_is_called() {
        let willFinishCalled = Protector<(Procedure, Error?)?>(nil)
        procedure.addObserver(BlockObserver(willFinish: { procedure, error, _ in
            willFinishCalled.overwrite(with: (procedure, error))
        }))
        wait(for: procedure)
        XCTAssertEqual(willFinishCalled.access?.0, procedure)
    }

    func test__did_finish_is_called() {
        let didFinishCalled = Protector<(Procedure, Error?)?>(nil)
        procedure.addObserver(BlockObserver(didFinish: { didFinishCalled.overwrite(with: ($0, $1)) }))
        wait(for: procedure)
        XCTAssertEqual(didFinishCalled.access?.0, procedure)
    }
}
