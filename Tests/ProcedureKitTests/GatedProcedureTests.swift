//
//  ProcedureKit
//
//  Copyright © 2015-2020 ProcedureKit. All rights reserved.
//

import XCTest
import TestingProcedureKit
@testable import ProcedureKit

public class GatedProcedureTests: ProcedureKitTestCase {

    static var allTests = [
        ("test__when_gate_is_closed_procedure_is_cancelled", test__when_gate_is_closed_procedure_is_cancelled),
        ("test__when_gate_is_open_procedure_is_performed", test__when_gate_is_open_procedure_is_performed),
    ]
    
    func test__when_gate_is_closed_procedure_is_cancelled() {
        let gated = GatedProcedure(procedure) { false }
        wait(for: gated)
        PKAssertProcedureCancelled(gated)
    }

    func test__when_gate_is_open_procedure_is_performed() {
        let gated = GatedProcedure(procedure) { true }
        wait(for: gated)
        PKAssertProcedureFinished(gated)
        PKAssertProcedureFinished(procedure)
    }
}
