//
//  ProcedureKit
//
//  Copyright © 2015-2020 ProcedureKit. All rights reserved.
//

import XCTest
@testable import ProcedureKit
import ProcedureKitTesting

class LogWriterTests: LoggingTestCase {

    static var allTests = [
        ("test__redirecting_log_writer", test__redirecting_log_writer),
    ]
    
    var channels: Log.Channels<TestableLogSettings>!

    override func setUp() {
        super.setUp()
        channels = Log.Channels<TestableLogSettings>()
    }

    override func tearDown() {
        channels = nil
        super.tearDown()
    }

    func test__redirecting_log_writer() {
        let writer = TestableLogWriter()
        channels.writer = Log.Writers.Redirecting(writers: [writer])
        channels.debug.message("Hello World")
        XCTAssertEqual(writer.entries.count, 1)
        guard let payload = writer.entries.first?.payload, case let .message(text) = payload else {
            XCTFail("Entry did not have a message payload"); return
        }
        XCTAssertEqual(text, "Hello World")
    }
}
