//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
import XCTest

open class TestGroupProcedure: GroupProcedure {
    public var didExecute: Bool { return _didExecute.access }

    private var _didExecute = Protector(false)

    open override func execute() {
        _didExecute.overwrite(with: true)
        super.execute()
    }
}
