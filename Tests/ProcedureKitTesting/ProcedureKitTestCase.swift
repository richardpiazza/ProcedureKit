//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

open class ProcedureKitTestCase: XCTestCase {

    public var queue: ProcedureQueue!
    public var delegate: QueueTestDelegate! // swiftlint:disable:this weak_delegate
    open var procedure: TestProcedure!

    open override func setUp() {
        super.setUp()
        queue = ProcedureQueue()
        delegate = QueueTestDelegate()
        queue.delegate = delegate
        procedure = TestProcedure()
    }

    open override func tearDown() {
        if let procedure = procedure {
            procedure.cancel()
        }
        if let queue = queue {
            queue.cancelAllOperations()
            queue.waitUntilAllOperationsAreFinished()
        }
        delegate = nil
        queue = nil
        procedure = nil
        Log.enabled = false
        Log.severity = .warning
        ExclusivityManager.__tearDownForUnitTesting()
        super.tearDown()
    }

    public func set(queueDelegate delegate: QueueTestDelegate) {
        self.delegate = delegate
        queue.delegate = delegate
    }

    public func run(operation: Operation) {
        run(operations: [operation])
    }

    public func run(operations: Operation...) {
        run(operations: operations)
    }

    public func run(operations: [Operation]) {
        queue.addOperations(operations, waitUntilFinished: false)
    }

    public func wait(for procedures: Procedure..., withTimeout timeout: TimeInterval = 3, withExpectationDescription expectationDescription: String = #function, handler: XCWaitCompletionHandler? = nil) {
        wait(forAll: procedures, withTimeout: timeout, withExpectationDescription: expectationDescription, handler: handler)
    }

    public func wait(forAll procedures: [Procedure], withTimeout timeout: TimeInterval = 3, withExpectationDescription expectationDescription: String = #function, handler: XCWaitCompletionHandler? = nil) {
        addCompletionBlockTo(procedures: procedures)
        run(operations: procedures)
        waitForExpectations(timeout: timeout, handler: handler)
    }

    /// Runs a Procedure on the queue, waiting until it is complete to return,
    /// but calls a specified block before the wait.
    ///
    /// IMPORTANT: This function calls the specified block immediately after adding
    ///            the Procedure to the queue. This does *not* ensure any specific
    ///            ordering/timing in regards to the block and the Procedure executing.
    ///
    /// - Parameters:
    ///   - procedure: a Procedure
    ///   - timeout: (optional) a timeout for the wait
    ///   - expectationDescription: (optional) an expectation description
    ///   - checkBeforeWait: a block to be executed before the wait (see above)
    public func check<T: Procedure>(procedure: T, withAdditionalProcedures additionalProcedures: Procedure..., withTimeout timeout: TimeInterval = 3, withExpectationDescription expectationDescription: String = #function, checkBeforeWait: (T) -> Void) {
        var allProcedures = additionalProcedures
        allProcedures.append(procedure)
        addCompletionBlockTo(procedures: allProcedures)
        run(operations: allProcedures)
        checkBeforeWait(procedure)
        waitForExpectations(timeout: timeout, handler: nil)
    }

    public func checkAfterDidExecute<T>(procedure: T, withTimeout timeout: TimeInterval = 3, withExpectationDescription expectationDescription: String = #function, checkAfterDidExecuteBlock: @escaping (T) -> Void) where T: Procedure {
        addCompletionBlockTo(procedure: procedure, withExpectationDescription: expectationDescription)
        procedure.addDidExecuteBlockObserver { (procedure) in
            checkAfterDidExecuteBlock(procedure)
        }
        run(operations: procedure)
        waitForExpectations(timeout: timeout, handler: nil)
    }

    public func addCompletionBlockTo(procedure: Procedure, withExpectationDescription expectationDescription: String = #function) {
        // Make a finishing procedure, which depends on this target Procedure.
        let finishingProcedure = makeFinishingProcedure(for: procedure, withExpectationDescription: expectationDescription)
        // Add the did finish expectation block to the finishing procedure
        addExpectationCompletionBlockTo(procedure: finishingProcedure, withExpectationDescription: expectationDescription)
        run(operation: finishingProcedure)
    }

    public func addCompletionBlockTo<S: Sequence>(procedures: S, withExpectationDescription expectationDescription: String = #function) where S.Iterator.Element == Procedure {
        for (i, procedure) in procedures.enumerated() {
            addCompletionBlockTo(procedure: procedure, withExpectationDescription: "\(i), \(expectationDescription)")
        }
    }

    @discardableResult public func addExpectationCompletionBlockTo(procedure: Procedure, withExpectationDescription expectationDescription: String = #function) -> XCTestExpectation {
        let expect = expectation(description: "Test: \(expectationDescription), \(UUID())")
        add(expectation: expect, to: procedure)
        return expect
    }

    public func add(expectation: XCTestExpectation, to procedure: Procedure) {
        weak var weakExpectation = expectation
        procedure.addDidFinishBlockObserver { _, _ in
            DispatchQueue.main.async {
                weakExpectation?.fulfill()
            }
        }
    }

    func makeFinishingProcedure(for procedure: Procedure, withExpectationDescription expectationDescription: String = #function) -> Procedure {
        let finishing = BlockProcedure { }
        finishing.log.enabled = false
        finishing.addDependency(procedure)
        // Adds a will add operation observer, which adds the produced operation as a dependency
        // of the finishing procedure. This way, we don't actually finish, until the
        // procedure, and any produced operations also finish.
        procedure.addWillAddOperationBlockObserver { [weak weakFinishing = finishing] _, operation in
            guard let finishing = weakFinishing else { fatalError("Finishing procedure is finished + gone, but a WillAddOperation observer on a dependency was called. This should never happen.") }
            finishing.addDependency(operation)
        }
        finishing.name = "FinishingBlockProcedure(for: \(procedure.operationName))"
        return finishing
    }
}

public extension ProcedureKitTestCase {

    func createCancellingProcedure() -> TestProcedure {
        let procedure = TestProcedure(name: "Cancelling Test Procedure")
        procedure.addWillExecuteBlockObserver { procedure, _ in
            procedure.cancel()
        }
        return procedure
    }
}

public extension ProcedureKitTestCase {

    func PKAssertGroupErrors<T: GroupProcedure>(_ exp: @autoclosure () throws -> T, count exp2:  @autoclosure () throws -> Int, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        __XCTEvaluateAssertion(testCase: self, message(), file: file, line: line) {

            let procedure = try exp()
            let count = try exp2()

            guard count > 0 else {
                guard procedure.error == nil else {
                    return .expectedFailure("\(procedure.procedureName) had an error.")
                }
                return .success
            }

            let groupErrors = procedure.children.compactMap { ($0 as? Procedure)?.error }

            guard groupErrors.count == count else {
                return .expectedFailure("\(procedure.procedureName) expected \(count) errors, received \(groupErrors.count).")
            }

            return .success
        }
    }

    func PKAssertGroupErrors<T: GroupProcedure, E: Error>(_ exp: @autoclosure () throws -> T, doesNot: Bool = false, contain exp2:  @autoclosure () throws -> E, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) where E: Equatable {
        __XCTEvaluateAssertion(testCase: self, message(), file: file, line: line) {

            let procedure = try exp()
            let otherError = try exp2()

            guard procedure.error != nil else {
                return .expectedFailure("\(procedure.procedureName) did not have an error.")
            }

            let errors: [E] = procedure.children.compactMap { ($0 as? Procedure)?.error as? E }

            guard errors.count > 0 else {
                return .expectedFailure("\(procedure.procedureName) did not have any errors of type \(E.self).")
            }

            switch (doesNot, errors.contains(otherError)) {
            case (false, false):
                return .expectedFailure("\(procedure.procedureName) errors did not contain \(otherError).")
            case (true, true):
                return .expectedFailure("\(procedure.procedureName) errors did contain \(otherError).")
            default:
                break
            }

            return .success
        }
    }
}

public extension ProcedureKitTestCase {

    func PKAssertProcedureLogContainsMessage<T: Procedure>(_ exp: @autoclosure () throws -> T, _ exp2: @autoclosure () throws -> String, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        __XCTEvaluateAssertion(testCase: self, message(), file: file, line: line) {

            let procedure = try exp()

            guard let writer = procedure.log.writer as? TestableLogWriter else {
                return .expectedFailure("\(procedure.procedureName) did not have a testable log writer.")
            }

            let loggedMessages: [String] = writer.entries.compactMap { $0.message }

            guard loggedMessages.count > 0 else {
                return .expectedFailure("\(procedure.procedureName) did not log any messages")
            }

            let text = try exp2()

            guard loggedMessages.contains(text) else {
                return .expectedFailure("\(procedure.procedureName) did not log the message: \(text)")
            }

            return .success
        }
    }
}

// MARK: Procedure Assertions

public extension ProcedureKitTestCase {

    func PKAssertProcedureFinished<T: Procedure>(_ exp: @autoclosure () throws -> T, withErrors: Bool = false, cancelling: Bool = false, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        __XCTEvaluateAssertion(testCase: self, message(), file: file, line: line) {

            let procedure = try exp()

            // Errors are expected
            if withErrors {
                guard let _ = procedure.error else {
                    return .expectedFailure("\(procedure.procedureName) did not have an error.")
                }
            }
            // Errors are not expected
            else {
                guard procedure.error == nil else {
                    return .expectedFailure("\(procedure.procedureName) has an error.")
                }
            }

            if cancelling {
                guard procedure.isCancelled else {
                    return .expectedFailure("\(procedure.procedureName) was not cancelled.")
                }
            }
            else {
                guard !procedure.isCancelled else {
                    return .expectedFailure("\(procedure.procedureName) was cancelled.")
                }
            }

            guard procedure.isFinished else {
                return .expectedFailure("\(procedure.procedureName) did not finish.")
            }

            return .success
        }
    }

    func PKAssertProcedureError<T: Procedure, E: Error>(_ exp: @autoclosure () throws -> T, _ exp2: @autoclosure () throws -> E, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) where E: Equatable {
        __XCTEvaluateAssertion(testCase: self, message(), file: file, line: line) {
            let procedure = try exp()
            let expectedError = try exp2()
            guard let error = procedure.error else {
                return .expectedFailure("\(procedure.procedureName) did not error.")
            }
            guard let e = error as? E else {
                return .expectedFailure("\(procedure.procedureName) error: \(error), was not the expected type.")
            }
            guard expectedError == e else {
                return .expectedFailure("\(procedure.procedureName) error: \(e), did not equal expected error: \(expectedError).")
            }
            return .success
        }
    }


    func PKAssertProcedureCancelled<T: Procedure>(_ exp: @autoclosure () throws -> T, withErrors: Bool = false, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        PKAssertProcedureFinished(try exp(), withErrors: withErrors, cancelling: true, message(), file: file, line: line)
    }

    func PKAssertProcedureFinishedWithError<T: Procedure, E: Error>(_ exp: @autoclosure () throws -> T, _ exp2: @autoclosure () throws -> E, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) where E: Equatable {
        PKAssertProcedureFinished(try exp(), withErrors: true, message(), file: file, line: line)
        PKAssertProcedureError(try exp(), try exp2(), message(), file: file, line: line)
    }

    func PKAssertProcedureCancelledWithError<T: Procedure, E: Error>(_ exp: @autoclosure () throws -> T, _ exp2: @autoclosure () throws -> E, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) where E: Equatable {
        PKAssertProcedureCancelled(try exp(), withErrors: true, message(), file: file, line: line)
        PKAssertProcedureError(try exp(), try exp2(), message(), file: file, line: line)
    }

    func PKAssertConditionSatisfied(_ exp1: @autoclosure () throws -> ConditionResult, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        __XCTEvaluateAssertion(testCase: self, message(), file: file, line: line) {
            let result = try exp1()
            switch result {
            case .success(true): break
            default:
                return .expectedFailure("Condition was not satisfied: \(result).")
            }
            return .success
        }
    }

    func PKAssertConditionFailed<E: Error>(_ exp1: @autoclosure () throws -> ConditionResult, failedWithError error: @autoclosure () throws -> E, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) where E: Equatable {
        __XCTEvaluateAssertion(testCase: self, message(), file: file, line: line) {

            let result = try exp1()
            let expectedError = try error()

            switch result {
            case let .failure(receivedError):
                guard let error = receivedError as? E else {
                    return .expectedFailure("Condition failed with unexpected error, \(receivedError).")
                }
                guard error == expectedError else {
                    return .expectedFailure("Condition failed with error: \(error), instead of: \(expectedError).")
                }
            default:
                return .expectedFailure("Condition did not fail, \(result).")
            }
            return .success
        }
    }

    func PKAssertProcedureOutput<T: Procedure>(_ exp: @autoclosure () throws -> T, _ exp2: @autoclosure () -> T.Output, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) where T: OutputProcedure, T.Output: Equatable {
        PKAssertProcedureFinished(try exp(), message(), file: file, line: line)
        __XCTEvaluateAssertion(testCase: self, message(), file: file, line: line) {
            let procedure = try exp()
            guard let output = procedure.output.success else {
                return .expectedFailure("\(procedure.procedureName) did not have a successful output value.")
            }
            let expectedOutput = exp2()
            guard expectedOutput == output else {
                return .expectedFailure("\(procedure.procedureName)'s successful output did not == \(expectedOutput).")
            }
            return .success
        }
    }
}

// MARK: Constrained to EventConcurrencyTrackingProcedureProtocol

public extension ProcedureKitTestCase {

    func PKAssertProcedureNoConcurrentEvents<T: EventConcurrencyTrackingProcedureProtocol>(_ exp: @autoclosure () throws -> T, minimumConcurrentDetected: Int = 1, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) where T: Procedure {
        __XCTEvaluateAssertion(testCase: self, message(), file: file, line: line) {
            let procedure = try exp()
            let detectedConcurrentEvents = procedure.concurrencyRegistrar.detectedConcurrentEvents
            guard procedure.concurrencyRegistrar.maximumDetected >= minimumConcurrentDetected && detectedConcurrentEvents.isEmpty else {
                return .expectedFailure("\(procedure.procedureName) detected concurrent events: \n\(detectedConcurrentEvents)")
            }
            return .success
        }
    }

    @available(*, unavailable, renamed: "PKAssertProcedureNoConcurrentEvents", message: "Use PKAssertProcedure* functions instead.")
    func XCTAssertProcedureNoConcurrentEvents<T: EventConcurrencyTrackingProcedureProtocol>(_ exp: @autoclosure () throws -> T, minimumConcurrentDetected: Int = 1, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) where T: Procedure {
        PKAssertProcedureNoConcurrentEvents(try exp(), minimumConcurrentDetected: minimumConcurrentDetected, message(), file: file, line: line)
    }
}
