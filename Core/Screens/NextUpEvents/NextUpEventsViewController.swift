import UIKit
import GomaUI
import Combine
import ServicesProvider

// MARK: - NextUpEventsViewModel
class NextUpEventsViewModel {

    var sportType: SportType
    var eventsState: AnyPublisher<LoadableContent<[Match]>, Never> {
        return self.eventsStateSubject.eraseToAnyPublisher()
    }

    var quickLinksTabBarViewModel: QuickLinksTabBarViewModelProtocol

    private var eventsStateSubject = CurrentValueSubject<LoadableContent<[Match]>, Never>.init(.loading)
    private var cancellables: Set<AnyCancellable> = []

    private var preLiveMatchesCancellable: AnyCancellable?

    init(sportType: SportType = SportType.defaultFootball) {
        self.sportType = sportType
        self.quickLinksTabBarViewModel = MockQuickLinksTabBarViewModel.sportsMockViewModel
    }

    func reloadEvents(forced: Bool = false) {
        self.loadEvents()
    }

    private func loadEvents() {
        self.eventsStateSubject.send(.loading)

        self.preLiveMatchesCancellable?.cancel()

        self.preLiveMatchesCancellable = Env.servicesProvider.subscribePreLiveMatches(
            forSportType: self.sportType,
            sortType: EventListSort.popular)
        .receive(on: DispatchQueue.main)
        .sink { completion in
            print("subscribePreLiveMatches \(completion)")
        } receiveValue: { [weak self] (subscribableContent: SubscribableContent<[EventsGroup]>) in
            switch subscribableContent {
            case .connected(let subscription):
                print("Connected to pre-live matches subscription \(subscription.id)")
                break

            case .contentUpdate(let content):
                let matches = ServiceProviderModelMapper.matches(fromEventsGroups: content)
                self?.process(matches: matches)

            case .disconnected:
                print("Disconnected from pre-live matches subscription")
                break
            }
        }
    }

    private func process(matches: [Match]) {
        self.eventsStateSubject.send(LoadableContent.loaded(matches))
    }
}

// MARK: - NextUpEventsViewController
class NextUpEventsViewController: UIViewController {

    private let quickLinksTabBarView: QuickLinksTabBarView!
    private let tableView: UITableView!
    private let loadingIndicator: UIActivityIndicatorView!
    private let errorView: UIView!
    private let errorImageView: UIImageView!

    private let viewModel: NextUpEventsViewModel
    private var matches: [Match] = []

    private var cancellables: Set<AnyCancellable> = []

    // MARK: Lifetime and cycle
    init(viewModel: NextUpEventsViewModel) {
        self.viewModel = viewModel

        self.quickLinksTabBarView = QuickLinksTabBarView(viewModel: viewModel.quickLinksTabBarViewModel)

        self.tableView = UITableView()
        self.tableView.translatesAutoresizingMaskIntoConstraints = false

        self.loadingIndicator = UIActivityIndicatorView(style: .large)
        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicator.hidesWhenStopped = true

        self.errorView = UIView()
        self.errorView.translatesAutoresizingMaskIntoConstraints = false
        self.errorView.isHidden = true

        self.errorImageView = UIImageView()
        self.errorImageView.translatesAutoresizingMaskIntoConstraints = false
        self.errorImageView.contentMode = .scaleAspectFit

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTableView()
        setupBindings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.reloadEvents()
    }

    private func setupViews() {
        view.backgroundColor = .systemBackground

        view.addSubview(quickLinksTabBarView)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorView)

        errorView.addSubview(errorImageView)

        NSLayoutConstraint.activate([
            quickLinksTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quickLinksTabBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            quickLinksTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: quickLinksTabBarView.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.topAnchor.constraint(equalTo: quickLinksTabBarView.bottomAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            errorImageView.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorImageView.centerYAnchor.constraint(equalTo: errorView.centerYAnchor),
            errorImageView.widthAnchor.constraint(equalToConstant: 100),
            errorImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MatchCell")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    public func setupWithTheme() {
        self.quickLinksTabBarView.updateTheme()
    }

    private func setupBindings() {
        self.viewModel.eventsState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (loadableContent: LoadableContent<[Match]>) in
                switch loadableContent {
                case .idle:
                    self?.loadingIndicator.stopAnimating()
                    self?.tableView.isHidden = true
                    self?.errorView.isHidden = true

                case .loading:
                    self?.loadingIndicator.startAnimating()
                    self?.tableView.isHidden = true
                    self?.errorView.isHidden = true

                case .loaded(let matches):
                    self?.loadingIndicator.stopAnimating()
                    self?.tableView.isHidden = false
                    self?.errorView.isHidden = true
                    self?.matches = matches
                    self?.tableView.reloadData()
                    print("Loaded \(matches.count) matches")

                case .failed:
                    self?.loadingIndicator.stopAnimating()
                    self?.tableView.isHidden = true
                    self?.errorView.isHidden = false
                    print("Failed to load matches")
                }
            }
            .store(in: &self.cancellables)
    }
}

// MARK: - UITableViewDataSource
extension NextUpEventsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath)
        let match = matches[indexPath.row]

        // Simple display to check if data is arriving
        cell.textLabel?.text = "\(match.homeParticipant.name) vs \(match.awayParticipant)"
        cell.detailTextLabel?.text = "\(match.markets.count)"

        return cell
    }
}

