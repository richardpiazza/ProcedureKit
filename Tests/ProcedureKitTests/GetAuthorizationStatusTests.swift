//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKitTesting
@testable import ProcedureKit

class GetAuthorizationStatusTests: TestableCapabilityTestCase {

    static var allTests = [
        ("test__sets_result", test__sets_result),
        ("test__async_sets_result", test__async_sets_result),
        ("test__runs_completion_block", test__runs_completion_block),
        ("test__async_runs_completion_block", test__async_runs_completion_block),
        ("test__void_status_equal", test__void_status_equal),
        ("test__void_status_meets_requirements", test__void_status_meets_requirements),
    ]
    
    func test__sets_result() {
        wait(for: getAuthorizationStatus)
        XCTAssertGetAuthorizationStatus(getAuthorizationStatus.output.success, expected: (true, .unknown))
        XCTAssertTestCapabilityStatusChecked()
    }

    func test__async_sets_result() {
        capability.isAsynchronous = true
        wait(for: getAuthorizationStatus)
        XCTAssertGetAuthorizationStatus(getAuthorizationStatus.output.success, expected: (true, .unknown))
        XCTAssertTestCapabilityStatusChecked()
    }

    func test__runs_completion_block() {
        var completedWithResult: GetAuthorizationStatusProcedure<TestableCapability.Status>.Output = (false, .unknown)
        getAuthorizationStatus = GetAuthorizationStatusProcedure(capability) { completedWithResult = $0 }

        wait(for: getAuthorizationStatus)
        XCTAssertGetAuthorizationStatus(completedWithResult, expected: (true, .unknown))
        XCTAssertTestCapabilityStatusChecked()
    }

    func test__async_runs_completion_block() {
        capability.isAsynchronous = true
        var completedWithResult: GetAuthorizationStatusProcedure<TestableCapability.Status>.Output = (false, .unknown)

        getAuthorizationStatus = GetAuthorizationStatusProcedure(capability) { result in
            completedWithResult = result
        }

        wait(for: getAuthorizationStatus)
        XCTAssertGetAuthorizationStatus(completedWithResult, expected: (true, .unknown))
        XCTAssertTestCapabilityStatusChecked()
    }

    func test__void_status_equal() {
        XCTAssertEqual(Capability.VoidStatus(), Capability.VoidStatus())
    }

    func test__void_status_meets_requirements() {
        XCTAssertTrue(Capability.VoidStatus().meets(requirement: ()))
    }
}
