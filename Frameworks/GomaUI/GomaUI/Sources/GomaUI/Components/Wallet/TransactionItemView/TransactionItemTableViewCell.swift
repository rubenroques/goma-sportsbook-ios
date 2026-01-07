import UIKit

public final class TransactionItemTableViewCell: UITableViewCell {

    // MARK: - Constants

    private struct Constants {
        static let horizontalInset: CGFloat = 0
        static let verticalInset: CGFloat = 0
    }

    // MARK: - Properties

    private lazy var transactionItemView: TransactionItemView = {
        let view = TransactionItemView(viewModel: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Cell Identifier

    public static let identifier = "TransactionItemTableViewCell"

    // MARK: - Initialization

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    // MARK: - Cell Lifecycle

    public override func prepareForReuse() {
        super.prepareForReuse()

        // Reset the transaction view with nil viewModel to clear content
        transactionItemView.configure(with: nil)
    }

    // MARK: - Setup

    private func setupCell() {
        // Clear background and selection
        contentView.backgroundColor = StyleProvider.Color.backgroundPrimary
        backgroundColor = StyleProvider.Color.backgroundPrimary
        selectionStyle = .none

        // Add transaction item view to content view
        contentView.addSubview(transactionItemView)

        // Setup constraints
        NSLayoutConstraint.activate([
            transactionItemView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalInset),
            transactionItemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            transactionItemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset),
            transactionItemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalInset)
        ])
    }

    // MARK: - Configuration

    public func configure(
        with viewModel: TransactionItemViewModelProtocol?,
        cornerRadiusStyle: TransactionCornerRadiusStyle,
        isFirstCell: Bool = false,
        isLastCell: Bool = false
    ) {
        // Configure the transaction item view with the viewModel and corner radius
        transactionItemView.configure(with: viewModel, cornerRadiusStyle: cornerRadiusStyle)
    }
}