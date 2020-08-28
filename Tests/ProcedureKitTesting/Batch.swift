//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

public protocol BatchProtocol {
    var startTime: TimeInterval { get }
    var dispatchGroup: DispatchGroup { get }
    var queue: ProcedureQueue { get }
    var number: Int { get }
    var size: Int { get }

    func counter(named: String) -> Int

    @discardableResult func incrementCounter(named: String) -> Int
}

public extension BatchProtocol {

    func didIncrementCounter(named name: String) -> Bool {
        let currentValue = counter(named: name)
        let newValue = Int(incrementCounter(named: name))
        return newValue > currentValue
    }
}

open class Batch: BatchProtocol {
    public let startTime = Date().timeIntervalSince1970
    public let dispatchGroup = DispatchGroup()
    public let queue: ProcedureQueue
    public let number: Int
    public let size: Int

    private var _countersLock = NSLock()
    private var _counters = Dictionary<String, Int>()

    public init(queue: ProcedureQueue = ProcedureQueue(), number: Int, size: Int) {
        self.queue = queue
        self.number = number
        self.size = size
    }

    public func counter(named: String = "Standard") -> Int {
        return _countersLock.withCriticalScope { _counters[named] ?? 0 }
    }

    @discardableResult public func incrementCounter(named: String = "Standard") -> Int {
        return _countersLock.withCriticalScope {
            guard let currentCount = _counters[named] else {
                _counters[named] = 1
                return 1
            }
            _counters[named] = currentCount + 1
            return currentCount + 1
        }
    }
}
