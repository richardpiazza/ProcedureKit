//
//  ProcedureKit
//
//  Copyright © 2015-2020 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKitTesting
@testable import ProcedureKit

class AuthorizeTests: TestableCapabilityTestCase {

    static var allTests = [
        ("test__authorize", test__authorize),
        ("test__authorize_procedure_is_mutually_exclusive", test__authorize_procedure_is_mutually_exclusive),
    ]
    
    func test__authorize() {
        wait(for: authorize)
        XCTAssertTrue(capability.didRequestAuthorization)
    }

    func test__authorize_procedure_is_mutually_exclusive() {
        // AuthorizeCapabilityProcedure should have a condition that is:
        //  MutuallyExclusive<AuthorizeCapabilityProcedure<TestableCapability.Status>>
        // with a mutually exclusive category of:
        //  "AuthorizeCapabilityProcedure(TestableCapability)"

        var foundMutuallyExclusiveCondition = false
        for condition in authorize.conditions {
            guard condition.isMutuallyExclusive else { continue }
            guard condition is MutuallyExclusive<AuthorizeCapabilityProcedure<TestableCapability.Status>> else { continue }
            guard condition.mutuallyExclusiveCategories == ["AuthorizeCapabilityProcedure(TestableCapability)"] else { continue }
            foundMutuallyExclusiveCondition = true
            break
        }

        XCTAssertTrue(foundMutuallyExclusiveCondition, "Failed to find appropriate Mutual Exclusivity condition")
    }
}
