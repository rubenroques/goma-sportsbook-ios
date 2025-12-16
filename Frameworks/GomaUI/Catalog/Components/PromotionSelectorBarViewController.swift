import UIKit
import GomaUI

class PromotionSelectorBarViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var selectorBars: [PromotionSelectorBarView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "PromotionSelectorBarView Demo"
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupDemoSelectorBars()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupDemoSelectorBars() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 40
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        // Demo 1: Basic selector bar
        setupBasicSelectorBar(stackView: stackView)
        
        // Demo 2: Extended selector bar (scrollable)
        setupExtendedSelectorBar(stackView: stackView)
        
        // Demo 3: Read-only selector bar
        setupReadOnlySelectorBar(stackView: stackView)
    }
    
    private func setupBasicSelectorBar(stackView: UIStackView) {
        let titleLabel = UILabel()
        titleLabel.text = "Basic Selector Bar"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        
        let items = [
            PromotionItemData(id: "1", title: "Welcome", isSelected: true),
            PromotionItemData(id: "2", title: "Sports", isSelected: false),
            PromotionItemData(id: "3", title: "Casino", isSelected: false),
            PromotionItemData(id: "4", title: "Bonuses", isSelected: false)
        ]
        
        let barData = PromotionSelectorBarData(
            id: "basic",
            promotionItems: items,
            selectedPromotionId: "1"
        )
        
        let viewModel = MockPromotionSelectorBarViewModel(barData: barData)
        let selectorBar = PromotionSelectorBarView(viewModel: viewModel)
        
        selectorBar.onPromotionSelected = { [weak self] selectedId in
            self?.handlePromotionSelection(selectedId, context: "Basic")
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(selectorBar)
        selectorBars.append(selectorBar)
    }
    
    private func setupExtendedSelectorBar(stackView: UIStackView) {
        let titleLabel = UILabel()
        titleLabel.text = "Extended Selector Bar (Scrollable)"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        
        let items = [
            PromotionItemData(id: "1", title: "Welcome", isSelected: true),
            PromotionItemData(id: "2", title: "Sports", isSelected: false),
            PromotionItemData(id: "3", title: "Casino", isSelected: false),
            PromotionItemData(id: "4", title: "Bonuses", isSelected: false),
            PromotionItemData(id: "5", title: "Live Casino", isSelected: false),
            PromotionItemData(id: "6", title: "Virtual Sports", isSelected: false),
            PromotionItemData(id: "7", title: "Esports", isSelected: false),
            PromotionItemData(id: "8", title: "Promotions", isSelected: false)
        ]
        
        let barData = PromotionSelectorBarData(
            id: "extended",
            promotionItems: items,
            selectedPromotionId: "1"
        )
        
        let viewModel = MockPromotionSelectorBarViewModel(barData: barData)
        let selectorBar = PromotionSelectorBarView(viewModel: viewModel)
        
        selectorBar.onPromotionSelected = { [weak self] selectedId in
            self?.handlePromotionSelection(selectedId, context: "Extended")
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(selectorBar)
        selectorBars.append(selectorBar)
    }
    
    private func setupReadOnlySelectorBar(stackView: UIStackView) {
        let titleLabel = UILabel()
        titleLabel.text = "Read-Only Selector Bar"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        
        let items = [
            PromotionItemData(id: "1", title: "Welcome", isSelected: true),
            PromotionItemData(id: "2", title: "Sports", isSelected: false),
            PromotionItemData(id: "3", title: "Casino", isSelected: false),
            PromotionItemData(id: "4", title: "Bonuses", isSelected: false)
        ]
        
        let barData = PromotionSelectorBarData(
            id: "readonly",
            promotionItems: items,
            selectedPromotionId: "1",
            allowsVisualStateChanges: false
        )
        
        let viewModel = MockPromotionSelectorBarViewModel(barData: barData)
        let selectorBar = PromotionSelectorBarView(viewModel: viewModel)
        
        selectorBar.onPromotionSelected = { [weak self] selectedId in
            self?.handlePromotionSelection(selectedId, context: "Read-Only")
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(selectorBar)
        selectorBars.append(selectorBar)
    }
    
    private func handlePromotionSelection(_ selectedId: String, context: String) {
        let alert = UIAlertController(
            title: "Selection Event",
            message: "Selected: \(selectedId) in \(context) selector bar",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
