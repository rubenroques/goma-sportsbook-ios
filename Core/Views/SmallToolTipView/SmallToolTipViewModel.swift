import Foundation

class SmallToolTipViewModel: ObservableObject {

        // MARK: - SwiftUI Implementation
    enum ToolTipType {
        case info
        case error
        case warning
        case success
    }

    @Published var text: String
    @Published var type: ToolTipType
    
    var onTap: () -> Void

    init(text: String, type: ToolTipType = .info, onTap: @escaping () -> Void = {}) {
        self.text = text
        self.type = type
        self.onTap = onTap
    }
}
