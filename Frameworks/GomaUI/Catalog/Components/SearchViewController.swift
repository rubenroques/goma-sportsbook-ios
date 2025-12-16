import UIKit
import Combine
import GomaUI

class SearchViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    private let viewModel = MockSearchViewModel.default
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupDemo()
    }

    private func setupViews() {
        view.backgroundColor = .systemBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func setupDemo() {
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 16)
        descriptionLabel.textColor = StyleProvider.Color.textPrimary
        descriptionLabel.text = "SearchView with leading icon, placeholder, and clear button. Shows default placeholder state and typing state."

        let search = SearchView(viewModel: viewModel)
        search.translatesAutoresizingMaskIntoConstraints = false

        let sampleHint = UILabel()
        sampleHint.numberOfLines = 0
        sampleHint.font = StyleProvider.fontWith(type: .regular, size: 14)
        sampleHint.textColor = StyleProvider.Color.textSecondary
        sampleHint.text = "Type ‘Liverpool’ to see the clear button appear."

        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(search)
        stackView.addArrangedSubview(sampleHint)

        // Pre-fill to demonstrate typed state toggle programmatically
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.viewModel.updateText("")
        }
    }
}


