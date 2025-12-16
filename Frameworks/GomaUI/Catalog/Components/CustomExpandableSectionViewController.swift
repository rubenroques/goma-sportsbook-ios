import UIKit
import GomaUI

final class CustomExpandableSectionViewController: UIViewController {
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        setupLayout()
        buildSections()
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }
    
    private func buildSections() {
        let titleLabel = UILabel()
        titleLabel.text = "CustomExpandableSectionView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 22)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "A customizable expandable section with optional leading icons and configurable expand/collapse icons."
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        descriptionLabel.textColor = StyleProvider.Color.textSecondary
        descriptionLabel.numberOfLines = 0
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(descriptionLabel)
        
        let sections: [(MockCustomExpandableSectionViewModel, [String])] = [
            (
                MockCustomExpandableSectionViewModel.custom(
                    title: "Personal Information",
                    icon: "person.crop.square",
                    collapsedIcon: "chevron.down",
                    expandedIcon: "chevron.up",
                    isExpanded: false
                ),
                [
                    "Review your profile, phone number, address and contact preferences.",
                    "Update individual fields or tap edit to modify all details."
                ]
            ),
            (
                MockCustomExpandableSectionViewModel.custom(
                    title: "Notifications",
                    icon: "bell.badge.fill",
                    collapsedIcon: "bell",
                    expandedIcon: "bell.fill",
                    isExpanded: true
                ),
                [
                    "Enable push notifications for odds boosts and cashout reminders.",
                    "Customize frequency per sport or tournament."
                ]
            ),
            (
                MockCustomExpandableSectionViewModel.custom(
                    title: "Payment Methods",
                    icon: "creditcard.fill",
                    collapsedIcon: "chevron.compact.down",
                    expandedIcon: "chevron.compact.up",
                    isExpanded: false
                ),
                [
                    "Store multiple debit cards and e-wallets securely.",
                    "Assign a default payment method for one-tap deposits."
                ]
            )
        ]
        
        for (model, lines) in sections {
            let sectionView = CustomExpandableSectionView(viewModel: model)
            sectionView.translatesAutoresizingMaskIntoConstraints = false
            lines.forEach { text in
                let label = UILabel()
                label.text = text
                label.font = StyleProvider.fontWith(type: .regular, size: 13)
                label.textColor = StyleProvider.Color.textSecondary
                label.numberOfLines = 0
                sectionView.contentContainer.addArrangedSubview(label)
            }
            contentStack.addArrangedSubview(sectionView)
        }
    }
}



