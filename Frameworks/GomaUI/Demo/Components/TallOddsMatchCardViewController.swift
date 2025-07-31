import UIKit
import GomaUI

class TallOddsMatchCardViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var scrollView = createScrollView()
    private lazy var contentStackView = createContentStackView()
    private lazy var segmentedControl = createSegmentedControl()
    
    // Match card views
    private var currentMatchCardView: TallOddsMatchCardView?
    
    // MARK: - Properties
    private let mockViewModels: [MockTallOddsMatchCardViewModel] = [
        MockTallOddsMatchCardViewModel.premierLeagueMock,
        MockTallOddsMatchCardViewModel.liveMock,
        MockTallOddsMatchCardViewModel.compactMock,
        MockTallOddsMatchCardViewModel.bundesliegaMock
    ]
    
    private let sectionTitles = ["Premier League", "Live Match", "La Liga", "Bundesliga"]
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        showMatchCard(at: 0)
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = StyleProvider.Color.backgroundColor
        title = "Pre-Live Match Card"
        
        setupScrollView()
        setupSegmentedControl()
        setupLayout()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupSegmentedControl() {
        contentStackView.addArrangedSubview(segmentedControl)
    }
    
    private func setupLayout() {
        // Additional spacing after segmented control
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        contentStackView.addArrangedSubview(spacerView)
    }
    
    // MARK: - Actions
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        showMatchCard(at: sender.selectedSegmentIndex)
    }
    
    private func showMatchCard(at index: Int) {
        // Remove current match card
        currentMatchCardView?.removeFromSuperview()
        
        // Create new match card
        let viewModel = mockViewModels[index]
        let matchCardView = TallOddsMatchCardView(viewModel: viewModel)
        matchCardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to content stack
        contentStackView.addArrangedSubview(matchCardView)
        currentMatchCardView = matchCardView
    }

}

// MARK: - UI Factory Methods
extension TallOddsMatchCardViewController {
    private func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }
    
    private func createContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }
    
    private func createSegmentedControl() -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: sectionTitles)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        // Add margins
        NSLayoutConstraint.activate([
            segmentedControl.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return segmentedControl
    }
}
