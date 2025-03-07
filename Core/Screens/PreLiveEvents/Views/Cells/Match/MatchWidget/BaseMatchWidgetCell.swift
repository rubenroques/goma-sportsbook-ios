import UIKit
import Combine
import Kingfisher
import ServicesProvider

class BaseMatchWidgetCell: UITableViewCell {
    // MARK: - Private Properties
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var baseStackView: UIStackView = Self.createBaseStackView()
    private lazy var topImageBaseView: UIView = Self.createTopImageBaseView()
    private lazy var topImageView: UIImageView = Self.createTopImageView()
    private lazy var mainContentBaseView: UIView = Self.createMainContentBaseView()
    private lazy var boostedOddBottomLineView: UIView = Self.createBoostedOddBottomLineView()

    private var cancellables: Set<AnyCancellable> = []


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset any properties that need to be reset
    }

    // MARK: - Configuration
    func configure(with viewModel: MatchWidgetCellViewModelProtocol) {
        // Configure cell based on state
        // For now, just implement a basic version to make the preview work
        viewModel.sportIconImagePublisher.sink { [weak self] image in
            self?.topImageView.image = image
        }
        .store(in: &cancellables)
    }
    // MARK: - Setup
    private func setupSubviews() {
        contentView.addSubview(baseView)
        baseView.addSubview(baseStackView)

        baseStackView.addArrangedSubview(topImageBaseView)
        baseStackView.addArrangedSubview(mainContentBaseView)
        baseStackView.addArrangedSubview(boostedOddBottomLineView)

        topImageBaseView.addSubview(topImageView)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Base view constraints (fills contentView)
            baseView.topAnchor.constraint(equalTo: contentView.topAnchor),
            baseView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            baseView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // Base stack view constraints (fills baseView)
            baseStackView.topAnchor.constraint(equalTo: baseView.topAnchor),
            baseStackView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            baseStackView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
            baseStackView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),

            // Top image view constraints
            topImageView.topAnchor.constraint(equalTo: topImageBaseView.topAnchor, constant: 2),
            topImageView.leadingAnchor.constraint(equalTo: topImageBaseView.leadingAnchor, constant: 2),
            topImageView.trailingAnchor.constraint(equalTo: topImageBaseView.trailingAnchor, constant: -2),
            topImageView.bottomAnchor.constraint(equalTo: topImageBaseView.bottomAnchor),

            // Set height for top image view - matching the XIB setting
            topImageBaseView.heightAnchor.constraint(equalToConstant: 100),

            // Set height for boosted odd bottom line
            boostedOddBottomLineView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
}

// MARK: - Factory Methods
private extension BaseMatchWidgetCell {
    static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }

    static func createBaseStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }

    static func createTopImageBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    static func createTopImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        return imageView
    }

    static func createMainContentBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    static func createBoostedOddBottomLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemOrange // Matching color from XIB
        return view
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI

extension MockMatchWidgetCellViewModel: PreviewStateRepresentable {
    var title: String {
        return "\(self.match.homeParticipant.name) vs \(self.match.homeParticipant.name) [\(self.matchWidgetType.rawValue)]"
    }
}

@available(iOS 17.0, *)
#Preview("BaseMatchWidgetCellState Example") {
    PreviewUIViewController {
        PreviewTableViewController(
            states: [
                MockMatchWidgetCellViewModel(
                    match: PreviewModelsHelper.createFootballMatch(),
                    matchWidgetType: MatchWidgetType.normal,
                    matchWidgetStatus: MatchWidgetStatus.preLive
                ),
                MockMatchWidgetCellViewModel(
                    match: PreviewModelsHelper.createFootballMatch(),
                    matchWidgetType: MatchWidgetType.topImageWithMixMatch,
                    matchWidgetStatus: MatchWidgetStatus.preLive
                ),
                MockMatchWidgetCellViewModel(
                    match: PreviewModelsHelper.createFootballMatch(),
                    matchWidgetType: MatchWidgetType.boosted,
                    matchWidgetStatus: MatchWidgetStatus.preLive
                ),
                MockMatchWidgetCellViewModel(
                    match: PreviewModelsHelper.createFootballMatch(),
                    matchWidgetType: MatchWidgetType.backgroundImage,
                    matchWidgetStatus: MatchWidgetStatus.preLive
                ),
            ],
            cellClass: BaseMatchWidgetCell.self,
            defaultCellHeight: 180
        ) { (cell: BaseMatchWidgetCell, state: MockMatchWidgetCellViewModel, indexPath: IndexPath) in
            cell.configure(with: state)
        }
    }
}


@available(iOS 17.0, *)
#Preview("BaseMatchWidgetCellState Example2") {
    PreviewUIViewController {
        PreviewTableViewController<BaseMatchWidgetCell, MockMatchWidgetCellViewModel>(
            states: [
                MockMatchWidgetCellViewModel(
                    match: PreviewModelsHelper.createFootballMatch(),
                    matchWidgetType: MatchWidgetType.normal,
                    matchWidgetStatus: MatchWidgetStatus.preLive
                )
            ],
            cellClass: BaseMatchWidgetCell.self,
            defaultCellHeight: 180
        ) { (cell: BaseMatchWidgetCell, state: MockMatchWidgetCellViewModel, indexPath: IndexPath) in
            cell.configure(with: state)
        }
    }
}


#endif
