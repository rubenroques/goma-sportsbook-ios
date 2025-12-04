//
//  LanguageSelectorFullScreenViewController.swift
//  BetssonCameroonApp
//

import UIKit
import Combine
import GomaUI

final class LanguageSelectorFullScreenViewController: UIViewController {

    // MARK: - Private Properties

    private let viewModel: LanguageSelectorFullScreenViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var navigationBarView: SimpleNavigationBarView = {
        let navBarVM = BetssonCameroonNavigationBarViewModel(
            title: localized("change_language"),
            onBackTapped: { [weak self] in
                self?.viewModel.didTapBack()
            }
        )
        let navBar = SimpleNavigationBarView(viewModel: navBarVM)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        return navBar
    }()

    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private lazy var languageSelectorView: LanguageSelectorView = {
        let view = LanguageSelectorView(
            viewModel: viewModel.languageSelectorViewModel,
            imageResolver: AppLanguageFlagImageResolver()
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Initialization

    init(viewModel: LanguageSelectorFullScreenViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()

        // Load languages
        viewModel.languageSelectorViewModel.loadLanguages()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - Status Bar

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = UIColor.App.backgroundTertiary
        setupViewHierarchy()
        setupConstraints()
    }

    private func setupViewHierarchy() {
        view.addSubview(navigationBarView)
        view.addSubview(contentContainerView)
        contentContainerView.addSubview(languageSelectorView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Navigation Bar
            navigationBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Content Container
            contentContainerView.topAnchor.constraint(equalTo: navigationBarView.bottomAnchor, constant: 16),
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentContainerView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -16),

            // Language Selector View
            languageSelectorView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            languageSelectorView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            languageSelectorView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            languageSelectorView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.displayStatePublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(displayState: displayState)
            }
            .store(in: &cancellables)
    }

    // MARK: - Rendering

    private func render(displayState: LanguageSelectorFullScreenDisplayState) {
        // Future: handle loading states if needed
    }
}

// MARK: - SwiftUI Preview

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Language Selector - Default") {
    PreviewUIViewController {
        let viewModel = MockLanguageSelectorFullScreenViewModel.defaultMock
        return LanguageSelectorFullScreenViewController(viewModel: viewModel)
    }
}

#endif
