//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKitTesting
@testable import ProcedureKit

class TransformProcedureTests: ProcedureKitTestCase {

    func test__requirement_is_transformed_to_result() {
        let timesTwo = TransformProcedure<Int, Int> { return $0 * 2 }
        timesTwo.input = .ready(2)
        wait(for: timesTwo)
        PKAssertProcedureFinished(timesTwo)
        XCTAssertEqual(timesTwo.output.success ?? 0, 4)
    }

    func test__requirement_is_nil_finishes_with_error() {
        let timesTwo = TransformProcedure<Int, Int> { return $0 * 2 }
        // Note that input has not been set
        wait(for: timesTwo)
        PKAssertProcedureError(timesTwo, ProcedureKitError.requirementNotSatisfied())
    }
}

class AsyncTransformProcedureTests: ProcedureKitTestCase {

    var dispatchQueue: DispatchQueue!

    override func setUp() {
        super.setUp()
        dispatchQueue = DispatchQueue.initiated
    }

    override func tearDown() {
        dispatchQueue = nil
        super.tearDown()
    }
    
    func test__requirement_is_transformed_to_result() {
        let timesTwo = AsyncTransformProcedure<Int, Int> { input, finishWithResult in
            self.dispatchQueue.async {
                finishWithResult(.success(input * 2))
            }
        }
        timesTwo.input = .ready(2)
        wait(for: timesTwo)
        PKAssertProcedureFinished(timesTwo)
        XCTAssertEqual(timesTwo.output.success ?? 0, 4)
    }

    func test__requirement_is_nil_finishes_with_error() {
        let timesTwo = AsyncTransformProcedure<Int, Int> { input, finishWithResult in
            self.dispatchQueue.async {
                finishWithResult(.success(input * 2))
            }
        }
        wait(for: timesTwo)
        PKAssertProcedureError(timesTwo, ProcedureKitError.requirementNotSatisfied())
    }
}
