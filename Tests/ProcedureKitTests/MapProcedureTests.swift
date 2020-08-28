//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKitTesting
@testable import ProcedureKit

class MapProcedureTests: ProcedureKitTestCase {

    static var allTests = [
        ("test__requirement_is_mapped_to_result", test__requirement_is_mapped_to_result),
        ("test__finishes_with_error_if_block_throws", test__finishes_with_error_if_block_throws),
        ("test__map_dependency_which_finishes_without_errors", test__map_dependency_which_finishes_without_errors),
        ("test__map_dependency_which_finishes_with_errors", test__map_dependency_which_finishes_with_errors),
    ]
    
    func test__requirement_is_mapped_to_result() {
        let functional = MapProcedure(source: [0,1,2,3,4,5,6,7]) { $0 * 2 }
        wait(for: functional)
        PKAssertProcedureFinished(functional)
        PKAssertProcedureOutput(functional, [0,2,4,6,8,10,12,14])
    }

    func test__finishes_with_error_if_block_throws() {
        let error = TestError()
        let functional = MapProcedure(source: [0,1,2,3,4,5,6,7]) { _ in throw error }
        wait(for: functional)
        PKAssertProcedureFinishedWithError(functional, error)
    }

    func test__map_dependency_which_finishes_without_errors() {
        let numbers = NumbersProcedure()
        let functional = numbers.map { $0 * 2 }
        wait(for: numbers, functional)
        PKAssertProcedureFinished(numbers)
        PKAssertProcedureFinished(functional)
        PKAssertProcedureOutput(functional, [0,2,4,6,8,10,12,14,16,18])
    }

    func test__map_dependency_which_finishes_with_errors() {
        let error = TestError()
        let numbers = NumbersProcedure(error: error)
        let functional = numbers.map { $0 * 2 }
        wait(for: numbers, functional)
        PKAssertProcedureFinishedWithError(numbers, error)
        PKAssertProcedureCancelledWithError(functional, ProcedureKitError.dependency(finishedWithError: error))
    }

}
