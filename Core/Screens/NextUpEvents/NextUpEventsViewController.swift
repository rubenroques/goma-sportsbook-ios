import UIKit
import GomaUI

// MARK: - Event Model
struct Event {
    let id: String
    let title: String
    let subtitle: String
    let time: String
}

// MARK: - NextUpEventsViewModel
class NextUpEventsViewModel {
    private(set) var events: [Event] = []

    var onEventsUpdated: (() -> Void)?

    var quickLinksTabBarViewModel: QuickLinksTabBarViewModelProtocol
    init() {
        self.quickLinksTabBarViewModel = MockQuickLinksTabBarViewModel.sportsMockViewModel
        
        self.loadDummyEvents()
    }

    private func loadDummyEvents() {
        events = [
            Event(id: "1", title: "Lakers vs Warriors", subtitle: "NBA Basketball", time: "7:30 PM"),
            Event(id: "2", title: "Patriots vs Chiefs", subtitle: "NFL Football", time: "8:00 PM"),
            Event(id: "3", title: "Barcelona vs Real Madrid", subtitle: "La Liga Soccer", time: "9:15 PM"),
            Event(id: "4", title: "Celtics vs Heat", subtitle: "NBA Basketball", time: "10:00 PM"),
            Event(id: "5", title: "Yankees vs Red Sox", subtitle: "MLB Baseball", time: "7:00 PM"),
            Event(id: "6", title: "Rangers vs Bruins", subtitle: "NHL Hockey", time: "7:30 PM"),
            Event(id: "7", title: "Dodgers vs Giants", subtitle: "MLB Baseball", time: "8:30 PM"),
            Event(id: "8", title: "Cowboys vs Eagles", subtitle: "NFL Football", time: "4:30 PM")
        ]
        onEventsUpdated?()
    }

    func numberOfEvents() -> Int {
        return events.count
    }

    func event(at index: Int) -> Event? {
        guard index >= 0 && index < events.count else { return nil }
        return events[index]
    }
}

// MARK: - EventTableViewCell
class EventTableViewCell: UITableViewCell {
    static let reuseIdentifier = "EventTableViewCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemBlue
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(timeLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }

    func configure(with event: Event) {
        titleLabel.text = event.title
        subtitleLabel.text = event.subtitle
        timeLabel.text = event.time
    }
    
}

// MARK: - NextUpEventsViewController
class NextUpEventsViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.reuseIdentifier)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let quickLinksTabBarView: QuickLinksTabBarView!

    private let viewModel: NextUpEventsViewModel

    // MARK: Lifetime and cycle
    init(viewModel: NextUpEventsViewModel) {
        self.viewModel = viewModel
        
        self.quickLinksTabBarView = QuickLinksTabBarView(viewModel: viewModel.quickLinksTabBarViewModel)
        
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
    }

    private func setupViews() {
        view.backgroundColor = .systemBackground

        view.addSubview(quickLinksTabBarView)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            quickLinksTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quickLinksTabBarView.topAnchor.constraint(equalTo: view.topAnchor),
            quickLinksTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: quickLinksTabBarView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    public func setupWithTheme() {
        self.quickLinksTabBarView.updateTheme()
    }

    private func setupBindings() {
        viewModel.onEventsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension NextUpEventsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfEvents()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.reuseIdentifier, for: indexPath) as? EventTableViewCell,
              let event = viewModel.event(at: indexPath.row) else {
            return UITableViewCell()
        }

        cell.configure(with: event)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NextUpEventsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let event = viewModel.event(at: indexPath.row) {
            print("Selected event: \(event.title)")
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
