//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

internal enum __XCTAssertionResult {
    case success
    case expectedFailure(String?)
    case unexpectedFailure(Swift.Error)

    var isExpected: Bool {
        switch self {
        case .unexpectedFailure: return false
        default: return true
        }
    }

    func failureDescription() -> String {
        let explanation: String
        switch self {
        case .success: explanation = "passed"
        case .expectedFailure(let details?): explanation = "failed: \(details)"
        case .expectedFailure: explanation = "failed"
        case .unexpectedFailure(let error): explanation = "threw error \"\(error)\""
        }
        return explanation
    }
}

internal func __XCTEvaluateAssertion(testCase: XCTestCase, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line, expression: () throws -> __XCTAssertionResult) {
    let result: __XCTAssertionResult
    do {
        result = try expression()
    }
    catch {
        result = .unexpectedFailure(error)
    }

    switch result {
    case .success: return
    default:
        testCase.recordFailure(
            withDescription: "\(result.failureDescription()) - \(message())",
            inFile: String(describing: file), atLine: Int(line),
            expected: result.isExpected
        )
    }
}
