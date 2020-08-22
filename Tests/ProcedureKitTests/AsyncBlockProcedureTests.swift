//
//  ProcedureKit
//
//  Copyright © 2015-2020 ProcedureKit. All rights reserved.
//

import XCTest
import TestingProcedureKit
@testable import ProcedureKit

class AsyncBlockProcedureTests: ProcedureKitTestCase {

    static var allTests = [
        ("test__block_executes", test__block_executes),
        ("test__block_does_not_execute_if_cancelled", test__block_does_not_execute_if_cancelled),
        ("test__block_which_finishes_with_error", test__block_which_finishes_with_error),
        ("test__block_did_execute_observer", test__block_did_execute_observer),
    ]
    
    var dispatchQueue: DispatchQueue!

    override func setUp() {
        super.setUp()
        dispatchQueue = DispatchQueue.initiated
    }

    override func tearDown() {
        dispatchQueue = nil
        super.tearDown()
    }

    func test__block_executes() {
        var blockDidExecute = false
        let block = BlockProcedure { this in
            self.dispatchQueue.async {
                blockDidExecute = true
                this.finish()
            }
        }
        wait(for: block)
        XCTAssertTrue(blockDidExecute)
        PKAssertProcedureFinished(block)
    }

    func test__block_does_not_execute_if_cancelled() {
        var blockDidExecute = false
        let block = BlockProcedure { this in
            self.dispatchQueue.async {
                blockDidExecute = true
                this.finish()
            }
        }
        block.cancel()
        wait(for: block)
        XCTAssertFalse(blockDidExecute)
        PKAssertProcedureCancelled(block)
    }

    func test__block_which_finishes_with_error() {
        let error = TestError()
        let block = BlockProcedure { this in
            self.dispatchQueue.async {
                this.finish(with: error)
            }
        }
        wait(for: block)
        PKAssertProcedureFinishedWithError(block, error)
    }

    func test__block_did_execute_observer() {
        let block = BlockProcedure { this in
            self.dispatchQueue.async {
                this.finish()
            }
        }
        var didExecuteBlockObserver = false
        block.addDidExecuteBlockObserver { procedure in
            didExecuteBlockObserver = true
        }
        wait(for: block)
        XCTAssertTrue(didExecuteBlockObserver)
        PKAssertProcedureFinished(block)
    }
}
