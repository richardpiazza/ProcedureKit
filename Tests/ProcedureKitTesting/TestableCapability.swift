//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

public class TestableCapability: CapabilityProtocol {

    public enum Status: AuthorizationStatus {
        public enum Requirement { // swiftlint:disable:this nesting
            case minimum, maximum
        }

        case unknown, restricted, denied, minimumAuthorized, maximumAuthorized

        public func meets(requirement: Requirement?) -> Bool {
            switch (requirement, self) {
            case (.some(.minimum), .minimumAuthorized), (_, .maximumAuthorized):
                return true
            default: return false
            }
        }
    }

    public var requirement: Status.Requirement? = .minimum
    public var isAsynchronous = false
    public var serviceIsAvailable = true
    public var didCheckIsAvailable = false
    public var serviceAuthorizationStatus: Status = .unknown
    public var didCheckAuthorizationStatus = false
    public var responseAuthorizationStatus: Status = .maximumAuthorized
    public var didRequestAuthorization = false

    public func isAvailable() -> Bool {
        didCheckIsAvailable = true
        return serviceIsAvailable
    }

    public func getAuthorizationStatus(_ completion: @escaping (Status) -> Void) {
        didCheckAuthorizationStatus = true
        if isAsynchronous {
            DispatchQueue.initiated.async {
                completion(self.serviceAuthorizationStatus)
            }
        }
        else {
            completion(serviceAuthorizationStatus)
        }
    }

    public func requestAuthorization(withCompletion completion: @escaping () -> Void) {
        didRequestAuthorization = true
        serviceAuthorizationStatus = responseAuthorizationStatus
        if isAsynchronous {
            DispatchQueue.initiated.async(execute: completion)
        }
        else {
            completion()
        }
    }
}
