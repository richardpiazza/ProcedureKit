//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKitTesting
@testable import ProcedureKit

class BlockConditionTests: ProcedureKitTestCase {

    static var allTests = [
        ("test__procedure_with_successful_block_finishes", test__procedure_with_successful_block_finishes),
        ("test__procedure_with_unsuccessful_block_cancels_without_errors", test__procedure_with_unsuccessful_block_cancels_without_errors),
        ("test__procedure_with_throwing_block_cancels_with_error", test__procedure_with_throwing_block_cancels_with_error),
    ]
    
    func test__procedure_with_successful_block_finishes() {
        procedure.addCondition(BlockCondition { true })
        wait(for: procedure)
        PKAssertProcedureFinished(procedure)
    }

    func test__procedure_with_unsuccessful_block_cancels_without_errors() {
        procedure.addCondition(BlockCondition { false })
        wait(for: procedure)
        PKAssertProcedureCancelled(procedure)
    }

    func test__procedure_with_throwing_block_cancels_with_error() {
        let error = TestError()
        procedure.addCondition(BlockCondition { throw error })
        wait(for: procedure)
        PKAssertProcedureCancelledWithError(procedure, ProcedureKitError.conditionFailed(with: error))
    }
}

