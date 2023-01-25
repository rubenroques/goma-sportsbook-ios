//
//  AddressFormStepView.swift
//  
//
//  Created by Ruben Roques on 16/01/2023.
//

import UIKit
import Extensions
import Combine
import Theming

struct AvatarFormStepViewModel {

    let title: String
    let subtitle: String
    let avatarIconNames: [String]
    
    var avatarIconNameGroups: [[String]] {
        let count = self.avatarIconNames.count
        let size = 3
        let arrays = stride(from: 0, to: count, by: size).map {
            Array(self.avatarIconNames[$0 ..< Swift.min($0 + size, count)])
        }
        return arrays
    }

}

class AvatarFormStepView: FormStepView {

    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var verticalStackView: UIStackView = Self.createVerticalStackView()
    private var horizontalStackViews: [UIStackView] = []

    let viewModel: AvatarFormStepViewModel

    init(viewModel: AvatarFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return Just(true).eraseToAnyPublisher()
    }
    
    func configureSubviews() {

        self.titleLabel.text = self.viewModel.title
        self.subtitleLabel.text = self.viewModel.subtitle

        self.stackView.addArrangedSubview(self.subtitleLabel)

        // Add avatars
        for avatarGroup in self.viewModel.avatarIconNameGroups {
            let lineStackView = Self.createHorizontalStackView()
            for avatarName in avatarGroup {

                let imageView = Self.createAvatarImageView()
                imageView.image = UIImage(named: avatarName, in: Bundle.module, with: nil)

                NSLayoutConstraint.activate([
                    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
                    imageView.widthAnchor.constraint(equalToConstant: 80)
                ])

                lineStackView.addArrangedSubview(imageView)
            }
            self.stackView.addArrangedSubview(lineStackView)
        }

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.titleLabel.textColor = AppColor.textPrimary
        self.subtitleLabel.textColor = AppColor.textPrimary

    }

}

extension AvatarFormStepView {

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    private static func createVerticalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 24
        return stackView
    }

    private static func createHorizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }

    private static func createAvatarImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

}
