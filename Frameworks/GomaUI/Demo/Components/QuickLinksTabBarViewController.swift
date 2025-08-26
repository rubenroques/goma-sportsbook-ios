import UIKit
import GomaUI

class QuickLinksTabBarViewController: UIViewController {

    private var quickLinksTabBar: QuickLinksTabBarView!
    private var selectedLinkLabel: UILabel!

    private var currentViewModel: MockQuickLinksTabBarViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        // Setup QuickLinksTabBarView
        self.setupQuickLinksTabBar()

        // Setup controls
        self.setupControls()
    }

    private func setupQuickLinksTabBar() {
        if self.currentViewModel == nil {
            self.currentViewModel = MockQuickLinksTabBarViewModel.gamingMockViewModel
        }

        self.quickLinksTabBar = QuickLinksTabBarView(viewModel: currentViewModel)
        self.quickLinksTabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.quickLinksTabBar)

        NSLayoutConstraint.activate([
            self.quickLinksTabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.quickLinksTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.quickLinksTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        self.quickLinksTabBar.onQuickLinkSelected = { [weak self] linkType in
            self?.handleQuickLinkSelection(linkType)
        }
    }

    private func setupControls() {
        // Selected link label
        self.selectedLinkLabel = UILabel()
        self.selectedLinkLabel.translatesAutoresizingMaskIntoConstraints = false
        self.selectedLinkLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.selectedLinkLabel.textAlignment = .center
        self.selectedLinkLabel.text = "Tap a quick link to see selection"
        self.view.addSubview(self.selectedLinkLabel)

        // Layout constraints
        NSLayoutConstraint.activate([
            self.selectedLinkLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.selectedLinkLabel.topAnchor.constraint(equalTo: self.quickLinksTabBar.bottomAnchor, constant: 40),
        ])
    }

    private func handleQuickLinkSelection(_ linkType: QuickLinkType) {
        // Update the selection label
        self.selectedLinkLabel.text = "Selected: \(linkType.rawValue.capitalized)"

        // Flash animation for feedback
        UIView.animate(withDuration: 0.2, animations: {
            self.selectedLinkLabel.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.selectedLinkLabel.transform = .identity
            }
        }
    }
}
