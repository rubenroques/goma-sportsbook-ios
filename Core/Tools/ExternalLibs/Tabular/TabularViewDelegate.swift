
import UIKit

public protocol TabularViewDelegate {
    func didScroll(toIndex index: Int)
    func didScroll(toViewController viewController: UIViewController)

    func didScrollOverEdgeLeft()
    func didScrollOverEdgeRight()
}
