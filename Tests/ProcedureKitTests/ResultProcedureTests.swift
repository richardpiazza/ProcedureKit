//
//  ProcedureKit
//
//  Copyright © 2015-2020 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKitTesting
@testable import ProcedureKit

class ResultProcedureTests: ProcedureKitTestCase {

    static var allTests = [
        ("test__throwing_output", test__throwing_output),
    ]
    
    func test__throwing_output() {
        typealias TypeUnderTest = ResultProcedure<String>
        var blockDidExecute = false

        let result = TypeUnderTest { (_) -> String in
            blockDidExecute = true
            return "Hello World"
        }

        wait(for: result)
        XCTAssertTrue(blockDidExecute)
        PKAssertProcedureOutput(result, "Hello World")
    }
}
