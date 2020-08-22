//
//  ProcedureKit
//
//  Copyright © 2015-2020 ProcedureKit. All rights reserved.
//

import XCTest

import ProcedureKitTests
import ProcedureKitStressTests
import ProcedureKitCloudTests
import ProcedureKitCoreDataTests
import ProcedureKitLocationTests
import ProcedureKitMacTests
import ProcedureKitMobileTests
import ProcedureKitNetworkTests

var tests = [XCTestCaseEntry]()
tests += ProcedureKitTests.allTests()
XCTMain(tests)
