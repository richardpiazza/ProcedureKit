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

public class TestableURLSessionTaskFactory {

    public var delay: TimeInterval {
        get { return stateLock.withCriticalScope { _delay } }
        set {
            stateLock.withCriticalScope {
                _delay = newValue
            }
        }
    }
    public var returnedResponse: HTTPURLResponse? {
        get { return stateLock.withCriticalScope { _returnedResponse } }
        set {
            stateLock.withCriticalScope {
                _returnedResponse = newValue
            }
        }
    }
    public var returnedError: Error? {
        get { return stateLock.withCriticalScope { _returnedError } }
        set {
            stateLock.withCriticalScope {
                _returnedError = newValue
            }
        }
    }

    // Data
    public var didReceiveDataRequest: URLRequest? {
        get { return stateLock.withCriticalScope { _didReceiveDataRequest } }
        set {
            stateLock.withCriticalScope {
                _didReceiveDataRequest = newValue
            }
        }
    }
    public var didReturnDataTask: TestableURLSessionTask? {
        get { return stateLock.withCriticalScope { _didReturnDataTask } }
        set {
            stateLock.withCriticalScope {
                _didReturnDataTask = newValue
            }
        }
    }
    public var returnedData: Data? {
        get { return stateLock.withCriticalScope { _returnedData } }
        set {
            stateLock.withCriticalScope {
                _returnedData = newValue
            }
        }
    }

    // Download
    public var didReceiveDownloadRequest: URLRequest? {
        get { return stateLock.withCriticalScope { _didReceiveDownloadRequest } }
        set {
            stateLock.withCriticalScope {
                _didReceiveDownloadRequest = newValue
            }
        }
    }
    public var didReturnDownloadTask: TestableURLSessionTask? {
        get { return stateLock.withCriticalScope { _didReturnDownloadTask } }
        set {
            stateLock.withCriticalScope {
                _didReturnDownloadTask = newValue
            }
        }
    }
    public var returnedURL: URL? {
        get { return stateLock.withCriticalScope { _returnedURL } }
        set {
            stateLock.withCriticalScope {
                _returnedURL = newValue
            }
        }
    }

    // Upload
    public var didReceiveUploadRequest: URLRequest? {
        get { return stateLock.withCriticalScope { _didReceiveUploadRequest } }
        set {
            stateLock.withCriticalScope {
                _didReceiveUploadRequest = newValue
            }
        }
    }
    public var didReturnUploadTask: TestableURLSessionTask? {
        get { return stateLock.withCriticalScope { _didReturnUploadTask } }
        set {
            stateLock.withCriticalScope {
                _didReturnUploadTask = newValue
            }
        }
    }

    private var stateLock = NSLock()

    // Private (protected) Properties
    private var _delay: TimeInterval = 0
    private var _returnedResponse: HTTPURLResponse?
    private var _returnedError: Error?

    private var _didReceiveDataRequest: URLRequest?
    private var _didReturnDataTask: TestableURLSessionTask?
    private var _returnedData: Data? = "hello world".data(using: String.Encoding.utf8)

    private var _didReceiveDownloadRequest: URLRequest?
    private var _didReturnDownloadTask: TestableURLSessionTask?
    private var _returnedURL: URL? = URL(fileURLWithPath: "/var/tmp/hello/this/is/a/test/url")

    private var _didReceiveUploadRequest: URLRequest?
    private var _didReturnUploadTask: TestableURLSessionTask?

    // Initializers
    public init() {
        let url = URL(string: "https://www.google.com")!
        _returnedResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
    }

    public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> TestableURLSessionTask {
        didReceiveDataRequest = request
        let task = TestableURLSessionTask(delay: delay) { (task) in
            DispatchQueue.main.async {
                guard !task.didCancel else {
                    completionHandler(nil, nil, TestableURLSessionTaskFactory.cancelledError(forRequest: request))
                    return
                }
                completionHandler(self.returnedData, self.returnedResponse, self.returnedError)
            }
        }
        didReturnDataTask = task
        return task
    }

    public func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> TestableURLSessionTask {
        didReceiveDownloadRequest = request
        let task = TestableURLSessionTask(delay: delay) { (task) in
            DispatchQueue.main.async {
                guard !task.didCancel else {
                    completionHandler(nil, nil, TestableURLSessionTaskFactory.cancelledError(forRequest: request))
                    return
                }
                completionHandler(self.returnedURL, self.returnedResponse, self.returnedError)
            }
        }
        didReturnDownloadTask = task
        return task
    }

    public func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> TestableURLSessionTask {

        didReceiveUploadRequest = request
        let task = TestableURLSessionTask(delay: delay) { (task) in
            DispatchQueue.main.async {
                guard !task.didCancel else {
                    completionHandler(nil, nil, TestableURLSessionTaskFactory.cancelledError(forRequest: request))
                    return
                }
                completionHandler(self.returnedData, self.returnedResponse, self.returnedError)
            }
        }
        didReturnUploadTask = task
        return task
    }

    private static func cancelledError(forRequest request: URLRequest) -> Error {
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: "cancelled"]
        if let requestURL = request.url {
            userInfo[NSURLErrorFailingURLErrorKey] = requestURL
        }
        if let requestURLString = request.url?.absoluteString {
            userInfo[NSURLErrorFailingURLStringErrorKey] = requestURLString
        }
        return NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: userInfo)
    }
}
