//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

// MARK: - EventConcurrencyTrackingRegistrar

// Tracks Procedure Events and the Threads on which they occur.
// Detects concurrency issues if two events occur concurrently on two different threads.
// Use a unique EventConcurrencyTrackingRegistrar per Procedure instance.
public class EventConcurrencyTrackingRegistrar {
    public enum ProcedureEvent: Equatable, CustomStringConvertible {

        case do_Execute

        case observer_didAttach
        case observer_willExecute
        case observer_didExecute
        case observer_willCancel
        case observer_didCancel
        case observer_procedureWillAdd(String)
        case observer_procedureDidAdd(String)
        case observer_willFinish
        case observer_didFinish

        case override_procedureWillCancel
        case override_procedureDidCancel
        case override_procedureWillFinish
        case override_procedureDidFinish

        // GroupProcedure open functions
        case override_groupWillAdd_child(String)
        case override_child_willFinishWithErrors(String)

        // GroupProcedure handlers
        case group_transformChildErrorsBlock(String)

        public var description: String {
            switch self {
            case .do_Execute: return "execute()"
            case .observer_didAttach: return "observer_didAttach"
            case .observer_willExecute: return "observer_willExecute"
            case .observer_didExecute: return "observer_didExecute"
            case .observer_willCancel: return "observer_willCancel"
            case .observer_didCancel: return "observer_didCancel"
            case .observer_procedureWillAdd(let name): return "observer_procedureWillAdd [\(name)]"
            case .observer_procedureDidAdd(let name): return "observer_procedureDidAdd [\(name)]"
            case .observer_willFinish: return "observer_willFinish"
            case .observer_didFinish: return "observer_didFinish"
            case .override_procedureWillCancel: return "procedureWillCancel()"
            case .override_procedureDidCancel: return "procedureDidCancel()"
            case .override_procedureWillFinish: return "procedureWillFinish()"
            case .override_procedureDidFinish: return "procedureDidFinish()"
            // GroupProcedure open functions
            case .override_groupWillAdd_child(let child): return "groupWillAdd(child:) [\(child)]"
            case .override_child_willFinishWithErrors(let child): return "child(_:willFinishWithErrors:) [\(child)]"
            case .group_transformChildErrorsBlock(let child): return "group.transformChildErrorsBlock [\(child)]"
            }
        }
    }

    public struct DetectedConcurrentEventSet: CustomStringConvertible {
        private var array: [DetectedConcurrentEvent] = []

        public var description: String {
            var description: String = ""
            for concurrentEvent in array {
                guard !description.isEmpty else {
                    description.append("\(concurrentEvent)")
                    continue
                }
                description.append("\n\(concurrentEvent)")
            }
            return description
        }

        public var isEmpty: Bool {
            return array.isEmpty
        }

        public mutating func append(_ newElement: DetectedConcurrentEvent) {
            array.append(newElement)
        }
    }

    public struct DetectedConcurrentEvent: CustomStringConvertible {
        var newEvent: (event: ProcedureEvent, threadUUID: String)
        var currentEvents: [UUID: (event: ProcedureEvent, threadUUID: String)]

        private func truncateThreadID(_ uuidString: String) -> String {
            //let uuidString = threadUUID.uuidString
            return String(uuidString[..<uuidString.index(uuidString.startIndex, offsetBy: 4)])
        }

        public var description: String {
            var description = "+ \(newEvent.event) (t: \(truncateThreadID(newEvent.threadUUID))) while: " /*+
             "while: \n"*/
            for (_, event) in currentEvents {
                description.append("\n\t- \(event.event) (t: \(truncateThreadID(event.threadUUID)))")
            }
            return description
        }
    }

    private struct State {
        // the current eventCallbacks
        var eventCallbacks: [UUID: (event: ProcedureEvent, threadUUID: String)] = [:]

        // maximum simultaneous eventCallbacks detected
        var maximumDetected: Int = 0

        // a list of detected concurrent events
        var detectedConcurrentEvents = DetectedConcurrentEventSet()

        // a history of all detected events (optional)
        var eventHistory: [ProcedureEvent] = []
    }

    private let state = Protector(State())

    public var maximumDetected: Int { return state.read { $0.maximumDetected } }
    public var detectedConcurrentEvents: DetectedConcurrentEventSet { return state.read { $0.detectedConcurrentEvents } }
    public var eventHistory: [ProcedureEvent]? { return (recordHistory) ? state.read { $0.eventHistory } : nil }

    private let recordHistory: Bool

    public init(recordHistory: Bool = false) {
        self.recordHistory = recordHistory
    }

    private let kThreadUUID: NSString = "run.kit.procedure.ProcedureKit.Testing.ThreadUUID"
    private func registerRunning(_ event: ProcedureEvent) -> UUID {
        // get current thread data
        let currentThread = Thread.current
        func getThreadUUID(_ thread: Thread) -> String {
            guard !thread.isMainThread else {
                return "main"
            }
            if let currentThreadUUID = currentThread.threadDictionary.object(forKey: kThreadUUID) as? UUID {
                return currentThreadUUID.uuidString
            }
            else {
                let newUUID = UUID()
                currentThread.threadDictionary.setObject(newUUID, forKey: kThreadUUID)
                return newUUID.uuidString
            }
        }

        let currentThreadUUID = getThreadUUID(currentThread)
        return state.write { ward -> UUID in
            var newUUID = UUID()
            while ward.eventCallbacks.keys.contains(newUUID) {
                newUUID = UUID()
            }
            if ward.eventCallbacks.count >= 1 {
                // determine if all existing event callbacks are on the same thread
                // as the new event callback
                if !ward.eventCallbacks.filter({ $0.1.threadUUID != currentThreadUUID }).isEmpty {
                    ward.detectedConcurrentEvents.append(DetectedConcurrentEvent(newEvent: (event: event, threadUUID: currentThreadUUID), currentEvents: ward.eventCallbacks))
                }
            }
            ward.eventCallbacks.updateValue((event, currentThreadUUID), forKey: newUUID)
            ward.maximumDetected = max(ward.eventCallbacks.count, ward.maximumDetected)
            if recordHistory {
                ward.eventHistory.append(event)
            }
            return newUUID
        }
    }

    private func deregisterRunning(_ uuid: UUID) {
        state.write { ward -> Bool in
            return ward.eventCallbacks.removeValue(forKey: uuid) != nil
        }
    }

    public func doRun(_ callback: ProcedureEvent, withDelay delay: TimeInterval = 0.0001, block: (ProcedureEvent) -> Void = { _ in }) {
        let id = registerRunning(callback)
        if delay > 0 {
            usleep(UInt32(delay * TimeInterval(1000000)))
        }
        block(callback)
        deregisterRunning(id)
    }
}
