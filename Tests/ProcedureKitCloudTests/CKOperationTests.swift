//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKit
import TestingProcedureKit
@testable import ProcedureKitCloud
#if canImport(CloudKit)
import CloudKit

class TestCKOperation: Operation, CKOperationProtocol {

    typealias ServerChangeToken = String
    typealias RecordZone = String
    typealias RecordZoneID = String
    typealias Notification = String
    typealias NotificationID = String
    typealias Record = String
    typealias RecordID = String
    typealias Subscription = String
    typealias RecordSavePolicy = Int
    typealias DiscoveredUserInfo = String
    typealias Query = String
    typealias QueryCursor = String

    typealias UserIdentity = String
    typealias UserIdentityLookupInfo = String
    typealias Share = String
    typealias ShareMetadata = String
    typealias ShareParticipant = String

    var container: String? // just a test
    var allowsCellularAccess: Bool = true

    var operationID: String = ""
    var isLongLived: Bool = false

    var longLivedOperationWasPersistedBlock: () -> Void = { }

    var timeoutIntervalForRequest: TimeInterval = 0
    var timeoutIntervalForResource: TimeInterval = 0
}

class CKOperationTests: CKProcedureTestCase {

    var target: TestCKOperation!
    var operation: CKProcedure<TestCKOperation>!

    override func setUp() {
        super.setUp()
        target = TestCKOperation()
        operation = CKProcedure(operation: target)
    }

    override func tearDown() {
        target = nil
        operation = nil
        super.tearDown()
    }

    func test__set_get__container() {
        let container = "I'm a cloud kit container"
        operation.container = container
        XCTAssertEqual(operation.container, container)
        XCTAssertEqual(target.container, container)
    }

    func test__set_get__allowsCellularAccess() {
        let allowsCellularAccess = true
        operation.allowsCellularAccess = allowsCellularAccess
        XCTAssertEqual(operation.allowsCellularAccess, allowsCellularAccess)
        XCTAssertEqual(target.allowsCellularAccess, allowsCellularAccess)
    }

    func test__get_operationID() {
        let operationID = "test operationID"
        target.operationID = operationID
        XCTAssertEqual(operation.operationID, operationID)
    }

    func test__set_get__longLived() {
        let longLived = true
        operation.isLongLived = longLived
        XCTAssertEqual(operation.isLongLived, longLived)
        XCTAssertEqual(target.isLongLived, longLived)
    }

    func test__set_get__longLivedOperationWasPersistedBlock() {
        var setByBlock = false
        let block: () -> Void = { setByBlock = true }
        operation.longLivedOperationWasPersistedBlock = block
        operation.longLivedOperationWasPersistedBlock()
        XCTAssertTrue(setByBlock)
    }

    func test__set_get__timeoutIntervalForRequest() {
        let timeout: TimeInterval = 42
        operation.timeoutIntervalForRequest = timeout
        XCTAssertEqual(operation.timeoutIntervalForRequest, timeout)
        XCTAssertEqual(target.timeoutIntervalForRequest, timeout)
    }

    func test__set_get__timeoutIntervalForResource() {
        let timeout: TimeInterval = 42
        operation.timeoutIntervalForResource = timeout
        XCTAssertEqual(operation.timeoutIntervalForResource, timeout)
        XCTAssertEqual(target.timeoutIntervalForResource, timeout)
    }
}

#endif
