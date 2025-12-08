//
//  LanguageSelectorFullScreenViewController.swift
//  GomaPlatform
//

import UIKit
import Combine
import GomaUI

public final class LanguageSelectorFullScreenViewController: UIViewController {

    // MARK: - Private Properties

    private let viewModel: LanguageSelectorFullScreenViewModelProtocol
    private let navigationBarViewModel: SimpleNavigationBarViewModelProtocol
    private let flagImageResolver: LanguageFlagImageResolver
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var navigationBarView: SimpleNavigationBarView = {
        let navBar = SimpleNavigationBarView(viewModel: navigationBarViewModel)
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
            imageResolver: flagImageResolver
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Initialization

    /// Creates a LanguageSelectorFullScreenViewController with injected dependencies.
    /// - Parameters:
    ///   - viewModel: The full screen ViewModel
    ///   - navigationBarViewModel: The navigation bar ViewModel (client-specific)
    ///   - flagImageResolver: The flag image resolver (client-specific)
    public init(
        viewModel: LanguageSelectorFullScreenViewModelProtocol,
        navigationBarViewModel: SimpleNavigationBarViewModelProtocol,
        flagImageResolver: LanguageFlagImageResolver
    ) {
        self.viewModel = viewModel
        self.navigationBarViewModel = navigationBarViewModel
        self.flagImageResolver = flagImageResolver
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()

        // Load languages
        viewModel.languageSelectorViewModel.loadLanguages()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - Status Bar

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = StyleProvider.Color.backgroundTertiary
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
        let navBarVM = MockSimpleNavigationBarViewModel(
            title: LocalizationProvider.string("change_language"),
            onBackTapped: { viewModel.didTapBack() }
        )
        return LanguageSelectorFullScreenViewController(
            viewModel: viewModel,
            navigationBarViewModel: navBarVM,
            flagImageResolver: DefaultLanguageFlagImageResolver()
        )
    }
}

#endif
