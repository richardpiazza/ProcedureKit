//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation

open class AsyncTestCondition: Condition {

    public typealias EvaluateBlock = (@escaping (ConditionResult) -> Void) -> Void
    let evaluate: EvaluateBlock

    public init(name: String = "TestCondition", producedDependencies: [Operation] = [], evaluate: @escaping EvaluateBlock) {
        self.evaluate = evaluate
        super.init()
        self.name = name
        producedDependencies.forEach(produceDependency)
    }

    open override func evaluate(procedure: Procedure, completion: @escaping (ConditionResult) -> Void) {
        evaluate(completion)
    }
}
