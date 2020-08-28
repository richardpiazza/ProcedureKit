//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKitTesting
@testable import ProcedureKit

class BlockProcedureTests: ProcedureKitTestCase {

    static var allTests = [
        ("test__void_block_procedure", test__void_block_procedure),
        ("test__self_block_procedure", test__self_block_procedure),
        ("test__block_does_not_execute_if_cancelled", test__block_does_not_execute_if_cancelled),
        ("test__block_which_throws_finishes_with_error", test__block_which_throws_finishes_with_error),
        ("test__block_did_execute_observer", test__block_did_execute_observer),
    ]
    
    func test__void_block_procedure() {
        var blockDidExecute = false
        let block = BlockProcedure { blockDidExecute = true }
        wait(for: block)
        XCTAssertTrue(blockDidExecute)
        PKAssertProcedureFinished(block)
    }

    func test__self_block_procedure() {
        var blockDidExecute = false
        let block = BlockProcedure { (procedure) in
            blockDidExecute = true
            procedure.log.debug.message("Hello world")
            procedure.finish()
        }
        wait(for: block)
        XCTAssertTrue(blockDidExecute)
        PKAssertProcedureFinished(block)
    }

    func test__block_does_not_execute_if_cancelled() {
        var blockDidExecute = false
        let block = BlockProcedure { blockDidExecute = true }
        block.cancel()
        wait(for: block)
        XCTAssertFalse(blockDidExecute)
        PKAssertProcedureCancelled(block)
    }

    func test__block_which_throws_finishes_with_error() {
        let error = TestError()
        let block = BlockProcedure { throw error }
        wait(for: block)
        PKAssertProcedureFinishedWithError(block, error)
    }

    func test__block_did_execute_observer() {
        let block = BlockProcedure { /* does nothing */ }
        var didExecuteBlockObserver = false
        block.addDidExecuteBlockObserver { procedure in
            didExecuteBlockObserver = true
        }
        wait(for: block)
        XCTAssertTrue(didExecuteBlockObserver)
        PKAssertProcedureFinished(block)
    }
}
