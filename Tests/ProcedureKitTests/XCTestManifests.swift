//
//  ProcedureKit
//
//  Copyright © 2015-2020 ProcedureKit. All rights reserved.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AsyncBlockProcedureTests.allTests),
        testCase(AuthorizedForTests.allTests),
        testCase(AuthorizeTests.allTests),
        testCase(BatchProcedureTests.allTests),
        testCase(BlockConditionTests.allTests),
        testCase(BlockObserverSynchronizationTests.allTests),
        testCase(BlockObserverTests.allTests),
        testCase(BlockProcedureTests.allTests),
        testCase(CancellationTests.allTests),
        testCase(ComposedProcedureTests.allTests),
//        testCase(ConditionTests.allTests),
        testCase(DelayProcedureTests.allTests),
        testCase(DispatchQoSClassTests.allTests),
        testCase(DispatchQoSTests.allTests),
        testCase(FilterProcedureTests.allTests),
        testCase(FinishingConcurrencyTests.allTests),
        testCase(FinishingTests.allTests),
        testCase(GatedProcedureTests.allTests),
        testCase(GetAuthorizationStatusTests.allTests),
//        testCase(GroupTests.allTests),
        testCase(IgnoreErrorsProcedureTests.allTests),
        testCase(JSONEncodingTests.allTests),
        testCase(ResultProcedureTests.allTests),
        testCase(UIBlockProcedureTests.allTests),
    ]
}
#endif
