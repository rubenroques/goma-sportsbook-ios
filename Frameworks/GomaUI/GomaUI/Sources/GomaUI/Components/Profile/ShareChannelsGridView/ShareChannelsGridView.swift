import UIKit
import Combine
import SwiftUI

public final class ShareChannelsGridView: UIView {

    // MARK: - Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var mainStackView: UIStackView = Self.createMainStackView()
    private lazy var topRowStackView: UIStackView = Self.createRowStackView()
    private lazy var bottomRowStackView: UIStackView = Self.createRowStackView()

    // MARK: - Properties
    private let viewModel: ShareChannelsGridViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var buttonViews: [ShareChannelButtonView] = []

    // MARK: - Initialization
    public init(viewModel: ShareChannelsGridViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        commonInit()
        setupWithTheme()
        setupBindings()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:) instead")
    }

    private func commonInit() {
        setupSubviews()
    }

    private func setupWithTheme() {
        backgroundColor = .clear
    }

    // MARK: - Setup
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.updateChannels(data.channels)
            }
            .store(in: &cancellables)
    }

    private func updateChannels(_ channels: [ShareChannel]) {
        // Clear existing buttons
        clearButtonViews()

        // Create new button views
        buttonViews = channels.map { channel in
            let button = ShareChannelButtonView()
            button.configure(with: channel) { [weak self] in
                self?.handleChannelTapped(channel.type)
            }
            return button
        }

        // Distribute buttons across rows
        // Top row: first 5 buttons, Bottom row: remaining buttons
        let topRowChannels = Array(buttonViews.prefix(5))
        let bottomRowChannels = Array(buttonViews.dropFirst(5))

        // Add to top row
        topRowChannels.forEach { button in
            topRowStackView.addArrangedSubview(button)
        }

        // Add spacers if needed to maintain layout
        let topRowSpacersNeeded = max(0, 5 - topRowChannels.count)
        for _ in 0..<topRowSpacersNeeded {
            let spacer = Self.createSpacerView()
            topRowStackView.addArrangedSubview(spacer)
        }

        // Add to bottom row
        bottomRowChannels.forEach { button in
            bottomRowStackView.addArrangedSubview(button)
        }

        // Add spacers if needed to maintain layout
        let bottomRowSpacersNeeded = max(0, 5 - bottomRowChannels.count)
        for _ in 0..<bottomRowSpacersNeeded {
            let spacer = Self.createSpacerView()
            bottomRowStackView.addArrangedSubview(spacer)
        }

        // Show/hide rows based on content
        topRowStackView.isHidden = topRowChannels.isEmpty
        bottomRowStackView.isHidden = bottomRowChannels.isEmpty
    }

    private func clearButtonViews() {
        buttonViews.forEach { $0.removeFromSuperview() }
        buttonViews.removeAll()

        topRowStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        bottomRowStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    private func handleChannelTapped(_ channelType: ShareChannelType) {
        viewModel.onChannelSelected?(channelType)
    }
}

// MARK: - Subviews Initialization and Setup
extension ShareChannelsGridView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMainStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        return stackView
    }

    private static func createRowStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }

    private static func createSpacerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(mainStackView)

        mainStackView.addArrangedSubview(topRowStackView)
        mainStackView.addArrangedSubview(bottomRowStackView)

        initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            // Main stack
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

#Preview("All Channels") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockShareChannelsGridViewModel.allChannelsMock
        mockViewModel.onChannelSelected = { channel in
            print("Selected: \(channel.title)")
        }
        let gridView = ShareChannelsGridView(viewModel: mockViewModel)
        gridView.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = .darkGray
        vc.view.addSubview(gridView)

        NSLayoutConstraint.activate([
            gridView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            gridView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            gridView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

#Preview("Social Only") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockShareChannelsGridViewModel.socialOnlyMock
        mockViewModel.onChannelSelected = { channel in
            print("Selected: \(channel.title)")
        }
        let gridView = ShareChannelsGridView(viewModel: mockViewModel)
        gridView.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(gridView)

        NSLayoutConstraint.activate([
            gridView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            gridView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            gridView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

#Preview("Limited Channels") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockShareChannelsGridViewModel.limitedMock
        mockViewModel.onChannelSelected = { channel in
            print("Selected: \(channel.title)")
        }
        let gridView = ShareChannelsGridView(viewModel: mockViewModel)
        gridView.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(gridView)

        NSLayoutConstraint.activate([
            gridView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            gridView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            gridView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

#Preview("With Disabled") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockShareChannelsGridViewModel.withDisabledMock
        mockViewModel.onChannelSelected = { channel in
            print("Selected: \(channel.title)")
        }
        let gridView = ShareChannelsGridView(viewModel: mockViewModel)
        gridView.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(gridView)

        NSLayoutConstraint.activate([
            gridView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            gridView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            gridView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

#Preview("Messaging Only") {
    PreviewUIViewController {
        let vc = UIViewController()
        let mockViewModel = MockShareChannelsGridViewModel.messagingOnlyMock
        mockViewModel.onChannelSelected = { channel in
            print("Selected: \(channel.title)")
        }
        let gridView = ShareChannelsGridView(viewModel: mockViewModel)
        gridView.translatesAutoresizingMaskIntoConstraints = false

        vc.view.backgroundColor = StyleProvider.Color.backgroundTertiary
        vc.view.addSubview(gridView)

        NSLayoutConstraint.activate([
            gridView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            gridView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            gridView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }
}

#endif
