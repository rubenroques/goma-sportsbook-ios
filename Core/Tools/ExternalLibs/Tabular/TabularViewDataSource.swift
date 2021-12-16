import UIKit

public protocol TabularViewDataSource: TabularBarDataSource {
    func defaultPage() -> Int
    func contentViewControllers() -> [UIViewController]
}
