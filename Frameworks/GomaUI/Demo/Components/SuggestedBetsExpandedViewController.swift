import UIKit
import GomaUI

final class SuggestedBetsExpandedViewController: UIViewController {
    private var componentView: SuggestedBetsExpandedView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTestColor
        title = "Suggested Bets"

        let vm = MockSuggestedBetsExpandedViewModel.demo
        componentView = SuggestedBetsExpandedView(viewModel: vm)
        componentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(componentView)

        NSLayoutConstraint.activate([
            componentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            componentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            componentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            componentView.heightAnchor.constraint(equalToConstant: 420)
        ])
    }
}


