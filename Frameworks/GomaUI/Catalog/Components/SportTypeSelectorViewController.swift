import UIKit
import GomaUI

class SportTypeSelectorViewController: UIViewController {
    
    private var stackView: UIStackView!
    private var selectedSportLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDemoSections()
    }
    
    private func setupUI() {
        title = "Sport Type Selector"
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        // Selected sport feedback label
        selectedSportLabel = UILabel()
        selectedSportLabel.text = "No sport selected"
        selectedSportLabel.font = StyleProvider.fontWith(type: .medium, size: 16)
        selectedSportLabel.textColor = StyleProvider.Color.textSecondary
        selectedSportLabel.textAlignment = .center
        selectedSportLabel.backgroundColor = StyleProvider.Color.backgroundSecondary
        selectedSportLabel.layer.cornerRadius = 8
        selectedSportLabel.clipsToBounds = true
        selectedSportLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    private func setupDemoSections() {
        addSectionHeader("Embedded Collection View")
        
        // Create embedded sport selector view
        let embeddedSelectorView = createEmbeddedSelector()
        embeddedSelectorView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        stackView.addArrangedSubview(embeddedSelectorView)
        
        stackView.addArrangedSubview(selectedSportLabel)
        
        addSectionHeader("Modal Presentation")
        
        let presentModalButton = createStyledButton(title: "Present Full Screen Selector")
        presentModalButton.addTarget(self, action: #selector(presentModalSelector), for: .touchUpInside)
        stackView.addArrangedSubview(presentModalButton)
        
        addSectionHeader("Features")
        addInfoLabel("✓ 2-column grid layout with 8pt spacing")
        addInfoLabel("✓ Reactive data updates via Combine")
        addInfoLabel("✓ Collection view cell wrapper for reuse")
        addInfoLabel("✓ Full-screen presentation controller")
        addInfoLabel("✓ Selection callbacks and delegation")
        addInfoLabel("✓ Modal presentation support")
        
        addSectionHeader("Architecture")
        addInfoLabel("• SportTypeSelectorView - Main collection view")
        addInfoLabel("• SportTypeSelectorCollectionViewCell - Cell wrapper")
        addInfoLabel("• SportTypeSelectorViewController - Presentation controller")
        addInfoLabel("• MVVM + Protocol-based design")
        addInfoLabel("• Uses SportTypeSelectorItemView for individual items")
    }
    
    private func createEmbeddedSelector() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
        containerView.layer.cornerRadius = 8
        
        let viewModel = MockSportTypeSelectorViewModel.defaultMock
        let selectorView = SportTypeSelectorView(viewModel: viewModel)
        selectorView.onSportSelected = { [weak self] sport in
            self?.handleSportSelection(sport)
        }
        
        containerView.addSubview(selectorView)
        selectorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            selectorView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            selectorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            selectorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            selectorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
        
        return containerView
    }
    
    private func createStyledButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = StyleProvider.Color.highlightPrimary
        button.setTitleColor(StyleProvider.Color.allWhite, for: .normal)
        button.titleLabel?.font = StyleProvider.fontWith(type: .medium, size: 16)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }
    
    @objc private func presentModalSelector() {
        let viewModel = MockSportTypeSelectorViewModel.manySportsMock
        let modalController = GomaUI.SportTypeSelectorViewController(viewModel: viewModel)
        
        modalController.onSportSelected = { [weak self] (sport: SportTypeData) in
            self?.handleSportSelection(sport)
            modalController.dismiss()
        }
        
        modalController.onCancel = { () -> Void in
            modalController.dismiss()
        }
        
        modalController.presentModally(from: self)
    }
    
    private func handleSportSelection(_ sport: SportTypeData) {
        selectedSportLabel.text = "Selected: \(sport.name) (ID: \(sport.id))"
        selectedSportLabel.textColor = StyleProvider.Color.highlightPrimary
        
        // Visual feedback
        UIView.animate(withDuration: 0.2) {
            self.selectedSportLabel.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.selectedSportLabel.transform = .identity
            }
        }
    }
    
    private func addSectionHeader(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = StyleProvider.fontWith(type: .semibold, size: 18)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .left
        
        let containerView = UIView()
        containerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
        
        stackView.addArrangedSubview(containerView)
    }
    
    private func addInfoLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textSecondary
        label.numberOfLines = 0
        stackView.addArrangedSubview(label)
    }
}