//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
@testable import ProcedureKit
import TestingProcedureKit

class LogEntryTests: LoggingTestCase {

    static var allTests = [
        ("test__trace_description", test__trace_description),
        ("test__message_description", test__message_description),
        ("test__value_description", test__value_description),
        ("test__value_nil_description", test__value_nil_description),
        ("test__appendFormattedMetadata", test__appendFormattedMetadata),
    ]
    
    func test__trace_description() {
        let payload: Log.Entry.Payload = .trace
        XCTAssertEqual(payload.description, "")
    }

    func test__message_description() {
        let payload: Log.Entry.Payload = .message("Hello World")
        XCTAssertEqual(payload.description, "Hello World")
    }

    func test__value_description() {
        let payload: Log.Entry.Payload = .value("Hello World")
        XCTAssertEqual(payload.description, "Hello World")
    }

    func test__value_nil_description() {
        let payload: Log.Entry.Payload = .value(nil)
        XCTAssertEqual(payload.description, "<nil-value>")
    }

    func test__appendFormattedMetadata() {
        let appended = entry
            .append(formattedMetadata: "Foo")
            .append(formattedMetadata: nil)
            .append(formattedMetadata: "")
            .append(formattedMetadata: "   ")
            .append(formattedMetadata: "Bar")
        XCTAssertEqual(appended.formattedMetadata, "Foo Bar")
        guard case let .message(text) = entry.payload else {
            XCTFail("Entry did not have a message payload"); return
        }
        XCTAssertEqual(text, "Hello World")
    }
}
