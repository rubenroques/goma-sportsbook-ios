import UIKit
import Combine

public class CashoutAmountView: UIView {
    
    // MARK: - Properties
    private let viewModel: CashoutAmountViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundSecondary
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Initialization
    public init(viewModel: CashoutAmountViewModelProtocol) {
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
        containerView.addSubview(titleLabel)
        containerView.addSubview(amountLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 35),
            
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Amount label constraints
            amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            amountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
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
    private func updateUI(with data: CashoutAmountData) {
        titleLabel.text = data.title
        amountLabel.text = "\(data.currency) \(data.amount)"
    }
}

// MARK: - SwiftUI Preview
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct CashoutAmountPreviewView: UIViewRepresentable {
    private let viewModel: CashoutAmountViewModelProtocol
    
    init(viewModel: CashoutAmountViewModelProtocol) {
        self.viewModel = viewModel
    }
    
    func makeUIView(context: Context) -> CashoutAmountView {
        let view = CashoutAmountView(viewModel: viewModel)
        return view
    }
    
    func updateUIView(_ uiView: CashoutAmountView, context: Context) {
        // Updates handled by Combine binding
    }
}

@available(iOS 13.0, *)
struct CashoutAmountView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Default state
            CashoutAmountPreviewView(
                viewModel: MockCashoutAmountViewModel.defaultMock()
            )
            .frame(height: 48)
            .padding()
            .background(Color.white.opacity(0.1))
            .previewDisplayName("Default State")
            
            // Different amount
            CashoutAmountPreviewView(
                viewModel: MockCashoutAmountViewModel.customMock(
                    title: "Full Cashout",
                    currency: "XAF",
                    amount: "150.00"
                )
            )
            .frame(height: 48)
            .padding()
            .background(Color.white.opacity(0.1))
            .previewDisplayName("Different Amount")
        }
    }
}
#endif
