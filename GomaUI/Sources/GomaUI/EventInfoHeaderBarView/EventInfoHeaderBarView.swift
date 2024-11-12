//
//  EventInfoHeaderBarView.swift
//  GomaUI
//
//  Created by Ruben Roques on 15/10/2024.
//

import UIKit
import GomaAssets
import Combine

class EventInfoHeaderBarView: UIView {

    private lazy var containerView: UIView = self.createContainerView()
    private lazy var stackView: UIStackView = self.createStackView()
    private lazy var starImageView: UIImageView = self.createStarImageView()
    private lazy var starTouchableArea: UIView = self.createStarTouchableArea() // New touchable area
    private lazy var sportIconView: UIImageView = self.createIconView()
    private lazy var countryIconView: UIImageView = self.createIconView()
    private lazy var competitionNameLabel: UILabel = self.createCompetitionNameLabel()
    private lazy var bottomLine: UIView = self.createBottomLine()

    private var viewModel: EventInfoHeaderBarViewModel
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    init(viewModel: EventInfoHeaderBarViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        self.setupSubviews()
        self.setupWithTheme()
        self.setupBindings()
    }

    @available(iOS, unavailable)
    override init(frame: CGRect) {
        fatalError("Unavailable")
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Unavailable")
    }

    // MARK: - Bindings
    private func setupBindings() {
        self.viewModel.$isStarSelected
            .sink { [weak self] isSelected in
                self?.updateStarButtonAppearance(isSelected: isSelected)
            }
            .store(in: &self.cancellables)
        
        self.viewModel.$sportIconName
            .compactMap { $0 }
            .sink { [weak self] imageName in
                self?.sportIconView.image = UIImage(named: imageName)
            }
            .store(in: &self.cancellables)
        self.viewModel.$countryIconName
            .compactMap { $0 }
            .sink { [weak self] imageName in
                self?.countryIconView.image = UIImage(named: imageName)
            }
            .store(in: &self.cancellables)
        
        self.viewModel.$competitionName
            .sink { [weak self] name in
                self?.competitionNameLabel.text = name
            }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Configuration
    private func setupWithTheme() {
        let colorScheme = GomaUI.colorScheme

        self.backgroundColor = .clear

        self.containerView.backgroundColor = colorScheme.backgroundPrimary
        self.competitionNameLabel.textColor = colorScheme.textPrimary
        self.bottomLine.backgroundColor = colorScheme.separatorLine
    }
    
    private func updateStarButtonAppearance(isSelected: Bool) {
        let imageName: String = isSelected ? "selected_favorite_icon" : "unselected_favorite_icon"
        let image = UIImage(named: imageName, in: Bundle.module, with: nil)
        self.starImageView.image = image
    }
    
    @objc private func starTouchableAreaTapped() {
        self.viewModel.toggleStar()
    }

    // MARK: - Setup
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.containerView)

        self.containerView.addSubview(self.stackView)
        self.containerView.addSubview(self.bottomLine)

        self.stackView.addArrangedSubview(self.starImageView)
        self.stackView.addArrangedSubview(self.sportIconView)
        self.stackView.addArrangedSubview(self.countryIconView)
        self.stackView.addArrangedSubview(self.competitionNameLabel)

        self.containerView.addSubview(self.starTouchableArea)

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.stackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.stackView.heightAnchor.constraint(equalToConstant: 14),

            self.starImageView.widthAnchor.constraint(equalTo: self.starImageView.heightAnchor),
            self.sportIconView.widthAnchor.constraint(equalTo: self.sportIconView.heightAnchor),
            self.countryIconView.widthAnchor.constraint(equalTo: self.countryIconView.heightAnchor),

            self.bottomLine.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.bottomLine.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.bottomLine.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.bottomLine.heightAnchor.constraint(equalToConstant: 1),

            // Constraints for starTouchableArea
            self.starTouchableArea.widthAnchor.constraint(equalToConstant: 40),
            self.starTouchableArea.heightAnchor.constraint(equalToConstant: 40),
            self.starImageView.centerXAnchor.constraint(equalTo: self.starTouchableArea.centerXAnchor),
            self.starImageView.centerYAnchor.constraint(equalTo: self.starTouchableArea.centerYAnchor),
        ])
    }

    private func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func createStarImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true // Enable interaction
        return imageView
    }

    private func createStarTouchableArea() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(starTouchableAreaTapped)))
        return view
    }

    private func createIconView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private func createCompetitionNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.text = ""
        return label
    }

    private func createBottomLine() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

}

@available(iOS 17, *)
#Preview("EventInfoHeaderBarView") {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = .gray

    let viewModel = EventInfoHeaderBarViewModel.debug
    let view = EventInfoHeaderBarView(viewModel: viewModel)
    containerView.addSubview(view)

    NSLayoutConstraint.activate([
        containerView.widthAnchor.constraint(equalToConstant: 340),
        view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        view.topAnchor.constraint(equalTo: containerView.topAnchor),
    ])

    return containerView
}
