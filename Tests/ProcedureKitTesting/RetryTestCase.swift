//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

open class RetryTestCase: ProcedureKitTestCase {

    public typealias Test = TestProcedure
    public typealias Retry = RetryProcedure<TestProcedure>
    public typealias Handler = Retry.Handler

    public class RetryTestCaseInfo {
        public var numberOfExecuctions: Int = 0
        public var numberOfFailures: Int = 0
    }

    public var retry: Retry!

    public var error: TestError!

    public func createOperationIterator(succeedsAfterFailureCount failureThreshold: Int) -> AnyIterator<Test> {
        let info = RetryTestCaseInfo()
        return AnyIterator {
            let procedure = TestProcedure()
            procedure.addCondition(BlockCondition {
                guard info.numberOfFailures == failureThreshold else { throw ProcedureKitError.conditionFailed() }
                return true
            })
            procedure.addWillFinishBlockObserver { _, _, _ in
                info.numberOfExecuctions += 1
                info.numberOfFailures += 1
            }
            return procedure
        }
    }

    public func createPayloadIterator(succeedsAfterFailureCount failureThreshold: Int) -> AnyIterator<RepeatProcedurePayload<Test>> {
        let info = RetryTestCaseInfo()
        return AnyIterator {
            let procedure = TestProcedure()
            procedure.addCondition(BlockCondition {
                guard info.numberOfFailures == failureThreshold else { throw ProcedureKitError.conditionFailed() }
                return true
            })
            procedure.addWillFinishBlockObserver { _, _, _ in
                info.numberOfExecuctions += 1
                info.numberOfFailures += 1
            }
            return RepeatProcedurePayload(operation: procedure, delay: .by(0.0001))
        }
    }
}
