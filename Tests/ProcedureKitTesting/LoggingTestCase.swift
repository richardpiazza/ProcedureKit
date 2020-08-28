//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

open class LoggingTestCase: ProcedureKitTestCase {

    open var entry: Log.Entry!

    override open func setUp() {
        super.setUp()
        Log.enabled = true
        Log.severity = .verbose
        TestableLogSettings.writer = TestableLogWriter()
        TestableLogSettings.formatter = TestableLogFormatter()
        entry = Log.Entry(payload: .message("Hello World"), severity: .debug, file: "the file", function: "the function", line: 100, threadID: 1000)
    }

    override open func tearDown() {
        Log.enabled = true
        Log.severity = .warning
        entry = nil
        super.tearDown()
    }
}
