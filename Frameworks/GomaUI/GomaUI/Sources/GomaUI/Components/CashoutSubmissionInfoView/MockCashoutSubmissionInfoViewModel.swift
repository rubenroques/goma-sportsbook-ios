import Foundation
import Combine

public class MockCashoutSubmissionInfoViewModel: CashoutSubmissionInfoViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject = CurrentValueSubject<CashoutSubmissionInfoData, Never>(CashoutSubmissionInfoData.empty)
    
    public var dataPublisher: AnyPublisher<CashoutSubmissionInfoData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public lazy var buttonViewModel: ButtonViewModelProtocol = {
        let viewModel = MockButtonViewModel(buttonData: ButtonData(id: "ok", title: "OK", style: .solidBackground, backgroundColor: .clear, disabledBackgroundColor: .clear))
        viewModel.onButtonTapped = { [weak self] in
            self?.handleButtonTap()
        }
        return viewModel
    }()
    
    // MARK: - Callbacks
    public var onButtonTap: (() -> Void)?
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Public Methods
    public func handleButtonTap() {
        print("Cashout submission info button tapped!")
        onButtonTap?()
    }
    
    public func setVisible(_ isVisible: Bool) {
        let currentData = dataSubject.value
        let updatedData = CashoutSubmissionInfoData(
            state: currentData.state,
            message: currentData.message,
            isVisible: isVisible
        )
        dataSubject.send(updatedData)
    }
    
    public func updateData(_ data: CashoutSubmissionInfoData) {
        dataSubject.send(data)
        
        // Update button based on state
        switch data.state {
        case .success:
            buttonViewModel.updateTitle("OK")
        case .error:
            buttonViewModel.updateTitle("Retry")
        }
        buttonViewModel.setEnabled(true)
    }
    
    // MARK: - Mock Factory Methods
    public static func successMock() -> MockCashoutSubmissionInfoViewModel {
        let viewModel = MockCashoutSubmissionInfoViewModel()
        let data = CashoutSubmissionInfoData(
            state: .success,
            message: "Cashout Successful"
        )
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func errorMock() -> MockCashoutSubmissionInfoViewModel {
        let viewModel = MockCashoutSubmissionInfoViewModel()
        let data = CashoutSubmissionInfoData(
            state: .error,
            message: "Cashout Failed"
        )
        viewModel.updateData(data)
        return viewModel
    }
    
    public static func customMock(
        state: CashoutSubmissionState,
        message: String,
        isVisible: Bool = true
    ) -> MockCashoutSubmissionInfoViewModel {
        let viewModel = MockCashoutSubmissionInfoViewModel()
        let data = CashoutSubmissionInfoData(
            state: state,
            message: message,
            isVisible: isVisible
        )
        viewModel.updateData(data)
        return viewModel
    }
}

// MARK: - Extensions
extension CashoutSubmissionInfoData {
    static var empty: CashoutSubmissionInfoData {
        CashoutSubmissionInfoData(
            state: .success,
            message: "",
            isVisible: false
        )
    }
}
