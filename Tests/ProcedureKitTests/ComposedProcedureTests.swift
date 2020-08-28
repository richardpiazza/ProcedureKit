//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKitTesting
@testable import ProcedureKit

public class ComposedProcedureTests: ProcedureKitTestCase {

    static var allTests = [
        ("test__composed_procedure_is_cancelled", test__composed_procedure_is_cancelled),
        ("test__composed_operation_is_executed", test__composed_operation_is_executed),
        ("test__composed_procedure_is_executed", test__composed_procedure_is_executed),
    ]
    
    func test__composed_procedure_is_cancelled() {
        let didCancelCalled = DispatchSemaphore(value: 0)
        procedure.addDidCancelBlockObserver { _, _ in
            didCancelCalled.signal()
        }
        let composed = ComposedProcedure(procedure)
        composed.cancel()
        XCTAssertTrue(composed.isCancelled)

        XCTAssertEqual(didCancelCalled.wait(timeout: .now() + 1.0), DispatchTimeoutResult.success)

        XCTAssertTrue(composed.operation.isCancelled)
        XCTAssertTrue(procedure.isCancelled)
    }

    func test__composed_operation_is_executed() {
        var didExecute = false
        let composed = ComposedProcedure(BlockOperation { didExecute = true })
        wait(for: composed)
        PKAssertProcedureFinished(composed)
        XCTAssertTrue(didExecute)
    }

    func test__composed_procedure_is_executed() {
        let composed = ComposedProcedure(procedure)
        wait(for: composed)
        PKAssertProcedureFinished(procedure)
    }
}
