import UIKit
import GomaUI

class SportTypeSelectorItemViewController: UIViewController {
    
    private var stackView: UIStackView!
    private var itemViews: [SportTypeSelectorItemView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSampleItems()
    }
    
    private func setupUI() {
        title = "Sport Type Selector Item"
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
    }
    
    private func setupSampleItems() {
        addSectionHeader("Individual Sport Items")
        
        // Row 1
        let row1 = createHorizontalRow([
            MockSportTypeSelectorItemViewModel.footballMock,
            MockSportTypeSelectorItemViewModel.basketballMock
        ])
        stackView.addArrangedSubview(row1)
        
        // Row 2
        let row2 = createHorizontalRow([
            MockSportTypeSelectorItemViewModel.tennisMock,
            MockSportTypeSelectorItemViewModel.baseballMock
        ])
        stackView.addArrangedSubview(row2)
        
        // Row 3
        let row3 = createHorizontalRow([
            MockSportTypeSelectorItemViewModel.hockeyMock,
            MockSportTypeSelectorItemViewModel.golfMock
        ])
        stackView.addArrangedSubview(row3)
        
        addSectionHeader("Tap Interaction Demo")
        
        let interactiveItem = SportTypeSelectorItemView(viewModel: MockSportTypeSelectorItemViewModel.volleyballMock)
        interactiveItem.onTap = { [weak self] sportData in
            self?.showTapAlert(for: sportData)
        }
        
        let centeredContainer = UIView()
        centeredContainer.addSubview(interactiveItem)
        interactiveItem.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            interactiveItem.centerXAnchor.constraint(equalTo: centeredContainer.centerXAnchor),
            interactiveItem.topAnchor.constraint(equalTo: centeredContainer.topAnchor),
            interactiveItem.bottomAnchor.constraint(equalTo: centeredContainer.bottomAnchor),
            interactiveItem.widthAnchor.constraint(equalToConstant: 150),
            interactiveItem.heightAnchor.constraint(equalToConstant: 56),
            centeredContainer.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        stackView.addArrangedSubview(centeredContainer)
        
        addSectionHeader("Technical Details")
        addInfoLabel("• Fixed 56pt height with 8pt corner radius")
        addInfoLabel("• 24x24pt icon with 12pt text below")
        addInfoLabel("• Uses StyleProvider.Color.backgroundSecondary")
        addInfoLabel("• Text and icons use StyleProvider.Color.textPrimary")
        addInfoLabel("• Horizontal padding: 12pt, Vertical: 6pt")
        addInfoLabel("• Tap gesture support with callback closure")
    }
    
    private func createHorizontalRow(_ viewModels: [MockSportTypeSelectorItemViewModel]) -> UIView {
        let rowStackView = UIStackView()
        rowStackView.axis = .horizontal
        rowStackView.spacing = 8
        rowStackView.distribution = .fillEqually
        
        for viewModel in viewModels {
            let itemView = SportTypeSelectorItemView(viewModel: viewModel)
            itemView.onTap = { [weak self] sportData in
                self?.showTapAlert(for: sportData)
            }
            itemView.heightAnchor.constraint(equalToConstant: 56).isActive = true
            rowStackView.addArrangedSubview(itemView)
            itemViews.append(itemView)
        }
        
        return rowStackView
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
    
    private func showTapAlert(for sportData: SportTypeData) {
        let alert = UIAlertController(
            title: "Sport Selected",
            message: "You selected: \(sportData.name)\nID: \(sportData.id)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}