import Foundation
import UIKit
import GomaUI

class PromotionalBonusCardViewController: UIViewController {
    private let viewModels: [(title: String, viewModel: PromotionalBonusCardViewModelProtocol)] = [
        ("Default Mock", MockPromotionalBonusCardViewModel.defaultMock),
        ("No Gradient Mock", MockPromotionalBonusCardViewModel.noGradientMock)
        // Add more mocks here if available
    ]
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.text = "A card view for displaying promotional bonuses, using PromotionalBonusCardView."
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    private let cardContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    private var currentCardView: PromotionalBonusCardView?
    private var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSummaryLabel()
        setupButtonStack()
        setupCardContainer()
        displayCard(at: 0)
    }

    private func setupSummaryLabel() {
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(summaryLabel)
        NSLayoutConstraint.activate([
            summaryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            summaryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            summaryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupButtonStack() {
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        for (index, (title, _)) in viewModels.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupCardContainer() {
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardContainer)
        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 24),
            cardContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func displayCard(at index: Int) {
        guard index < viewModels.count else { return }
        
        // Remove current card view
        currentCardView?.removeFromSuperview()
        
        // Create and add new card view
        let (title, viewModel) = viewModels[index]
        let cardView = PromotionalBonusCardView(viewModel: viewModel)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor)
        ])
        
        currentCardView = cardView
        currentIndex = index
        
        // Update button states
        updateButtonStates()
    }

    private func updateButtonStates() {
        for (index, button) in buttonStackView.arrangedSubviews.enumerated() {
            if let button = button as? UIButton {
                if index == currentIndex {
                    button.backgroundColor = .systemGreen
                } else {
                    button.backgroundColor = .systemBlue
                }
            }
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        displayCard(at: sender.tag)
    }
}
