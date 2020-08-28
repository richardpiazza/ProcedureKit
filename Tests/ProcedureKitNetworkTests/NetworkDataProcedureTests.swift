//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKit
import ProcedureKitTesting
@testable import ProcedureKitNetwork
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class NetworkDataProcedureTests: ProcedureKitTestCase {

    var url: URL!
    var request: URLRequest!
    var session: TestableURLSessionTaskFactory!
    var download: NetworkDataProcedure!

    override func setUp() {
        super.setUp()
        url = "http://procedure.kit.run"
        request = URLRequest(url: url)
        session = TestableURLSessionTaskFactory()
        download = NetworkDataProcedure(session: session, request: request)
    }

    override func tearDown() {
        url = nil
        request = nil
        session = nil
        download = nil
        super.tearDown()
    }

    func test__session_receives_request() {
        wait(for: download)
        PKAssertProcedureFinished(download)
        XCTAssertEqual(session.didReceiveDataRequest?.url, url)
    }

    func test__session_creates_data_task() {
        wait(for: download)
        PKAssertProcedureFinished(download)
        XCTAssertNotNil(session.didReturnDataTask)
        XCTAssertEqual(session.didReturnDataTask, download.task as? TestableURLSessionTask)
    }

    func test__download_resumes_data_task() {
        wait(for: download)
        PKAssertProcedureFinished(download)
        XCTAssertTrue(session.didReturnDataTask?.didResume ?? false)
    }

    // MARK: Cancellation

    func test__download_cancels_data_task_is_cancelled() {
        session.delay = 2.0
        let delay = DelayProcedure(by: 0.1)
        delay.addDidFinishBlockObserver { _, _ in
            self.download.cancel()
        }
        wait(for: download, delay)
        PKAssertProcedureCancelled(download)
        XCTAssertTrue(session.didReturnDataTask?.didCancel ?? false)
    }

    func test__download_cancelled_while_executing() {
        session.delay = 2.0
        download.addDidExecuteBlockObserver { (procedure) in
            procedure.cancel()
        }
        wait(for: download)
        PKAssertProcedureCancelled(download)
    }

    func test__download_cancelled_does_not_call_completion_handler() {
        session.delay = 2.0
        var calledCompletionHandler = false
        download = NetworkDataProcedure(session: session, request: request) { _ in
            DispatchQueue.onMain {
                calledCompletionHandler = true
            }
        }
        download.addDidExecuteBlockObserver { (procedure) in
            procedure.cancel()
        }
        wait(for: download)
        PKAssertProcedureCancelled(download)
        XCTAssertFalse(calledCompletionHandler)
    }

    // MARK: Finishing

    func test__no_requirement__finishes_with_error() {
        download = NetworkDataProcedure(session: session) { _ in }
        wait(for: download)
        PKAssertProcedureFinishedWithError(download, ProcedureKitError.requirementNotSatisfied())
    }

    func test__no_data__finishes_with_error() {
        session.returnedData = nil
        wait(for: download)
        PKAssertProcedureFinishedWithError(download, ProcedureKitError.unknown)
    }

    func test__session_error__finishes_with_error() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        session.returnedError = error
        wait(for: download)
        XCTAssertNotNil(download.error)
        PKAssertProcedureFinishedWithError(download, error)
    }

    func test__completion_handler_receives_data_and_response() {
        var completionHandlerDidExecute = false
        download = NetworkDataProcedure(session: session, request: request) { result in            
            XCTAssertEqual(result.value?.payload, self.session.returnedData)
            XCTAssertEqual(result.value?.response, self.session.returnedResponse)
            completionHandlerDidExecute = true
        }
        wait(for: download)
        PKAssertProcedureFinished(download)
        XCTAssertTrue(completionHandlerDidExecute)
    }
}
