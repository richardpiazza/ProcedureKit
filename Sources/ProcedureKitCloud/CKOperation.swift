//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
#if canImport(CloudKit)
import CloudKit

/**
 A generic protocol which exposes the types and properties used by
 Apple's CloudKit Operation types.
 */
public protocol CKOperationProtocol: class {

    /// The type of the CloudKit Container
    associatedtype Container

    /// The type of the CloudKit ServerChangeToken
    associatedtype ServerChangeToken

    /// The type of the CloudKit Notification
    associatedtype Notification

    /// The type of the CloudKit RecordZone
    associatedtype RecordZone

    /// The type of the CloudKit Record
    associatedtype Record

    /// The type of the CloudKit Subscription
    associatedtype Subscription

    /// The type of the CloudKit RecordSavePolicy
    associatedtype RecordSavePolicy

    /// The type of the CloudKit Query
    associatedtype Query

    /// The type of the CloudKit QueryCursor
    associatedtype QueryCursor

    /// The type of the CloudKit RecordZoneID
    associatedtype RecordZoneID: Hashable

    /// The type of the CloudKit NotificationID
    associatedtype NotificationID: Hashable

    /// The type of the CloudKit RecordID
    associatedtype RecordID: Hashable

    /// The type of the CloudKit UserIdentity
    associatedtype UserIdentity

    /// The type of the CloudKit UserIdentityLookupInfo
    associatedtype UserIdentityLookupInfo

    /// The type of the CloudKit Share
    associatedtype Share

    /// The type of the CloudKit ShareMetadata
    associatedtype ShareMetadata

    /// The type of the CloudKit ShareParticipant
    associatedtype ShareParticipant

    /// The type of the longLivedOperationWasPersistedBlock property
    associatedtype LongLivedOperationWasPersistedBlockType

    /// - returns the CloudKit Container
    var container: Container? { get set }

    /// - returns whether to use cellular data access, if WiFi is unavailable (CKOperation default is true)
    var allowsCellularAccess: Bool { get set }

    /// - returns a unique identifier for a long-lived CKOperation
    var operationID: String { get }

    /// - returns whether the operation is long-lived
    var isLongLived: Bool { get set }

    /// - returns the block to execute when the server starts storing callbacks for this long-lived CKOperation
    var longLivedOperationWasPersistedBlock: LongLivedOperationWasPersistedBlockType { get set }

    /// If non-zero, overrides the timeout interval for any network requests issued by this operation.
    /// See NSURLSessionConfiguration.timeoutIntervalForRequest
    var timeoutIntervalForRequest: TimeInterval { get set }

    /// If non-zero, overrides the timeout interval for any network resources retrieved by this operation.
    /// See NSURLSessionConfiguration.timeoutIntervalForResource
    var timeoutIntervalForResource: TimeInterval { get set }
}

/// An extension to make CKOperation to conform to the CKOperationProtocol.
extension CKOperation: CKOperationProtocol {

    /// The Container is a CKContainer
    public typealias Container = CKContainer

    /// The ServerChangeToken is a CKServerChangeToken
    public typealias ServerChangeToken = CKServerChangeToken

    /// The RecordZone is a CKRecordZone
    public typealias RecordZone = CKRecordZone

    /// The RecordZoneID is a CKRecordZoneID
    public typealias RecordZoneID = CKRecordZone.ID

    /// The Notification is a CKNotification
    public typealias Notification = CKNotification

    /// The NotificationID is a CKNotificationID
    public typealias NotificationID = CKNotification.ID

    /// The Record is a CKRecord
    public typealias Record = CKRecord

    /// The RecordID is a CKRecordID
    public typealias RecordID = CKRecord.ID

    #if !os(watchOS)
    /// The Subscription is a CKSubscription
    public typealias Subscription = CKSubscription
    #else
    // CKSubscription is unsupported on watchOS
    public typealias Subscription = Void
    #endif

    /// The RecordSavePolicy is a CKRecordSavePolicy
    public typealias RecordSavePolicy = CKModifyRecordsOperation.RecordSavePolicy

    /// The Query is a CKQuery
    public typealias Query = CKQuery

    /// The QueryCursor is a CKQueryCursor
    public typealias QueryCursor = CKQueryOperation.Cursor

    /// The UserIdentity is a CKUserIdentity
    public typealias UserIdentity = CKUserIdentity

    /// The UserIdentityLookupInfo is a CKUserIdentityLookupInfo
    public typealias UserIdentityLookupInfo = CKUserIdentity.LookupInfo

    /// The Share is a CKShare
    public typealias Share = CKShare

    /// The ShareMetadata is a CKShareMetadata
    public typealias ShareMetadata = CKShare.Metadata

    /// The ShareParticipant is a CKShareParticipant
    public typealias ShareParticipant = CKShare.Participant

    public typealias LongLivedOperationWasPersistedBlockType = (() -> Void)?
}

extension CKProcedure {

    public var container: T.Container? {
        get { return operation.container }
        set { operation.container = newValue }
    }

    public var allowsCellularAccess: Bool {
        get { return operation.allowsCellularAccess }
        set { operation.allowsCellularAccess = newValue }
    }

    public var operationID: String {
        get { return operation.operationID }
    }

    public var isLongLived: Bool {
        get { return operation.isLongLived }
        set { operation.isLongLived = newValue }
    }

    public var longLivedOperationWasPersistedBlock: T.LongLivedOperationWasPersistedBlockType {
        get { return operation.longLivedOperationWasPersistedBlock }
        set { operation.longLivedOperationWasPersistedBlock = newValue }
    }

    public var timeoutIntervalForRequest: TimeInterval {
        get { return operation.timeoutIntervalForRequest }
        set { operation.timeoutIntervalForRequest = newValue }
    }

    public var timeoutIntervalForResource: TimeInterval {
        get { return operation.timeoutIntervalForResource }
        set { operation.timeoutIntervalForResource = newValue }
    }
}

extension CloudKitProcedure {

    /// - returns: the CloudKit container
    public var container: T.Container? {
        get { return current.container }
        set {
            current.container = newValue
            appendConfigureBlock { $0.container = newValue }
        }
    }

    /// - returns whether to use cellular data access, if WiFi is unavailable (CKOperation default is true)
    public var allowsCellularAccess: Bool {
        get { return current.allowsCellularAccess }
        set {
            current.allowsCellularAccess = newValue
            appendConfigureBlock { $0.allowsCellularAccess = newValue }
        }
    }

    /// - returns a unique identifier for a long-lived CKOperation
    public var operationID: String {
        get { return current.operationID }
    }

    /// - returns whether the operation is long-lived
    public var isLongLived: Bool {
        get { return current.isLongLived }
        set {
            current.isLongLived = newValue
            appendConfigureBlock { $0.isLongLived = newValue }
        }
    }

    /// - returns the block to execute when the server starts storing callbacks for this long-lived CKOperation
    public var longLivedOperationWasPersistedBlock: T.LongLivedOperationWasPersistedBlockType {
        get { return current.longLivedOperationWasPersistedBlock }
        set {
            current.longLivedOperationWasPersistedBlock = newValue
            appendConfigureBlock { $0.longLivedOperationWasPersistedBlock = newValue }
        }
    }

    /// If non-zero, overrides the timeout interval for any network requests issued by this operation.
    /// See NSURLSessionConfiguration.timeoutIntervalForRequest
    public var timeoutIntervalForRequest: TimeInterval {
        get { return current.timeoutIntervalForRequest }
        set {
            current.timeoutIntervalForRequest = newValue
            appendConfigureBlock { $0.timeoutIntervalForRequest = newValue }
        }
    }

    /// If non-zero, overrides the timeout interval for any network resources retrieved by this operation.
    /// See NSURLSessionConfiguration.timeoutIntervalForResource
    public var timeoutIntervalForResource: TimeInterval {
        get { return current.timeoutIntervalForResource }
        set {
            current.timeoutIntervalForResource = newValue
            appendConfigureBlock { $0.timeoutIntervalForResource = newValue }
        }
    }
}

#endif
