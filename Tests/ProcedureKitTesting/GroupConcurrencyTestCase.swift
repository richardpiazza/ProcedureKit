//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

// MARK: - GroupConcurrencyTestCase

open class GroupConcurrencyTestCase: ConcurrencyTestCase {

    public class GroupTestResult: TestResult {
        public let group: TestGroupProcedure

        public init(group: TestGroupProcedure, procedures: [TrackingProcedure], duration: TimeInterval, registrar: Registrar) {
            self.group = group
            super.init(procedures: procedures, duration: duration, registrar: registrar)
        }
    }

    @discardableResult public func concurrencyTestGroup(children: Int = 3, withDelayMicroseconds delayMicroseconds: useconds_t = 500000 /* 0.5 seconds */, withName name: String = #function, withTimeout timeout: TimeInterval = 3, withConfigureBlock configure: (TestGroupProcedure) -> Void, withExpectations expectations: Expectations) -> GroupTestResult {

        return concurrencyTestGroup(children: children, withDelayMicroseconds: delayMicroseconds, withName: name, withTimeout: timeout,
            withConfigureBlock: configure,
            completionBlock: { (results) in
                XCTAssertResults(results, matchExpectations: expectations)
        })
    }

    @discardableResult public func concurrencyTestGroup(children: Int = 3, withDelayMicroseconds delayMicroseconds: useconds_t = 500000 /* 0.5 seconds */, withName name: String = #function, withTimeout timeout: TimeInterval = 3, withConfigureBlock configure: (TestGroupProcedure) -> Void, completionBlock completion: (GroupTestResult) -> Void) -> GroupTestResult {

        let registrar = Registrar()
        let testProcedures = create(procedures: children, delayMicroseconds: delayMicroseconds, withRegistrar: registrar)
        let group = TestGroupProcedure(operations: testProcedures)

        configure(group)

        let startTime = Date().timeIntervalSince1970
        wait(for: group, withTimeout: timeout)
        let endTime = Date().timeIntervalSince1970
        let duration = Double(endTime) - Double(startTime)

        let result = GroupTestResult(group: group, procedures: testProcedures, duration: duration, registrar: registrar)
        completion(result)
        return result
    }
}
