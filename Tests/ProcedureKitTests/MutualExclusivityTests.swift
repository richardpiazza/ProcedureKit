//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKitTesting
@testable import ProcedureKit

class MutualExclusiveTests: ProcedureKitTestCase {

    static var allTests = [
        ("test__mutual_exclusive_name", test__mutual_exclusive_name),
        ("test__mutual_exclusive_category", test__mutual_exclusive_category),
        ("test__alert_presentation_is_mutually_exclusive", test__alert_presentation_is_mutually_exclusive),
        ("test__alert_presentation_evaluation_satisfied", test__alert_presentation_evaluation_satisfied),
        ("test__mutually_exclusive_operations_can_be_executed", test__mutually_exclusive_operations_can_be_executed),
        ("test__procedure_mutual_exclusivity_internal_API_contract", test__procedure_mutual_exclusivity_internal_API_contract),
    ]
    
    func test__mutual_exclusive_name() {
        let condition = MutuallyExclusive<Procedure>()
        XCTAssertEqual(condition.name, "MutuallyExclusive<Procedure>")
    }

    func test__mutual_exclusive_category() {
        let condition = MutuallyExclusive<Procedure>(category: "testing")
        XCTAssertEqual(condition.mutuallyExclusiveCategories, ["testing"])
    }

    func test__alert_presentation_is_mutually_exclusive() {
        let condition = MutuallyExclusive<Procedure>()
        XCTAssertTrue(condition.isMutuallyExclusive)
    }

    func test__alert_presentation_evaluation_satisfied() {
        let condition = MutuallyExclusive<Procedure>()
        condition.evaluate(procedure: TestProcedure()) { result in
            switch result {
            case .success(true):
                return XCTAssertTrue(true)
            default:
                return XCTFail("Condition should evaluate true.")
            }
        }
    }

    func test__mutually_exclusive_operations_can_be_executed() {
        let procedure1 = TestProcedure()
        procedure1.name = "Procedure 1"
        procedure1.addCondition(MutuallyExclusive<TestProcedure>())

        let procedure2 = TestProcedure()
        procedure2.name = "Procedure 2"
        procedure2.addCondition(MutuallyExclusive<TestProcedure>())

        wait(for: procedure1, procedure2)
    }

    func test__procedure_mutual_exclusivity_internal_API_contract() {
        class CustomProcedureQueue: ProcedureQueue {
            typealias RequestLockObserver = (Set<String>) -> Void
            typealias ProcedureClaimLockObserver = (ExclusivityLockTicket) -> Void
            typealias UnlockObservers = (Set<String>) -> Void

            private let requestLockCallback: RequestLockObserver
            private let procedureClaimLockCallback: ProcedureClaimLockObserver
            private let unlockCallback: UnlockObservers

            init(requestLock: @escaping RequestLockObserver, procedureClaimLock: @escaping ProcedureClaimLockObserver, unlock: @escaping UnlockObservers) {
                requestLockCallback = requestLock
                procedureClaimLockCallback = procedureClaimLock
                unlockCallback = unlock
            }

            internal override func requestLock(for mutuallyExclusiveCategories: Set<String>, completion: @escaping (ExclusivityLockTicket) -> Void) {
                DispatchQueue.main.async {
                    self.requestLockCallback(mutuallyExclusiveCategories)
                    super.requestLock(for: mutuallyExclusiveCategories, completion: completion)
                }
            }

            internal override func procedureClaimLock(withTicket ticket: ExclusivityLockTicket, completion: @escaping () -> Void) {
                DispatchQueue.main.async {
                    self.procedureClaimLockCallback(ticket)
                    super.procedureClaimLock(withTicket: ticket, completion: completion)
                }
            }

            internal override func unlock(mutuallyExclusiveCategories categories: Set<String>) {
                DispatchQueue.main.async {
                    self.unlockCallback(categories)
                    super.unlock(mutuallyExclusiveCategories: categories)
                }
            }
        }

        struct DummyExclusivity { }

        let calledRequestLock = Protector(false)
        let calledProcedureClaimLock = Protector(false)
        let calledUnlock = Protector(false)

        let procedure = TestProcedure()
        let mutuallyExclusiveConditions = [MutuallyExclusive<TestProcedure>(), MutuallyExclusive<DummyExclusivity>()]
        let expectedMutuallyExclusiveCategories = Set(mutuallyExclusiveConditions.map { $0.mutuallyExclusiveCategories }.joined())
        print("\(expectedMutuallyExclusiveCategories)")
        mutuallyExclusiveConditions.forEach { procedure.addCondition($0) }

        procedure.addWillExecuteBlockObserver(synchronizedWith: DispatchQueue.main) { procedure, _ in
            // The Procedure should have called procedureClaimLock prior
            // to dispatching willExecute observers
            XCTAssertTrue(calledProcedureClaimLock.access)
        }

        let queue = CustomProcedureQueue(
            requestLock: { mutuallyExclusiveCategories in
                // Requesting the lock should occur *prior* to the Procedure being ready
                XCTAssertFalse(procedure.isReady)

                // And only once
                let previouslyCalledRequestLock = calledRequestLock.write({ (value) -> Bool in
                    let previousValue = value
                    value = true
                    return previousValue
                })
                XCTAssertFalse(previouslyCalledRequestLock)

                // And should contain the expected set of categories
                XCTAssertEqual(mutuallyExclusiveCategories, expectedMutuallyExclusiveCategories)
        },
            procedureClaimLock: { ticket in
                // Should be called *after* requestLock was called
                XCTAssertTrue(calledRequestLock.access)

                // Should only be called once for the Procedure
                let previouslyCalledProcedureClaimLock = calledProcedureClaimLock.write({ (value) -> Bool in
                    let previousValue = value
                    value = true
                    return previousValue
                })
                XCTAssertFalse(previouslyCalledProcedureClaimLock)

                // At the point the procedure claims the lock, it should no longer be pending
                // (i.e. it should have been started by the queue) but it also should not yet
                // be executing
                XCTAssertFalse(procedure.isPending)
                XCTAssertFalse(procedure.isExecuting)
                XCTAssertFalse(procedure.isFinished)

                // The ticket should contain the original categories
                XCTAssertEqual(ticket.mutuallyExclusiveCategories, expectedMutuallyExclusiveCategories)
        },
            unlock: { categories in
                // Should be called after the Procedure has finished
                XCTAssertTrue(procedure.isFinished)

                // And after the required prior calls to requestLock, procedureClaimLock
                XCTAssertTrue(calledRequestLock.access)
                XCTAssertTrue(calledProcedureClaimLock.access)

                // And only once
                let previouslyCalledUnlock = calledUnlock.write({ (value) -> Bool in
                    let previousValue = value
                    value = true
                    return previousValue
                })
                XCTAssertFalse(previouslyCalledUnlock)

                // Providing the original categories
                XCTAssertEqual(categories, expectedMutuallyExclusiveCategories)
        }
        )

        addCompletionBlockTo(procedure: procedure)
        queue.addOperation(procedure)
        waitForExpectations(timeout: 3)

        PKAssertProcedureFinished(procedure)
        XCTAssertTrue(calledRequestLock.access)
        XCTAssertTrue(calledProcedureClaimLock.access)
        XCTAssertTrue(calledUnlock.access)
    }
}
