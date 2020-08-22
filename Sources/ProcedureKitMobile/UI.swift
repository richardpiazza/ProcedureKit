//
//  ProcedureKit
//
//  Copyright © 2015-2018 ProcedureKit. All rights reserved.
//

import ProcedureKit
import Foundation
#if canImport(UIKit) && !os(watchOS)
import UIKit

public protocol PresentingViewController: class {

    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)

    func show(_ viewControllerToShow: UIViewController, sender: Any?)

    func showDetailViewController(_ viewControllerToShow: UIViewController, sender: Any?)
}

extension UIViewController: PresentingViewController { }

public protocol DismissingViewController: class {
    var didDismissViewControllerBlock: () -> Void { get set }
}

public enum PresentationStyle {
    case show, showDetail, present
}

#endif
