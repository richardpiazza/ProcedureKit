//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import XCTest
import ProcedureKit
import TestingProcedureKit
@testable import ProcedureKitCoreData
#if canImport(CoreData)
import CoreData

final class MakeFetchedResultsControllerProcedureTests: ProcedureKitCoreDataTestCase {

    func test__make_frc() {

        let makeFRC = MakeFetchedResultControllerProcedure<TestEntity>().injectResult(from: coreDataStack)

        wait(for: coreDataStack, makeFRC)

        PKAssertProcedureFinished(makeFRC)

        guard let _ = makeFRC.output.success else {
            XCTFail("Did not make FRC")
            return
        }
    }
}

#endif
