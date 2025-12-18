import UIKit
import GomaUI

class PromotionItemViewController: UIViewController {
    
    private let stackView = UIStackView()
    private var promotionItemViews: [PromotionItemView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "PromotionItemView Demo"
        view.backgroundColor = .systemBackground
        
        setupStackView()
        setupDemoItems()
    }
    
    private func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fill
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupDemoItems() {
        let demoItems = [
            ("Welcome", true, "Welcome"),
            ("Sports", false, "Sports Betting"),
            ("Casino", false, "Casino Games"),
            ("Bonuses", false, "Promotional Offers")
        ]
        
        for (title, isSelected, category) in demoItems {
            let data = PromotionItemData(
                id: title.lowercased(),
                title: title,
                isSelected: isSelected,
                category: category
            )
            
            let viewModel = MockPromotionItemViewModel(promotionItemData: data)
            let promotionItemView = PromotionItemView(viewModel: viewModel)
            
            promotionItemView.onPromotionSelected = { [weak self] in
                self?.handlePromotionSelection(promotionItemView, title: title)
            }
            
            stackView.addArrangedSubview(promotionItemView)
            promotionItemViews.append(promotionItemView)
        }
    }
    
    private func handlePromotionSelection(_ selectedView: PromotionItemView, title: String) {
        // Show selection feedback
        let alert = UIAlertController(title: "Selection", message: "Selected: \(title)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
