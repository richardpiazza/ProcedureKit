//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

// MARK: - ConcurrencyRegistrar

open class ConcurrencyRegistrar {
    private struct State {
        var operations: [Operation] = []
        var maximumDetected: Int = 0
    }
    private let state = Protector(State())

    public var maximumDetected: Int {
        get {
            return state.read { $0.maximumDetected }
        }
    }
    public func registerRunning(_ operation: Operation) {
        state.write { ward in
            ward.operations.append(operation)
            ward.maximumDetected = max(ward.operations.count, ward.maximumDetected)
        }
    }
    public func deregisterRunning(_ operation: Operation) {
        state.write { ward in
            if let opIndex = ward.operations.firstIndex(of: operation) {
                ward.operations.remove(at: opIndex)
            }
        }
    }
}
