//
//  ProcedureKit
//
//  Copyright © 2015-2020 ProcedureKit. All rights reserved.
//

import XCTest
@testable import ProcedureKit
import ProcedureKitTesting

class LogChannelsTests: LoggingTestCase {

    static var allTests = [
        ("test__setting_enabled_sets_all_channels", test__setting_enabled_sets_all_channels),
        ("test__setting_writer", test__setting_writer),
        ("test__getting_current_channel", test__getting_current_channel),
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

    func test__setting_enabled_sets_all_channels() {
        channels.enabled = false
        XCTAssertFalse(channels.verbose.enabled)
        XCTAssertFalse(channels.info.enabled)
        XCTAssertFalse(channels.event.enabled)
        XCTAssertFalse(channels.debug.enabled)
        XCTAssertFalse(channels.warning.enabled)
        XCTAssertFalse(channels.fatal.enabled)
        channels.enabled = true
        XCTAssertTrue(channels.verbose.enabled)
        XCTAssertTrue(channels.info.enabled)
        XCTAssertTrue(channels.event.enabled)
        XCTAssertTrue(channels.debug.enabled)
        XCTAssertTrue(channels.warning.enabled)
        XCTAssertTrue(channels.fatal.enabled)
    }

    func test__setting_writer() {
        let writer = TestableLogWriter()
        channels.writer = writer
        channels.debug.message("Hello World")
        XCTAssertEqual(writer.entries.count, 1)
        guard let payload = writer.entries.first?.payload, case let .message(text) = payload else {
            XCTFail("Entry did not have a message payload"); return
        }
        XCTAssertEqual(text, "Hello World")
    }

    func test__getting_current_channel() {
        channels.severity = .verbose
        XCTAssertEqual(channels.current.severity, .verbose)
        channels.severity = .info
        XCTAssertEqual(channels.current.severity, .info)
        channels.severity = .event
        XCTAssertEqual(channels.current.severity, .event)
        channels.severity = .debug
        XCTAssertEqual(channels.current.severity, .debug)
        channels.severity = .warning
        XCTAssertEqual(channels.current.severity, .warning)
        channels.severity = .fatal
        XCTAssertEqual(channels.current.severity, .fatal)
    }
}
