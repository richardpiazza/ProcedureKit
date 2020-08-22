//
//  ProcedureKit
//
//  Copyright © 2015-2020 ProcedureKit. All rights reserved.
//

import XCTest
import TestingProcedureKit
@testable import ProcedureKit

class FinishingConcurrencyTests: ProcedureKitTestCase {

    static var allTests = [
        ("test__finish_on_other_thread_synchronously_from_execute", test__finish_on_other_thread_synchronously_from_execute),
    ]
    
    func test__finish_on_other_thread_synchronously_from_execute() {
        // This test should not result in deadlock.

        class TestFinishSyncFromExecuteProcedure: Procedure {
            override init() {
                super.init()
                self.name = "TestFinishSyncFromExecuteProcedure"
            }
            override func execute() {
                guard !Thread.current.isMainThread else { fatalError("Procedure's execute() is on main thread.") }
                DispatchQueue.main.sync {
                    assert(Thread.current.isMainThread)
                    finish()
                }
            }
        }

        let procedure = TestFinishSyncFromExecuteProcedure()
        wait(for: procedure, withTimeout: 3, handler: { (error) in
            XCTAssertNil(error)
        })
        XCTAssertTrue(procedure.isFinished)
    }
}
