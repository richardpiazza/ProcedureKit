//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import TestingProcedureKit
@testable import ProcedureKit
import Dispatch

class DispatchQoSClassTests: XCTestCase {

    static var allTests = [
        ("test_dispatchqos_qosclass_comparable", test_dispatchqos_qosclass_comparable),
    ]
    
    private let dispatchQosClassOrder: [DispatchQoS.QoSClass] = [.unspecified, .background, .utility, .default, .userInitiated, .userInteractive]
    
    func test_dispatchqos_qosclass_comparable() {
        for (i, currentQoSClass) in dispatchQosClassOrder.enumerated() {
            if i > 0 {
                let qosClassesLessThanCurrent = dispatchQosClassOrder.prefix(i)
                for qosClass in qosClassesLessThanCurrent {
                    XCTAssertLessThan(qosClass, currentQoSClass)
                }
            }
            XCTAssertEqual(currentQoSClass, currentQoSClass)
            if i < dispatchQosClassOrder.count - 1 {
                let qosClassesGreaterThanCurrent = dispatchQosClassOrder.suffix(dispatchQosClassOrder.count - i - 1)
                for qosClass in qosClassesGreaterThanCurrent {
                    XCTAssertGreaterThan(qosClass, currentQoSClass)
                }
            }
        }
    }
}
