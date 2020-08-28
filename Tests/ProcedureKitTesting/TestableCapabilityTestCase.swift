//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

open class TestableCapabilityTestCase: ProcedureKitTestCase {

    public var capability: TestableCapability!
    public var getAuthorizationStatus: GetAuthorizationStatusProcedure<TestableCapability.Status>!
    public var authorize: AuthorizeCapabilityProcedure<TestableCapability.Status>!
    public var authorizedFor: AuthorizedFor<TestableCapability.Status>!

    open override func setUp() {
        super.setUp()
        capability = TestableCapability()
        getAuthorizationStatus = GetAuthorizationStatusProcedure(capability)
        authorize = AuthorizeCapabilityProcedure(capability)
        authorizedFor = AuthorizedFor(capability)
        procedure.addCondition(authorizedFor)
    }

    open override func tearDown() {
        capability = nil
        getAuthorizationStatus.cancel()
        getAuthorizationStatus = nil
        authorize.cancel()
        authorize = nil
        authorizedFor = nil
        super.tearDown()
    }

    public func XCTAssertGetAuthorizationStatus<Status: AuthorizationStatus>(_ exp1: @autoclosure () throws -> (Bool, Status)?, expected exp2: @autoclosure () throws -> (Bool, Status), _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) where Status: Equatable {
        __XCTEvaluateAssertion(testCase: self, message(), file: file, line: line) {
            let result = try exp1()
            let expected = try exp2()

            guard let (isAvailable, status) = result else {
                return .expectedFailure("GetAuthorizationStatus result was not set.")
            }
            guard isAvailable == expected.0 else {
                return .expectedFailure("Capability's availability was not \(expected.0).")
            }
            guard status == expected.1 else {
                return .expectedFailure("\(status) was not \(expected.1).")
            }
            return .success
        }
    }

    public func XCTAssertTestCapabilityStatusChecked(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        __XCTEvaluateAssertion(testCase: self, message(), file: file, line: line) {
            guard capability.didCheckIsAvailable else {
                return .expectedFailure("Capability did not check availability.")
            }
            guard capability.didCheckAuthorizationStatus else {
                return .expectedFailure("Capability did not check authorization status.")
            }
            guard !capability.didRequestAuthorization else {
                return .expectedFailure("Capability did request authorization unexpectedly.")
            }
            return .success
        }
    }
}
