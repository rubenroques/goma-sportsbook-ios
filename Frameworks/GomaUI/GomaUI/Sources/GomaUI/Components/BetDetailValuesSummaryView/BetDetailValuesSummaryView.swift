import UIKit
import Combine

public class BetDetailValuesSummaryView: UIView {
    
    // MARK: - Properties
    private let viewModel: BetDetailValuesSummaryViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let rowsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.distribution = .equalSpacing
        stackView.layer.cornerRadius = 8
        stackView.clipsToBounds = true
        return stackView
    }()
    
    // MARK: - Initialization
    public init(viewModel: BetDetailValuesSummaryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(rowsStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Rows stack view constraints
            rowsStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            rowsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            rowsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            rowsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    private func bindViewModel() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.updateUI(with: data)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Updates
    private func updateUI(with data: BetDetailValuesSummaryData) {
        // Remove existing row views
        rowsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new row views
        for (index, rowData) in data.rows.enumerated() {
            let rowViewModel = MockBetDetailRowViewModel()
            rowViewModel.updateData(rowData)
            
            // Determine corner style based on position
            let cornerStyle: BetDetailRowCornerStyle
            cornerStyle = .none
            
            let rowView = BetDetailRowView(viewModel: rowViewModel, cornerStyle: cornerStyle)
            rowsStackView.addArrangedSubview(rowView)
        }
    }
}

// MARK: - SwiftUI Preview
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct BetDetailValuesSummaryPreviewView: UIViewRepresentable {
    private let viewModel: BetDetailValuesSummaryViewModelProtocol
    
    init(viewModel: BetDetailValuesSummaryViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    func makeUIView(context: Context) -> BetDetailValuesSummaryView {
        let view = BetDetailValuesSummaryView(viewModel: viewModel)
        return view
    }
    
    func updateUIView(_ uiView: BetDetailValuesSummaryView, context: Context) {
        // Updates handled by Combine binding
    }
}

@available(iOS 13.0, *)
struct BetDetailValuesSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Default state with multiple rows
            BetDetailValuesSummaryPreviewView(
                viewModel: MockBetDetailValuesSummaryViewModel.defaultMock()
            )
            .frame(height: 330)
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("Default State")
            
            // Single row
            BetDetailValuesSummaryPreviewView(
                viewModel: MockBetDetailValuesSummaryViewModel.singleRowMock()
            )
            .frame(height: 66)
            .padding()
            .background(Color.gray.opacity(0.1))
            .previewDisplayName("Single Row")
        }
    }
}
#endif
