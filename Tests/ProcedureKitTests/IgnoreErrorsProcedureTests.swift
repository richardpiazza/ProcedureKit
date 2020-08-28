//
//  ProcedureKit
//
//  Copyright © 2016 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKitTesting
@testable import ProcedureKit

class IgnoreErrorsProcedureTests: ProcedureKitTestCase {

    static var allTests = [
        ("test__procedure_which_errors_is_ignored", test__procedure_which_errors_is_ignored),
        ("test__procedure_which_does_not_error", test__procedure_which_does_not_error),
        ("test__procedure_output", test__procedure_output),
    ]
    
    func test__procedure_which_errors_is_ignored() {

        let procedure = IgnoreErrorsProcedure(ResultProcedure { throw ProcedureKitError.unknown })
        wait(for: procedure)
        PKAssertProcedureFinished(procedure)
    }

    func test__procedure_which_does_not_error() {

        let procedure = IgnoreErrorsProcedure(ResultProcedure { "Hello" })
        wait(for: procedure)
        PKAssertProcedureFinished(procedure)
    }

    func test__procedure_output() {

        let procedure = IgnoreErrorsProcedure(ResultProcedure { "Hello" })
        wait(for: procedure)
        PKAssertProcedureOutput(procedure, "Hello")
    }
}

