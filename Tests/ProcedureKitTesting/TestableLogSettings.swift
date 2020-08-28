//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

public class TestableLogSettings: LogSettings {

    private static var shared: LogChannel = Log.Channel<TestableLogSettings>(enabled: true, severity: .verbose, writer: TestableLogWriter(), formatter: TestableLogFormatter())

    public static var channel: LogChannel {
        get { return shared }
        set { shared = newValue }
    }

    public static var enabled: Bool {
        get { return channel.enabled }
        set { channel.enabled = newValue }
    }

    public static var severity: Log.Severity {
        get { return channel.severity }
        set { channel.severity = newValue }
    }

    public static var writer: LogWriter {
        get { return channel.writer }
        set { channel.writer = newValue }
    }

    public static var formatter: LogFormatter {
        get { return channel.formatter }
        set { channel.formatter = newValue }
    }
}
