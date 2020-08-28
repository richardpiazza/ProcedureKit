//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

open class RepeatTestCase: ProcedureKitTestCase {

    public var repeatProcedure: RepeatProcedure<TestProcedure>!

    public var expectedError: TestError!

    open override func setUp() {
        super.setUp()
        expectedError = TestError()
    }

    open override func tearDown() {
        expectedError = nil
        super.tearDown()
    }

    public func createIterator(withDelay delay: Delay = .by(0.001)) -> AnyIterator<RepeatProcedurePayload<TestProcedure>> {
        return AnyIterator { RepeatProcedurePayload(operation: TestProcedure(), delay: .by(0.01)) }
    }

    public func createIterator(succeedsAfterCount target: Int) -> AnyIterator<TestProcedure> {
        var count = 0
        let _error = expectedError
        return AnyIterator {
            guard count < target else { return nil }
            defer { count += 1 }
            if count < target - 1 {
                return TestProcedure(error: _error)
            }
            else {
                return TestProcedure()
            }
        }
    }
}
