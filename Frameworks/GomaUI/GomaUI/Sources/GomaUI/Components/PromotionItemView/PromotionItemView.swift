import UIKit
import Combine
import SwiftUI


final public class PromotionItemView: UIView {
    // MARK: - Private Properties
    private let containerView = UIView()
    private let titleLabel = UILabel()
    
    private var cancellables = Set<AnyCancellable>()
    public let viewModel: PromotionItemViewModelProtocol
    
    // MARK: - Public Properties
    public var onPromotionSelected: (() -> Void) = { }
    
    // MARK: - Constants
    private enum Constants {
        static let minHeight: CGFloat = 40.0
        static let horizontalPadding: CGFloat = 16.0
        static let verticalPadding: CGFloat = 10.0
        static let cornerRadius: CGFloat = 20.0
    }
    
    // MARK: - Initialization
    public init(viewModel: PromotionItemViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = Constants.cornerRadius
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        setupConstraints()
        setupWithTheme()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minHeight),
            
            // Title label
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.horizontalPadding),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.verticalPadding),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.verticalPadding)
        ])
    }
    
    private func setupWithTheme() {
        containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
        
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.font = StyleProvider.fontWith(type: .medium, size: 14)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
    }
    
    private func setupBindings() {
        // Bind title
        viewModel.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleLabel.text = title
            }
            .store(in: &cancellables)
        
        // Bind selection state
        viewModel.isSelectedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSelected in
                self?.updateSelectionState(isSelected)
            }
            .store(in: &cancellables)
        
        // Bind category (if needed for future use)
        viewModel.categoryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                // Category can be used for additional styling or accessibility
                self?.accessibilityLabel = category.map { "\(self?.titleLabel.text ?? ""), \($0)" }
            }
            .store(in: &cancellables)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPromotion))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    // MARK: - Actions
    @objc private func didTapPromotion() {
        viewModel.selectPromotion()
        onPromotionSelected()
    }
    
    // MARK: - Private Methods
    private func updateSelectionState(_ isSelected: Bool) {
        UIView.animate(withDuration: 0.2) {
            if isSelected {
                self.containerView.backgroundColor = StyleProvider.Color.highlightPrimary
                self.titleLabel.textColor = .white
            } else {
                self.containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
                self.titleLabel.textColor = StyleProvider.Color.textPrimary
            }
        }
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
@available(iOS 17.0, *)
#Preview("Component States") {
    PreviewUIViewController {
        let vc = UIViewController()
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .fill
        
        vc.view.addSubview(stackView)
        
        // Selected state
        let selectedData = PromotionItemData(id: "1", title: "Welcome", isSelected: true)
        let selectedViewModel = MockPromotionItemViewModel(promotionItemData: selectedData)
        let selectedView = PromotionItemView(viewModel: selectedViewModel)
        stackView.addArrangedSubview(selectedView)
        
        // Unselected state
        let unselectedData = PromotionItemData(id: "2", title: LocalizationProvider.string("sports"), isSelected: false)
        let unselectedViewModel = MockPromotionItemViewModel(promotionItemData: unselectedData)
        let unselectedView = PromotionItemView(viewModel: unselectedViewModel)
        stackView.addArrangedSubview(unselectedView)
        
        // Long title
        let longTitleData = PromotionItemData(id: "3", title: "Casino Games", isSelected: false)
        let longTitleViewModel = MockPromotionItemViewModel(promotionItemData: longTitleData)
        let longTitleView = PromotionItemView(viewModel: longTitleViewModel)
        stackView.addArrangedSubview(longTitleView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: vc.view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: vc.view.trailingAnchor, constant: -20)
        ])
        
        vc.view.backgroundColor = .systemBackground
        return vc
    }
}
#endif
