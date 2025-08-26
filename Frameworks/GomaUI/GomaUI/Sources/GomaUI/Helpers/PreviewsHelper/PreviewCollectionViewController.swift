import UIKit
import SwiftUI

/// A generic UICollectionViewController for use in SwiftUI previews
@available(iOS 17.0, *)
public class PreviewCollectionViewController<Cell: UICollectionViewCell, State: PreviewStateRepresentable>:
    UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties

    /// Collection view for displaying cells
    private var collectionView: UICollectionView!

    /// Cell configurator closure
    public typealias CellConfigurator = (Cell, State, IndexPath) -> Void

    /// The states to display in the collection
    private let states: [State]

    /// Closure for configuring cells
    private let configurator: CellConfigurator

    /// Cell reuse identifier
    private let cellReuseIdentifier: String

    /// Whether to register the cell class
    private let registerCellClass: Bool

    /// Default size for cells
    private let defaultCellSize: CGSize

    /// Spacing between cells
    private let interItemSpacing: CGFloat

    /// Insets for the section
    private let sectionInsets: UIEdgeInsets

    /// Scroll direction
    private let scrollDirection: UICollectionView.ScrollDirection

    // MARK: - Initialization

    /// Initialize with states and a cell configurator
    public init(
        states: [State],
        cellClass: Cell.Type? = nil,
        cellReuseIdentifier: String? = nil,
        defaultCellSize: CGSize = CGSize(width: 100, height: 100),
        interItemSpacing: CGFloat = 10,
        sectionInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
        scrollDirection: UICollectionView.ScrollDirection = .vertical,
        configurator: @escaping CellConfigurator
    ) {
        self.states = states
        self.configurator = configurator
        self.registerCellClass = cellClass != nil
        self.cellReuseIdentifier = cellReuseIdentifier ?? String(describing: Cell.self)
        self.defaultCellSize = defaultCellSize
        self.interItemSpacing = interItemSpacing
        self.sectionInsets = sectionInsets
        self.scrollDirection = scrollDirection
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
    }

    // MARK: - Setup

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemGroupedBackground

        if registerCellClass {
            collectionView.register(Cell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        }
        else {
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "DefaultCell")
        }
    }

    // MARK: - UICollectionView Data Source

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return states.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard registerCellClass else {
            let containerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCell", for: indexPath)
            containerCell.backgroundColor = .clear

            // Clear existing subviews to avoid duplicates
            for subview in containerCell.contentView.subviews {
                subview.removeFromSuperview()
            }

            // Create custom cell manually
            let customCell = Cell(frame: .zero)

            // Configure the cell
            configurator(customCell, states[indexPath.section], indexPath)

            // Add it to the content view
            containerCell.contentView.addSubview(customCell)
            customCell.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                customCell.topAnchor.constraint(equalTo: containerCell.contentView.topAnchor),
                customCell.leadingAnchor.constraint(equalTo: containerCell.contentView.leadingAnchor),
                customCell.trailingAnchor.constraint(equalTo: containerCell.contentView.trailingAnchor),
                customCell.bottomAnchor.constraint(equalTo: containerCell.contentView.bottomAnchor)
            ])

            return containerCell
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? Cell else {
            return UICollectionViewCell()
        }

        configurator(cell, states[indexPath.section], indexPath)
        return cell
    }

    // MARK: - UICollectionView Delegate Flow Layout

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Use state-specific height if available
        if let cellHeight = states[indexPath.section].cellHeight {
            return CGSize(width: defaultCellSize.width, height: cellHeight)
        }
        return defaultCellSize
    }
}

// MARK: - Candy Preview
// In the next lines you will find an example of how to use the PreviewCollectionViewController
// This is a simple example, but you can use it to create more complex previews
/// Represents a candy item in the preview

struct CandyState: PreviewStateRepresentable {
    let title: String
    let subtitle: String?
    let imageName: String
    let cellHeight: CGFloat?

    init(title: String, subtitle: String? = nil, imageName: String, cellHeight: CGFloat? = 120) {
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.cellHeight = cellHeight
    }
}

class CandyCollectionViewCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4

        // Setup Image
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Setup Title Label
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Setup Subtitle Label
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 2
        subtitleLabel.textColor = .gray
        contentView.addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with state: CandyState) {
        titleLabel.text = state.title
        subtitleLabel.text = state.subtitle
        imageView.image = UIImage(systemName: state.imageName) // Placeholder using SF Symbols
    }
}

@available(iOS 17.0, *)
#Preview("Candy Preview Example") {
    PreviewUIViewController {
        PreviewCollectionViewController(
            states: [
                CandyState(title: "Lollipop", subtitle: "Sweet and colorful", imageName: "star.fill"),
                CandyState(title: "Chocolate Bar", subtitle: "Rich and delicious", imageName: "square.fill"),
                CandyState(title: "Gummy Bears", subtitle: "Chewy and fruity", imageName: "circle.fill"),
                CandyState(title: "Caramel Toffee", subtitle: "Soft and buttery", imageName: "heart.fill"),
                CandyState(title: "Peppermint", subtitle: "Minty and fresh", imageName: "bolt.fill")
            ],
            cellClass: CandyCollectionViewCell.self,
            defaultCellSize: CGSize(width: 120, height: 160),
            interItemSpacing: 15,
            scrollDirection: .horizontal
        ) { cell, state, _ in
            cell.configure(with: state)
        }
    }
}
