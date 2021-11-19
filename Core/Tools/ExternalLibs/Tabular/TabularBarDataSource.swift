
public protocol TabularBarDataSource: AnyObject {
    func numberOfButtons() -> Int
    func titleForButton(atIndex index: Int) -> String
}
