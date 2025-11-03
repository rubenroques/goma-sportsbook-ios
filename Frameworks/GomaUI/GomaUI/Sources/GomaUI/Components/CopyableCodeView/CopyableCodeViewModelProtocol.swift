import Foundation

/// Protocol defining the interface for copyable code view models
public protocol CopyableCodeViewModelProtocol {
    /// The code to display and copy
    var code: String { get }

    /// The label text shown above the code
    var label: String { get }

    /// The message shown after copying
    var copiedMessage: String { get }

    /// Called when the copy button is tapped
    func onCopyTapped()
}
