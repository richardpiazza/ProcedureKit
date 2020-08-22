//
//  ProcedureKit
//
//  Copyright © 2015-2020 ProcedureKit. All rights reserved.
//

import XCTest
import TestingProcedureKit
@testable import ProcedureKit

class AuthorizedForTests: TestableCapabilityTestCase {

    static var allTests = [
        ("test__is_not_mututally_exclusive_by_default", test__is_not_mututally_exclusive_by_default),
        ("test__default_mututally_exclusive_category", test__default_mututally_exclusive_category),
        ("test__custom_mututally_exclusive_category", test__custom_mututally_exclusive_category),
        ("test__has_authorize_dependency", test__has_authorize_dependency),
        ("test__fails_if_capability_is_not_available", test__fails_if_capability_is_not_available),
        ("test__async_fails_if_capability_is_not_available", test__async_fails_if_capability_is_not_available),
        ("test__fails_if_requirement_is_not_met", test__fails_if_requirement_is_not_met),
        ("test__async_fails_if_requirement_is_not_met", test__async_fails_if_requirement_is_not_met),
        ("test__suceeds_if_requirement_is_met", test__suceeds_if_requirement_is_met),
        ("test__async_suceeds_if_requirement_is_met", test__async_suceeds_if_requirement_is_met),
        ("test__negated_authorized_for_and_no_failed_dependencies_succeeds", test__negated_authorized_for_and_no_failed_dependencies_succeeds),
    ]
    
    func test__is_not_mututally_exclusive_by_default() {
        // the AuthorizedFor condition itself does not confer mutual exclusivity by default
        XCTAssertFalse(authorizedFor.isMutuallyExclusive)
    }

    func test__default_mututally_exclusive_category() {
        XCTAssertTrue(authorizedFor.mutuallyExclusiveCategories.isEmpty)
    }

    func test__custom_mututally_exclusive_category() {
        authorizedFor = AuthorizedFor(capability, category: "testing")
        XCTAssertEqual(authorizedFor.mutuallyExclusiveCategories, ["testing"])
    }

    func test__has_authorize_dependency() {
        guard let dependency = authorizedFor.producedDependencies.first else {
            XCTFail("Condition did not return a dependency")
            return
        }

        guard let _ = dependency as? AuthorizeCapabilityProcedure<TestableCapability.Status> else {
            XCTFail("Dependency is not the correct type")
            return
        }
    }

    func test__fails_if_capability_is_not_available() {
        capability.serviceIsAvailable = false
        wait(for: procedure)
        PKAssertConditionFailed(authorizedFor.output.value ?? .success(true), failedWithError: ProcedureKitError.capabilityUnavailable())
        PKAssertProcedureCancelledWithError(procedure, ProcedureKitError.capabilityUnavailable())
    }

    func test__async_fails_if_capability_is_not_available() {
        capability.isAsynchronous = true
        capability.serviceIsAvailable = false
        wait(for: procedure)
        PKAssertConditionFailed(authorizedFor.output.value ?? .success(true), failedWithError: ProcedureKitError.capabilityUnavailable())
        PKAssertProcedureCancelledWithError(procedure, ProcedureKitError.capabilityUnavailable())
    }

    func test__fails_if_requirement_is_not_met() {
        capability.requirement = .maximum
        capability.responseAuthorizationStatus = .minimumAuthorized
        wait(for: procedure)
        PKAssertConditionFailed(authorizedFor.output.value ?? .success(true), failedWithError: ProcedureKitError.capabilityUnauthorized())
        PKAssertProcedureCancelledWithError(procedure, ProcedureKitError.capabilityUnauthorized())
    }

    func test__async_fails_if_requirement_is_not_met() {
        capability.isAsynchronous = true
        capability.requirement = .maximum
        capability.responseAuthorizationStatus = .minimumAuthorized

        wait(for: procedure)
        PKAssertConditionFailed(authorizedFor.output.value ?? .success(true), failedWithError: ProcedureKitError.capabilityUnauthorized())
        PKAssertProcedureCancelledWithError(procedure, ProcedureKitError.capabilityUnauthorized())
    }

    func test__suceeds_if_requirement_is_met() {
        wait(for: procedure)
        PKAssertProcedureFinished(procedure)
        PKAssertConditionSatisfied(authorizedFor.output.value ?? .success(false))
    }

    func test__async_suceeds_if_requirement_is_met() {
        capability.isAsynchronous = true
        wait(for: procedure)
        PKAssertProcedureFinished(procedure)
        PKAssertConditionSatisfied(authorizedFor.output.value ?? .success(false))
    }

    func test__negated_authorized_for_and_no_failed_dependencies_succeeds() {
        // See: Issue #515
        // https://github.com/ProcedureKit/ProcedureKit/issues/515
        //
        // This test previously failed because dependencies of Conditions
        // were incorporated into the dependencies of the parent Procedure
        // and, thus, the NoFailedDependenciesCondition picked up the
        // failing dependencies of the NegatedCondition.
        //

        // set the TestableCapability so it fails to meet the requirement
        capability.requirement = .maximum
        capability.responseAuthorizationStatus = .minimumAuthorized

        let procedure = TestProcedure()
        let authorizedCondition = AuthorizedFor(capability)

        procedure.addCondition(NegatedCondition(authorizedCondition))
        procedure.addCondition(NoFailedDependenciesCondition())

        wait(for: procedure)
        PKAssertProcedureFinished(procedure)
    }
}
