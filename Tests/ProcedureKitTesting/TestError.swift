//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation

public struct TestError: Error, Equatable, CustomDebugStringConvertible {

    public static func verify(errors: [Error], count: Int = 1, contains error: TestError) -> Bool {
        return (errors.count == count) && errors.contains { ($0 as? TestError) ?? TestError() == error }
    }

    let uuid = UUID()

    public init() { }

    public var debugDescription: String {
        return "TestError (\(uuid.uuidString))"
    }
}
