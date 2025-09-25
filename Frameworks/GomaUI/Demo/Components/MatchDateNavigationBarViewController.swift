import UIKit
import GomaUI

class MatchDateNavigationBarViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private var navigationBars: [MatchDateNavigationBarView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Match Date Navigation Bar"
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        setupViews()
        createNavigationBarExamples()
    }
    
    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createNavigationBarExamples() {
        addSection(title: "Pre-Match State", navigationBar: createPreMatchNavigationBar())
        addSection(title: "Live Match - First Half", navigationBar: createLiveNavigationBar())
        addSection(title: "Live Match - Second Half", navigationBar: createSecondHalfNavigationBar())
        addSection(title: "Half Time", navigationBar: createHalfTimeNavigationBar())
        addSection(title: "Extra Time", navigationBar: createExtraTimeNavigationBar())
        addSection(title: "No Back Button", navigationBar: createNoBackButtonNavigationBar())
        addSection(title: "Custom Date Format", navigationBar: createCustomDateNavigationBar())
        
        // Add animated demo
        let animatedSection = createAnimatedSection()
        stackView.addArrangedSubview(animatedSection)
    }
    
    private func addSection(title: String, navigationBar: MatchDateNavigationBarView) {
        let sectionView = UIView()
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        sectionView.addSubview(titleLabel)
        sectionView.addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sectionView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -16),
            
            navigationBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            navigationBar.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 47), // Ensure fixed height
            navigationBar.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor, constant: -16) // Add bottom spacing
        ])
        
        stackView.addArrangedSubview(sectionView)
        navigationBars.append(navigationBar)
    }
    
    private func createPreMatchNavigationBar() -> MatchDateNavigationBarView {
        let viewModel = MockMatchDateNavigationBarViewModel.defaultPreMatchMock
        let navigationBar = MatchDateNavigationBarView(viewModel: viewModel)
        
        navigationBar.onBackTapped = { [weak self] in
            self?.showAlert(title: "Back Tapped", message: "Pre-match navigation bar back button")
        }
        
        return navigationBar
    }
    
    private func createLiveNavigationBar() -> MatchDateNavigationBarView {
        let viewModel = MockMatchDateNavigationBarViewModel.liveMock
        let navigationBar = MatchDateNavigationBarView(viewModel: viewModel)
        
        navigationBar.onBackTapped = { [weak self] in
            self?.showAlert(title: "Back Tapped", message: "Live match navigation bar back button")
        }
        
        return navigationBar
    }
    
    private func createSecondHalfNavigationBar() -> MatchDateNavigationBarView {
        let viewModel = MockMatchDateNavigationBarViewModel.secondHalfMock
        let navigationBar = MatchDateNavigationBarView(viewModel: viewModel)
        
        navigationBar.onBackTapped = { [weak self] in
            self?.showAlert(title: "Back Tapped", message: "Second half navigation bar back button")
        }
        
        return navigationBar
    }
    
    private func createHalfTimeNavigationBar() -> MatchDateNavigationBarView {
        let viewModel = MockMatchDateNavigationBarViewModel.halfTimeMock
        let navigationBar = MatchDateNavigationBarView(viewModel: viewModel)
        
        navigationBar.onBackTapped = { [weak self] in
            self?.showAlert(title: "Back Tapped", message: "Half time navigation bar back button")
        }
        
        return navigationBar
    }
    
    private func createExtraTimeNavigationBar() -> MatchDateNavigationBarView {
        let viewModel = MockMatchDateNavigationBarViewModel.extraTimeMock
        let navigationBar = MatchDateNavigationBarView(viewModel: viewModel)
        
        navigationBar.onBackTapped = { [weak self] in
            self?.showAlert(title: "Back Tapped", message: "Extra time navigation bar back button")
        }
        
        return navigationBar
    }
    
    private func createNoBackButtonNavigationBar() -> MatchDateNavigationBarView {
        let viewModel = MockMatchDateNavigationBarViewModel.noBackButtonMock
        return MatchDateNavigationBarView(viewModel: viewModel)
    }
    
    private func createCustomDateNavigationBar() -> MatchDateNavigationBarView {
        let viewModel = MockMatchDateNavigationBarViewModel.customDateFormatMock
        let navigationBar = MatchDateNavigationBarView(viewModel: viewModel)
        
        navigationBar.onBackTapped = { [weak self] in
            self?.showAlert(title: "Back Tapped", message: "Custom date format navigation bar back button")
        }
        
        return navigationBar
    }
    
    private func createAnimatedSection() -> UIView {
        let sectionView = UIView()
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Animated Demo (Auto-updating)"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        
        let viewModel = MockMatchDateNavigationBarViewModel.createAnimatedMock()
        let navigationBar = MatchDateNavigationBarView(viewModel: viewModel)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        navigationBar.onBackTapped = { [weak self] in
            self?.showAlert(title: "Back Tapped", message: "Animated navigation bar back button")
        }
        
        sectionView.addSubview(titleLabel)
        sectionView.addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sectionView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor, constant: -16),
            
            navigationBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            navigationBar.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 47), // Ensure fixed height
            navigationBar.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor, constant: -16) // Add bottom spacing
        ])
        
        return sectionView
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
