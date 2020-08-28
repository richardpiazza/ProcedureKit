//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest

public class TestableURLSessionTask: Equatable {

    public static func == (lhs: TestableURLSessionTask, rhs: TestableURLSessionTask) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    public typealias CompletionBlock = (TestableURLSessionTask) -> Void

    public let delay: TimeInterval
    public let uuid = UUID()

    public var didResume: Bool {
        get { return stateLock.withCriticalScope { _didResume } }
    }
    public var didCancel: Bool {
        get { return stateLock.withCriticalScope { _didCancel } }
    }

    private let completion: CompletionBlock
    private var completionWorkItem: DispatchWorkItem!
    private var stateLock = NSLock()
    private var _didResume = false
    private var _didCancel = false
    private var _didFinish = false

    public init(delay: TimeInterval = 0.000_001, completion: @escaping CompletionBlock) {
        self.delay = delay
        self.completion = completion
        self.completionWorkItem = DispatchWorkItem(block: { [weak self] in
            guard let strongSelf = self else { return }
            guard !strongSelf.completionWorkItem.isCancelled else { return }
            guard strongSelf.shouldFinish() else { return }
            completion(strongSelf)
        })
    }

    public func resume() {
        stateLock.withCriticalScope {
            _didResume = true
        }
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + delay, execute: completionWorkItem)
    }

    public func cancel() {
        // Behavior: cancel the delayed completion, and call the completion handler immediately
        // (Unless already finished)
        guard shouldFinish() else { return }
        stateLock.withCriticalScope {
            _didCancel = true
            completionWorkItem.cancel()
        }
        completion(self)
    }

    private func shouldFinish() -> Bool {
        return stateLock.withCriticalScope { () -> Bool in
            guard !_didFinish else { return false }
            _didFinish = true
            return true
        }
    }
}
