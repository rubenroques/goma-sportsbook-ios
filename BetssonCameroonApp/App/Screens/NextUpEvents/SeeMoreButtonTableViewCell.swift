import UIKit
import GomaUI
import Combine

/// Table view cell wrapper for SeeMoreButtonView component
final class SeeMoreButtonTableViewCell: UITableViewCell {

    // MARK: - UI Elements

    private let seeMoreButtonView: SeeMoreButtonView

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private var currentViewModel: SeeMoreButtonViewModelProtocol?

    // MARK: - Cell Identifier
    static let identifier = "SeeMoreButtonTableViewCell"

    // MARK: - Callbacks

    /// Callback fired when the see more button is tapped
    var onSeeMoreTapped: (() -> Void) {
        get { seeMoreButtonView.onButtonTapped }
        set { seeMoreButtonView.onButtonTapped = newValue }
    }

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.seeMoreButtonView = SeeMoreButtonView(viewModel: MockSeeMoreButtonViewModel.defaultMock)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupCell() {
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        seeMoreButtonView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(seeMoreButtonView)

        NSLayoutConstraint.activate([
            seeMoreButtonView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            seeMoreButtonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            seeMoreButtonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            seeMoreButtonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            seeMoreButtonView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Configuration

    /// Configure the cell with a SeeMoreButton ViewModel
    func configure(with viewModel: SeeMoreButtonViewModelProtocol?) {
        cancellables.removeAll()
        currentViewModel = viewModel
        seeMoreButtonView.configure(with: viewModel)
    }

    /// Configure with button data and state (convenience method)
    func configure(
        with buttonData: SeeMoreButtonData,
        isLoading: Bool = false,
        isEnabled: Bool = true
    ) {
        let mockViewModel = MockSeeMoreButtonViewModel(
            buttonData: buttonData,
            isLoading: isLoading,
            isEnabled: isEnabled
        )
        configure(with: mockViewModel)
    }

    // MARK: - Cell Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()

        cancellables.removeAll()
        currentViewModel = nil
        seeMoreButtonView.configure(with: nil)
        onSeeMoreTapped = { }
    }
}
