
import UIKit
import GomaUI

class BonusCardViewController: UIViewController {
    
    // MARK: - Private Properties
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentView: UIView = Self.createContentView()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupWithTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupWithTheme()
    }
    
    // MARK: - Setup
    private func setupView() {
        self.setupSubviews()
        self.setupBonusCards()
    }
    
    private func setupWithTheme() {
        self.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        self.contentView.backgroundColor = .clear
    }
    
    private func setupBonusCards() {
        // Default mock with all features
        let defaultCard = BonusCardView(viewModel: MockBonusCardViewModel.defaultMock)
        defaultCard.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(defaultCard)
        
        // No URLs mock
        let noURLsCard = BonusCardView(viewModel: MockBonusCardViewModel.noURLsMock)
        noURLsCard.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(noURLsCard)
        
        // Casino bonus mock
        let casinoCard = BonusCardView(viewModel: MockBonusCardViewModel.casinoBonusMock)
        casinoCard.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(casinoCard)
        
        // Sports bonus mock
        let sportsCard = BonusCardView(viewModel: MockBonusCardViewModel.sportsBonusMock)
        sportsCard.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(sportsCard)
        
        // VIP bonus mock
        let vipCard = BonusCardView(viewModel: MockBonusCardViewModel.vipBonusMock)
        vipCard.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(vipCard)
        
        // No tag mock
        let noTagCard = BonusCardView(viewModel: MockBonusCardViewModel.noTagMock)
        noTagCard.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(noTagCard)
    }
}

// MARK: - Subviews Initialization and Setup
extension BonusCardViewController {
    
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
    private static func createContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        return stackView
    }
    
    private func setupSubviews() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)
        self.contentView.addSubview(self.stackView)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView
            self.contentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            self.contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.contentView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
            
            // StackView
            self.stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
            self.stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20)
        ])
    }
}

// MARK: - Preview Factory
extension BonusCardViewController {
    static func makePreview() -> BonusCardViewController {
        let vc = BonusCardViewController()
        return vc
    }
}

