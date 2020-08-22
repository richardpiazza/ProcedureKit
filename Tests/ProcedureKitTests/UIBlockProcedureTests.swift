//
//  ProcedureKit
//
//  Copyright © 2015-2020 ProcedureKit. All rights reserved.
//

import XCTest
import TestingProcedureKit
@testable import ProcedureKit

class UIBlockProcedureTests: ProcedureKitTestCase {

    static var allTests = [
        ("test__block_executes", test__block_executes),
        ("test__block_executes_on_main_queue", test__block_executes_on_main_queue),
        ("test__willFinishObserversCalled", test__willFinishObserversCalled),
    ]
    
    func test__block_executes() {
        var blockDidExecute = false
        let block = UIBlockProcedure {
            blockDidExecute = true
        }
        wait(for: block)
        XCTAssertTrue(blockDidExecute)
        PKAssertProcedureFinished(block)
    }

    func test__block_executes_on_main_queue() {
        var blockDidExecuteOnMainQueue = false
        let block = UIBlockProcedure {
            blockDidExecuteOnMainQueue = DispatchQueue.isMainDispatchQueue
        }
        wait(for: block)
        XCTAssertTrue(blockDidExecuteOnMainQueue)
        PKAssertProcedureFinished(block)
    }

    func test__willFinishObserversCalled() {
        var blockDidExecute = false
        var observerDidExecute = false
        let block = UIBlockProcedure {
            blockDidExecute = true
        }
        block.addWillFinishBlockObserver { (_, _, pendingFinish) in
            pendingFinish.doBeforeEvent {
                observerDidExecute = true
            }
        }
        var dependencyDidExecute = false
        let dep = BlockProcedure {
            dependencyDidExecute = true
        }
        block.addDependency(dep)
        wait(for: block, dep)
        XCTAssertTrue(blockDidExecute)
        XCTAssertTrue(observerDidExecute)
        XCTAssertTrue(dependencyDidExecute)
        PKAssertProcedureFinished(block)
        PKAssertProcedureFinished(dep)
    }
}
