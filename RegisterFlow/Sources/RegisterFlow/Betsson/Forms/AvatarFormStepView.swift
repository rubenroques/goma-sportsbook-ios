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
import Lottie

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

    private var animationView: LottieAnimationView?
    private lazy var avatarAnimationPlaceholdeView: UIView = Self.createAvatarAnimationPlaceholdeView()

    private var avatarViews: [String: UIView] = [:]
    private var avatarViewsTags: [Int: String] = [:]

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

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCancelAnimation(_:)))
        self.addGestureRecognizer(tapGesture)
        
        self.titleLabel.text = self.viewModel.title
        self.subtitleLabel.text = self.viewModel.subtitle

        self.stackView.addArrangedSubview(self.subtitleLabel)

        var tagCounter = 0
        // Add avatars
        for avatarGroup in self.viewModel.avatarIconNameGroups {
            let lineStackView = Self.createHorizontalStackView()

            NSLayoutConstraint.activate([
                lineStackView.heightAnchor.constraint(equalToConstant: 100)
            ])

            for avatarName in avatarGroup {

                let outerBaseView = Self.createAvatarOuterBaseView()

                let baseView = Self.createAvatarBaseView()

                outerBaseView.addSubview(baseView)

                NSLayoutConstraint.activate([
                    baseView.widthAnchor.constraint(equalToConstant: 90),
                    baseView.heightAnchor.constraint(equalTo: baseView.widthAnchor),
                    baseView.centerXAnchor.constraint(equalTo: outerBaseView.centerXAnchor),
                    baseView.centerYAnchor.constraint(equalTo: outerBaseView.centerYAnchor)
                ])

//                let baseInnerView = Self.createAvatarBaseInnerView()
//                baseInnerView.backgroundColor = AppColor.backgroundPrimary
//
//                baseView.addSubview(baseInnerView)
//                baseView.bringSubviewToFront(baseInnerView)
//
//                NSLayoutConstraint.activate([
//                    baseInnerView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 2),
//                    baseInnerView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -2),
//                    baseInnerView.topAnchor.constraint(equalTo: baseView.topAnchor,constant: 2),
//                    baseInnerView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -2)
//                ])

                let imageView = Self.createAvatarImageView()
                imageView.image = UIImage(named: avatarName, in: Bundle.module, with: nil)
                imageView.tag = tagCounter

                baseView.addSubview(imageView)

                NSLayoutConstraint.activate([
                    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
                    imageView.widthAnchor.constraint(equalToConstant: 90),
                    imageView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
                    imageView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor)
                ])

                baseView.bringSubviewToFront(imageView)
                lineStackView.addArrangedSubview(outerBaseView)

                avatarViews[avatarName] = baseView
                avatarViewsTags[tagCounter] = avatarName

                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatarImageView(_:))))

                tagCounter += 1
            }
            self.stackView.addArrangedSubview(lineStackView)
        }

        self.selectAvatarWithName(self.viewModel.selectedAvatarName.value)


        self.insertSubview(self.avatarAnimationPlaceholdeView, at: 0)

        if let secondeArrangedView = self.stackView.arrangedSubviews[safe: 1] { // First line of avatars
            NSLayoutConstraint.activate([
                self.avatarAnimationPlaceholdeView.centerXAnchor.constraint(equalTo: self.stackView.centerXAnchor),
                self.avatarAnimationPlaceholdeView.widthAnchor.constraint(equalTo: self.avatarAnimationPlaceholdeView.heightAnchor),
                self.avatarAnimationPlaceholdeView.topAnchor.constraint(equalTo: secondeArrangedView.topAnchor),
                self.avatarAnimationPlaceholdeView.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor),
            ])
        }

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
//
//        for avatarView in avatarViews.values {
//            avatarView.layer.cornerRadius = avatarView.frame.height/2
//        }
//
//        for avatarBackgroundView in avatarBackgroundViews.values {
//            avatarBackgroundView.layer.cornerRadius = avatarBackgroundView.frame.height/2
//
//        }
    }

    override func setupWithTheme() {
        super.setupWithTheme()

        self.titleLabel.textColor = AppColor.textPrimary
        self.subtitleLabel.textColor = AppColor.textPrimary
    }

    func selectAvatarWithName(_ name: String) {
        for avatarView in self.avatarViews.values {
            avatarView.alpha = 0.6
        }

        if let selectedView = self.avatarViews[name] {
            selectedView.alpha = 1.0
        }

        self.animateForAvatarWithName(name)
        self.viewModel.setSelectedAvatarName(name)
    }

    func animateForAvatarWithName(_ name: String) {
        guard
            let selectedView = self.avatarViews[name]
        else { return }

        self.animationView?.removeFromSuperview()
        self.animationView = nil

        let startFrame = selectedView.convert(selectedView.bounds, to: self)
        let endFrame = self.avatarAnimationPlaceholdeView.frame

        let avatarAnimationView = self.createAvatarAnimationView(withFrame: startFrame, andName: name)
        avatarAnimationView.isUserInteractionEnabled = false
        avatarAnimationView.alpha = 0.0
        self.addSubview(avatarAnimationView)

        avatarAnimationView.play()

        self.animationView = avatarAnimationView
        
        // simplifiend animation
//        self.animationView?.frame = endFrame
//        UIView.animate(withDuration: 0.35, delay: 0) {
//            avatarAnimationView.alpha = 1.0
//        } completion: { completed in
//            UIView.animate(withDuration: 0.35, delay: 3.0) {
//                avatarAnimationView.alpha = 0.0
//            } completion: { completed in
//                avatarAnimationView.stop()
//                avatarAnimationView.removeFromSuperview()
//            }
//        }
        //
        
        // Using CGAffineTransform
        // Initial transform (scale or other transformations can be added here)
         avatarAnimationView.transform = CGAffineTransform.identity

         UIView.animate(withDuration: 0.1, delay: 0.0) {
             avatarAnimationView.alpha = 1.0
         } completion: { completed in
             UIView.animate(withDuration: 0.6, delay: 0.1) {
                 // Calculate the translation needed
                 let translationX = endFrame.midX - startFrame.midX
                 let translationY = endFrame.midY - startFrame.midY
                 let frameTransofrm = CGAffineTransform(translationX: translationX, y: translationY)
                 avatarAnimationView.transform = frameTransofrm.scaledBy(x: 1.9, y: 1.9)
             } completion: { completed in
                 UIView.animate(withDuration: 0.6, delay: 3.0) {
                     avatarAnimationView.transform = CGAffineTransform.identity
                 } completion: { completed in
                     avatarAnimationView.alpha = 0.0
                     avatarAnimationView.stop()
                     avatarAnimationView.removeFromSuperview()
                 }
             }
         }
       
    }

    @objc func didTapCancelAnimation(_ gesture: UITapGestureRecognizer) {
        guard let avatarAnimationView = self.animationView else {
            return
        }

        // Remove the view from superview
        avatarAnimationView.stop()
        avatarAnimationView.removeFromSuperview()
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
        imageView.clipsToBounds = true
//        imageView.layer.borderWidth = 4.0
//        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.isUserInteractionEnabled = true

        return imageView
    }

    private static func createAvatarOuterBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

    private static func createAvatarAnimationPlaceholdeView() -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createAvatarAnimationView(withFrame frame: CGRect, andName name: String) -> LottieAnimationView {
        
        let animationView = LottieAnimationView(frame: frame)
        animationView.contentMode = .scaleAspectFill
        animationView.clipsToBounds = false
        animationView.loopMode = .loop
        
        let animationName: String
        if self.traitCollection.userInterfaceStyle == .dark {
            animationName = name + "-dark"
        } else {
            animationName = name + "-light"
        }
        
        let avatarAnimation = LottieAnimation.named(animationName, bundle: Bundle.module)
        animationView.animation = avatarAnimation
        return animationView
    }
}
