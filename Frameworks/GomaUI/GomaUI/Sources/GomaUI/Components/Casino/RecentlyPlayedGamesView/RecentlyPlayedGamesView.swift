import UIKit
import Combine
import SwiftUI

final public class RecentlyPlayedGamesView: UIView {
    
    // MARK: - Constants
    private enum Constants {
        static let verticalPadding: CGFloat = 16.0
        static let horizontalPadding: CGFloat = 16.0
        static let cellSpacing: CGFloat = 12.0
        static let collectionHeight: CGFloat = 56.0
        static let pillHeight: CGFloat = 32.0
        static let pillHorizontalPadding: CGFloat = 16.0
    }
    
    // MARK: - UI Elements
    private let stackView = UIStackView()
    private let headerContainer = UIView()
    private let pillView = UIView()
    private let pillLabel = UILabel()
    private let collectionView: UICollectionView
    
    // MARK: - Properties
    private var viewModel: RecentlyPlayedGamesViewModelProtocol?
    private var cancellables = Set<AnyCancellable>()
    private var games: [RecentlyPlayedGameData] = []
    
    // MARK: - Callbacks
    public var onGameSelected: ((String) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: RecentlyPlayedGamesViewModelProtocol? = nil) {
        // Create collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 210, height: Constants.collectionHeight)
        layout.minimumInteritemSpacing = Constants.cellSpacing
        layout.minimumLineSpacing = Constants.cellSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: Constants.horizontalPadding,
            bottom: 0,
            right: Constants.horizontalPadding
        )
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        setupSubviews()
        configure(with: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Configuration
    public func configure(with viewModel: RecentlyPlayedGamesViewModelProtocol?) {
        // Clear existing bindings
        cancellables.removeAll()
        self.viewModel = viewModel
        
        if let viewModel = viewModel {
            setupBindings(with: viewModel)
        } else {
            renderPlaceholderState()
        }
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = StyleProvider.Color.backgroundPrimary
        
        // Main stack view
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        setupHeader()
        setupCollectionView()
        setupConstraints()
    }
    
    private func setupHeader() {
        // Header container for pill view
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(headerContainer)
        
        // Pill view setup
        pillView.backgroundColor = StyleProvider.Color.highlightPrimary
        pillView.layer.cornerRadius = Constants.pillHeight / 2
        pillView.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(pillView)
        
        // Pill label setup
        pillLabel.font = StyleProvider.fontWith(type: .bold, size: 12)
        pillLabel.textColor = StyleProvider.Color.buttonTextPrimary
        pillLabel.text = LocalizationProvider.string("recently_played")
        pillLabel.translatesAutoresizingMaskIntoConstraints = false
        pillView.addSubview(pillLabel)
        
        NSLayoutConstraint.activate([
            // Pill view
            pillView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            pillView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: Constants.horizontalPadding),
            pillView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            pillView.heightAnchor.constraint(equalToConstant: Constants.pillHeight),
            
            // Pill label
            pillLabel.centerXAnchor.constraint(equalTo: pillView.centerXAnchor),
            pillLabel.centerYAnchor.constraint(equalTo: pillView.centerYAnchor),
            pillLabel.leadingAnchor.constraint(equalTo: pillView.leadingAnchor, constant: Constants.pillHorizontalPadding),
            pillLabel.trailingAnchor.constraint(equalTo: pillView.trailingAnchor, constant: -Constants.pillHorizontalPadding)
        ])
    }
    
    private func setupCollectionView() {
        // Collection view setup
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Register cell
        collectionView.register(RecentlyPlayedGameCollectionViewCell.self, forCellWithReuseIdentifier: "GameCell")
        
        // Set delegates
        collectionView.dataSource = self
        collectionView.delegate = self
        
        stackView.addArrangedSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Stack view
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalPadding),
            
            // Collection view height
            collectionView.heightAnchor.constraint(equalToConstant: Constants.collectionHeight)
        ])
    }
    
    // MARK: - Bindings
    private func setupBindings(with viewModel: RecentlyPlayedGamesViewModelProtocol) {
        // Games list
        viewModel.gamesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] games in
                self?.games = games
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        // Title (updates pill label)
        viewModel.titlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.pillLabel.text = title
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    private func renderPlaceholderState() {
        pillLabel.text = LocalizationProvider.string("recently_played")
        games = []
        collectionView.reloadData()
    }
}

// MARK: - Collection View Data Source
extension RecentlyPlayedGamesView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.isEmpty ? 3 : games.count // Show 3 placeholder cells when empty
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCell", for: indexPath) as! RecentlyPlayedGameCollectionViewCell
        
        if games.isEmpty {
            // Configure placeholder cell
            cell.configure(with: nil)
        } else {
            // Configure with actual game data
            let gameData = games[indexPath.item]
            cell.configure(with: gameData)
        }
        
        // Set callback
        cell.onGameSelected = { [weak self] gameId in
            self?.onGameSelected(gameId)
            self?.viewModel?.gameSelected(gameId)
        }
        
        return cell
    }
}

// MARK: - Collection View Delegate
extension RecentlyPlayedGamesView: UICollectionViewDelegate {
    // Additional delegate methods can be added here if needed
}

// MARK: - Collection View Cell
private class RecentlyPlayedGameCollectionViewCell: UICollectionViewCell {
    
    private let gameView = RecentlyPlayedGamesCellView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        gameView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gameView)
        
        NSLayoutConstraint.activate([
            gameView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gameView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with gameData: RecentlyPlayedGameData?) {
        gameView.configure(with: gameData)
    }
    
    var onGameSelected: ((String) -> Void) {
        get { gameView.onGameSelected }
        set { gameView.onGameSelected = newValue }
    }
}

// MARK: - Preview Provider
#if DEBUG

#Preview("Recently Played Games - Placeholder") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor
        
        let recentlyPlayedView = RecentlyPlayedGamesView() // No viewModel - placeholder state
        recentlyPlayedView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(recentlyPlayedView)
        
        NSLayoutConstraint.activate([
            recentlyPlayedView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            recentlyPlayedView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            recentlyPlayedView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor)
        ])
        
        return vc
    }
}

#endif
