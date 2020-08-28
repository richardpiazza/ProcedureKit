//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

public class TestableLogWriter: LogWriter {

    private let stateLock = PThreadMutex()
    private var _entries: [Log.Entry] = []

    public init() { }

    @discardableResult
    private func synchronise<T>(block: () -> T) -> T {
        return stateLock.withCriticalScope(block: block)
    }

    public var entries: [Log.Entry] {
        return synchronise { _entries }
    }

    public func write(entry: Log.Entry) {
        synchronise {
            _entries.append(entry)
        }
    }
}
