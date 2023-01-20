//
//  RegisterStepView.swift
//  
//
//  Created by Ruben Roques on 11/01/2023.
//

import Foundation
import ServicesProvider
import UIKit
import Combine
import Extensions
import Theming

public struct RegisterStepViewModel {

    let serviceProvider: ServicesProviderClient

    public init(serviceProvider: ServicesProviderClient) {
        self.serviceProvider = serviceProvider
    }

}

public class RegisterStepView: UIView {

    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var scrollInnerView: UIView = Self.createScrollInnerView()

    private lazy var stackView: UIStackView = Self.createStackView()

    private let viewModel: RegisterStepViewModel
    private var formStepViews: [FormStepView] = []

    private var cancellables = Set<AnyCancellable>()

    var isRegisterStepCompleted: AnyPublisher<Bool, Never> {
        let publishers = self.formStepViews.map(\.isFormCompleted)

        return publishers.combineLatest()
            .map { forms in
                return forms.reduce(true, { $0 && $1 })
            }
            .eraseToAnyPublisher()
    }

    public init(viewModel: RegisterStepViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)
        
        self.commonInit()
        self.setupWithTheme()
    }

    @available(iOS, unavailable)
    required public override init(frame: CGRect) {
        fatalError()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func commonInit() {
        self.setupSubviews()

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    func setupWithTheme() {
        self.backgroundColor = AppColor.backgroundPrimary

        self.scrollView.backgroundColor = AppColor.backgroundPrimary
        self.scrollInnerView.backgroundColor = AppColor.backgroundPrimary
    }

    func addFormView(formView: FormStepView) {
        self.formStepViews.append(formView)
        self.stackView.addArrangedSubview(formView)
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension RegisterStepView {

    private static func createScrollInnerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.clipsToBounds = true
        return scrollView
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func setupSubviews() {

        self.initConstraints()
    }

    private func initConstraints() {

        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.scrollInnerView)

        self.scrollInnerView.addSubview(self.stackView)

        let topConstraint = self.scrollView.contentLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: self.scrollInnerView.topAnchor)
        topConstraint.priority = UILayoutPriority.init(rawValue: 1000)

        let stepsViewCenterY = self.scrollView.centerYAnchor.constraint(equalTo: self.scrollInnerView.centerYAnchor)
        stepsViewCenterY.priority = UILayoutPriority.init(990)

        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            self.scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: self.scrollInnerView.topAnchor),
            self.scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: self.scrollInnerView.bottomAnchor),
            self.scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: self.scrollInnerView.leadingAnchor),
            self.scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: self.scrollInnerView.trailingAnchor),

            self.scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: self.scrollInnerView.widthAnchor),

            self.stackView.leadingAnchor.constraint(equalTo: self.scrollInnerView.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.scrollInnerView.trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.scrollInnerView.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.scrollInnerView.bottomAnchor),

            stepsViewCenterY,
            topConstraint
        ])

    }

}


/*

 //
 // MARK: - Subviews Initialization and Setup
 //
 extension SportStatisticView {

     private static func createContainerView() -> UIView {
         let view = UIView()
         view.translatesAutoresizingMaskIntoConstraints = false
         return view
     }

     private static func createIconImageView() -> UIImageView {
         let imageView = UIImageView()
         imageView.translatesAutoresizingMaskIntoConstraints = false
         imageView.image = UIImage(named: "sport_type_soccer_icon")
         imageView.contentMode = .scaleAspectFit
         return imageView
     }

     private static func createProgressBarView() -> UIProgressView {
         let progressView = UIProgressView()
         progressView.translatesAutoresizingMaskIntoConstraints = false
         progressView.progress = 0
         return progressView
     }

     private static func createValueLabel() -> UILabel {
         let label = UILabel()
         label.translatesAutoresizingMaskIntoConstraints = false
         label.text = "80%"
         label.font = AppFont.with(type: .bold, size: 12)
         return label
     }

     private func setupSubviews() {

         self.addSubview(self.containerView)

         self.containerView.addSubview(self.iconImageView)

         self.containerView.addSubview(self.progressBarView)

         self.containerView.addSubview(self.valueLabel)

         self.initConstraints()

     }

     private func initConstraints() {

         NSLayoutConstraint.activate([
             self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
             self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
             self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
             self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

             self.iconImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 4),
             self.iconImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 4),
             self.iconImageView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -4),
             self.iconImageView.widthAnchor.constraint(equalToConstant: 16),
             self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),

             self.progressBarView.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 10),
             self.progressBarView.widthAnchor.constraint(equalToConstant: 78),
             self.progressBarView.heightAnchor.constraint(equalToConstant: 5),
             self.progressBarView.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor),

             self.valueLabel.leadingAnchor.constraint(equalTo: self.progressBarView.trailingAnchor, constant: 5),
             self.valueLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.containerView.trailingAnchor, constant: -4),
             self.valueLabel.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor)

         ])
     }
 }



 */
