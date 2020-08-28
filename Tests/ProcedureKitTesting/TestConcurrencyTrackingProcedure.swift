//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

// MARK: - TestConcurrencyTrackingProcedure

open class TestConcurrencyTrackingProcedure: Procedure {
    private(set) weak var concurrencyRegistrar: ConcurrencyRegistrar?
    let microsecondsToSleep: useconds_t

    init(name: String = "TestConcurrencyTrackingProcedure", microsecondsToSleep: useconds_t, registrar: ConcurrencyRegistrar) {
        self.concurrencyRegistrar = registrar
        self.microsecondsToSleep = microsecondsToSleep
        super.init()
        self.name = name
    }
    override open func execute() {
        concurrencyRegistrar?.registerRunning(self)
        usleep(microsecondsToSleep)
        concurrencyRegistrar?.deregisterRunning(self)
        finish()
    }
}
