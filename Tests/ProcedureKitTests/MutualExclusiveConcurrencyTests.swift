//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import TestingProcedureKit
@testable import ProcedureKit

class MutualExclusiveConcurrencyTests: ConcurrencyTestCase {

    static var allTests = [
        ("test__mutually_exclusive_operation_are_run_exclusively", test__mutually_exclusive_operation_are_run_exclusively),
        ("test__mutually_exclusive_operations_added_concurrently_are_run_exclusively", test__mutually_exclusive_operations_added_concurrently_are_run_exclusively),
        ("test__mutual_exclusivity_with_dependencies", test__mutual_exclusivity_with_dependencies),
        ("test__mutual_exclusivity_when_initial_reference_to_queue_goes_away", test__mutual_exclusivity_when_initial_reference_to_queue_goes_away),
    ]
    
    func test__mutually_exclusive_operation_are_run_exclusively() {

        let numOperations = 3
        let delayMicroseconds: useconds_t = 500_000 // 0.5 seconds

        queue.maxConcurrentOperationCount = numOperations

        concurrencyTest(operations: numOperations, withDelayMicroseconds: delayMicroseconds, withTimeout: 3,
            withConfigureBlock: { (testOp) in
                let condition = MutuallyExclusive<TrackingProcedure>()
                testOp.addCondition(condition)
                return testOp
            },
            withExpectations: Expectations(
                checkMinimumDetected: 1,
                checkMaximumDetected: 1,
                checkAllProceduresFinished: true,
                checkMinimumDuration: TimeInterval(useconds_t(numOperations) * delayMicroseconds) / 1000000.0
            )
        )
    }

    func test__mutually_exclusive_operations_added_concurrently_are_run_exclusively() {
        // Attempt to add mutually exclusive operations to a queue simultaneously.
        // This should not affect their mutual exclusivity.
        // Covers Issue: https://github.com/ProcedureKit/ProcedureKit/issues/543

        let numOperations = 3
        let delayMicroseconds: useconds_t = 500000 // 0.5 seconds

        queue.maxConcurrentOperationCount = numOperations

        let procedures: [TrackingProcedure] = create(procedures: numOperations, delayMicroseconds: delayMicroseconds, withRegistrar: registrar).map {
            let condition = MutuallyExclusive<TrackingProcedure>()
            $0.addCondition(condition)
            addCompletionBlockTo(procedure: $0, withExpectationDescription: "\(String(describing: $0.name)), didFinish")
            return $0
        }

        let startTime = Date().timeIntervalSince1970

        // add procedures to the queue simultaneously
        let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
        for procedure in procedures {
            dispatchQueue.async { [weak weakQueue = self.queue] in
                guard let queue = weakQueue else { return }
                queue.addOperation(procedure)
            }
        }

        waitForExpectations(timeout: TimeInterval(numOperations), handler: nil)

        let endTime = Date().timeIntervalSince1970
        let duration = Double(endTime) - Double(startTime)

        XCTAssertResults(TestResult(procedures: procedures, duration: duration, registrar: registrar),
            matchExpectations: Expectations(
                checkMinimumDetected: 1,
                checkMaximumDetected: 1,
                checkAllProceduresFinished: true,
                checkMinimumDuration: TimeInterval(useconds_t(numOperations) * delayMicroseconds) / 1000000.0
            )
        )
    }

    func test__mutual_exclusivity_with_dependencies() {
        // The expected result is that procedure1 will run first and, once procedure1
        // has finished, procedure2 will run.
        //
        // Previously, this test resulted in neither procedure finishing (i.e. deadlock).

        // Two procedures that are mutually-exclusive
        let procedure1 = TestProcedure()
        procedure1.addCondition(MutuallyExclusive<TestProcedure>())
        let procedure2 = TestProcedure()
        procedure2.addCondition(MutuallyExclusive<TestProcedure>())

        addCompletionBlockTo(procedures: [procedure1, procedure2])

        // procedure2 will not run until procedure1 is complete
        procedure2.addDependency(procedure1)

        // add procedure2 to the queue first
        queue.addOperation(procedure2).then(on: DispatchQueue.main) { [weak weakQueue = self.queue] in
            guard let queue = weakQueue else { return }
            // then add procedure1 to the queue
            queue.addOperation(procedure1)
        }

        waitForExpectations(timeout: 2)

        XCTAssertTrue(procedure1.isFinished)
        XCTAssertTrue(procedure2.isFinished)
    }

    func test__mutual_exclusivity_when_initial_reference_to_queue_goes_away() {

        class DoesNotFinishByItselfProcedure: Procedure {
            override func execute() {
                // does not finish by itself - the test must call finish()
            }
        }

        weak var weakQueue: ProcedureQueue?
        let procedure1 = DoesNotFinishByItselfProcedure()

        let procedureFinishedGroup = DispatchGroup()
        procedureFinishedGroup.enter()
        procedure1.addDidFinishBlockObserver { _, _ in
            procedureFinishedGroup.leave()
        }

        procedure1.addWillFinishBlockObserver(synchronizedWith: DispatchQueue.main) { _, _, _ in
            guard let _ = weakQueue else {
                // Neither NSOperationInternal (nor Procedure) appears to be holding a strong
                // reference to the OperationQueue while the Operation is executing (i.e. prior to finish)
                //
                // The current mutual exclusivity implementation requires this,
                // so Procedure must hold onto its own strong reference.
                //
                XCTFail("ERROR: The Procedure is about to finish, but nothing has a strong reference to the ProcedureQueue it's executing \"on\". This needs to be resolved by modifying Procedure to maintain a strong reference to its queue through finish.")
                return
            }
        }

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        autoreleasepool {

            var queue: ProcedureQueue? = ProcedureQueue()

            procedure1.addCondition(MutuallyExclusive<TestProcedure>())

            let expProcedureWasStarted = expectation(description: "Procedure was started - execute was called")
            procedure1.addDidExecuteBlockObserver(synchronizedWith: DispatchQueue.main) { _ in
                // the Procedure has been started
                expProcedureWasStarted.fulfill()
            }

            queue!.addOperation(procedure1)
            waitForExpectations(timeout: 3) // wait for the Procedure to be started by the queue

            // store a weak reference to the ProcedureQueue
            weakQueue = queue

            // get rid of our strong reference to the ProcedureQueue
            queue = nil

        }
        #else
        var queue: ProcedureQueue? = ProcedureQueue()

        procedure1.addCondition(MutuallyExclusive<TestProcedure>())

        let expProcedureWasStarted = expectation(description: "Procedure was started - execute was called")
        procedure1.addDidExecuteBlockObserver(synchronizedWith: DispatchQueue.main) { _ in
            // the Procedure has been started
            expProcedureWasStarted.fulfill()
        }

        queue!.addOperation(procedure1)
        waitForExpectations(timeout: 3) // wait for the Procedure to be started by the queue

        // store a weak reference to the ProcedureQueue
        weakQueue = queue

        // get rid of our strong reference to the ProcedureQueue
        queue = nil
        #endif

        // verify that the weak reference to the ProcedureQueue still exists
        guard let _ = weakQueue else {
            // Neither NSOperationInternal (nor Procedure) appears to be holding a strong
            // reference to the OperationQueue while the Operation is executing (i.e. prior to finish)
            //
            // The current mutual exclusivity implementation requires this,
            // so Procedure must hold onto its own strong reference.
            //
            XCTFail("ERROR: The Procedure is still executing, but nothing has a strong reference to the ProcedureQueue it's executing \"on\". This needs to be resolved by modifying Procedure to maintain a strong reference to its queue through finish.")
            return
        }

        // then finish the testing procedure
        procedure1.finish()

        // and wait for it to finish
        let expProcedureDidFinish = expectation(description: "Procedure did finish")
        procedureFinishedGroup.notify(queue: DispatchQueue.main) {
            expProcedureDidFinish.fulfill()
        }
        waitForExpectations(timeout: 3)

        PKAssertProcedureFinished(procedure1)
    }
}
