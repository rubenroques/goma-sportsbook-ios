//
//  RibDocsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 02/06/2023.
//

import UIKit
import Combine

class RibDocsViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    init() {
        
    }
}
class RibDocsViewController: UIViewController {
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentBaseView: UIView = Self.createContentBaseView()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    private var cancellables = Set<AnyCancellable>()

    var viewModel: RibDocsViewModel

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }

    // MARK: - Lifetime and Cycle
    init(viewModel: RibDocsViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.bind(toViewModel: self.viewModel)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.scrollView.backgroundColor = .clear

        self.contentBaseView.backgroundColor = .clear

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)

   }

    // MARK: - Bindings
    private func bind(toViewModel viewModel: RibDocsViewModel) {

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in

                self?.isLoading = isLoading

            })
            .store(in: &cancellables)
    }

}

extension RibDocsViewController {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createContentBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.scrollView)

        self.scrollView.addSubview(self.contentBaseView)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.activityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.scrollView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.contentBaseView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.contentBaseView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.contentBaseView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.contentBaseView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])

    }
}
