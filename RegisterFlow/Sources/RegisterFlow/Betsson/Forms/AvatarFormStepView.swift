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

class AvatarFormStepViewModel {

    let title: String
    let subtitle: String
    let avatarIconNames: [String]

    var selectedAvatarName: CurrentValueSubject<String, Never>

    private var userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater

    var avatarIconNameGroups: [[String]] {
        let count = self.avatarIconNames.count
        let size = 3
        let arrays = stride(from: 0, to: count, by: size).map {
            Array(self.avatarIconNames[$0 ..< Swift.min($0 + size, count)])
        }
        return arrays
    }

    var isFormCompleted: AnyPublisher<Bool, Never> {
        return Just(true).eraseToAnyPublisher()
    }

    init(title: String,
         subtitle: String,
         avatarIconNames: [String],
         selectedAvatarName: String?,
         userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) {

        self.title = title
        self.subtitle = subtitle
        self.avatarIconNames = avatarIconNames

        if let selectedAvatarName = selectedAvatarName {
            self.selectedAvatarName = .init(selectedAvatarName)
        }
        else if let first = avatarIconNames.first {
            self.selectedAvatarName = .init(first)
        }
        else {
            self.selectedAvatarName = .init("avatar1")
        }

        self.userRegisterEnvelopUpdater = userRegisterEnvelopUpdater
    }

    func setSelectedAvatarName(_ avatarName: String) {
        self.selectedAvatarName.send(avatarName)
        self.userRegisterEnvelopUpdater.setAvatarName(avatarName)
    }

}

class AvatarFormStepView: FormStepView {

    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var verticalStackView: UIStackView = Self.createVerticalStackView()
    private var horizontalStackViews: [UIStackView] = []

    private var avatarViews: [String: UIView] = [:]
    private var avatarViewsTags: [Int: String] = [:]
    private var avatarBackgroundViews: [String: UIView] = [:]

    let viewModel: AvatarFormStepViewModel

    override var isFormCompleted: AnyPublisher<Bool, Never> {
        return self.viewModel.isFormCompleted
    }

    init(viewModel: AvatarFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }
    
    func configureSubviews() {

        self.titleLabel.text = self.viewModel.title
        self.subtitleLabel.text = self.viewModel.subtitle

        self.stackView.addArrangedSubview(self.subtitleLabel)

        var tagCounter = 0
        // Add avatars
        for avatarGroup in self.viewModel.avatarIconNameGroups {
            let lineStackView = Self.createHorizontalStackView()
            for avatarName in avatarGroup {

                let baseView = Self.createAvatarBaseView()

                NSLayoutConstraint.activate([
                    baseView.widthAnchor.constraint(equalToConstant: 80),
                    baseView.heightAnchor.constraint(equalTo: baseView.widthAnchor)
                ])

                let baseInnerView = Self.createAvatarBaseInnerView()
                baseInnerView.backgroundColor = AppColor.backgroundPrimary

                baseView.addSubview(baseInnerView)
                baseView.bringSubviewToFront(baseInnerView)

                NSLayoutConstraint.activate([
                    baseInnerView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 4),
                    baseInnerView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -4),
                    baseInnerView.topAnchor.constraint(equalTo: baseView.topAnchor,constant: 4),
                    baseInnerView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -4)
                ])

                let imageView = Self.createAvatarImageView()
                imageView.image = UIImage(named: avatarName, in: Bundle.module, with: nil)
                imageView.tag = tagCounter

                baseView.addSubview(imageView)

                NSLayoutConstraint.activate([
                    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
                    imageView.widthAnchor.constraint(equalToConstant: 120),
                    imageView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
                    imageView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor)
                ])

                baseView.bringSubviewToFront(imageView)
                lineStackView.addArrangedSubview(baseView)

                avatarViews[avatarName] = baseView
                avatarBackgroundViews[avatarName] = baseInnerView
                avatarViewsTags[tagCounter] = avatarName

                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatarImageView(_:))))

                tagCounter += 1
            }
            self.stackView.addArrangedSubview(lineStackView)
        }

        self.selectAvatarWithName(self.viewModel.selectedAvatarName.value)
        
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        for avatarView in avatarViews.values {
            avatarView.layer.cornerRadius = avatarView.frame.height/2
        }

        for avatarBackgroundView in avatarBackgroundViews.values {
            avatarBackgroundView.layer.cornerRadius = avatarBackgroundView.frame.height/2

        }
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.titleLabel.textColor = AppColor.textPrimary
        self.subtitleLabel.textColor = AppColor.textPrimary

    }

    func selectAvatarWithName(_ name: String) {
        for avatarView in avatarViews.values {
//            avatarView.layer.borderColor = UIColor.clear.cgColor
            avatarView.backgroundColor = .clear
            avatarView.alpha = 0.95
        }

        if let selectedView = avatarViews[name] {
            //selectedView.layer.borderColor = AppColor.highlightPrimary.cgColor
            selectedView.backgroundColor = AppColor.highlightPrimary
            selectedView.alpha = 1.0
        }

        self.viewModel.setSelectedAvatarName(name)
    }

    @IBAction func didTapAvatarImageView(_ sender: UITapGestureRecognizer? = nil) {
        guard let tag = sender?.view?.tag else { return }

        if let name = avatarViewsTags[tag] {
            self.selectAvatarWithName(name)
        }
    }

    override func canPresentError(forFormStep formStep: FormStep) -> Bool {
        switch formStep {
        case .avatar: return true
        default: return false
        }
    }

    override func presentError(_ error: RegisterError, forFormStep formStep: FormStep) {
        if !self.canPresentError(forFormStep: formStep) { return }
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

//        imageView.layer.borderWidth = 4.0
//        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.isUserInteractionEnabled = true

        return imageView
    }

    private static func createAvatarBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAvatarBaseInnerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

}
