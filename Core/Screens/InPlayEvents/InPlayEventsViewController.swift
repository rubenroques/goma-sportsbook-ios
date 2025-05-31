import UIKit

// MARK: - InPlayEvent Model
struct InPlayEvent {
    let id: String
    let title: String
    let subtitle: String
    let score: String
    let time: String
    let isLive: Bool
}

// MARK: - InPlayEventsViewModel
class InPlayEventsViewModel {
    private(set) var events: [InPlayEvent] = []
    
    var onEventsUpdated: (() -> Void)?
    
    init() {
        loadDummyEvents()
    }
    
    private func loadDummyEvents() {
        events = [
            InPlayEvent(id: "1", title: "Lakers vs Warriors", subtitle: "NBA Basketball", score: "89-92", time: "Q3 2:45", isLive: true),
            InPlayEvent(id: "2", title: "Patriots vs Chiefs", subtitle: "NFL Football", score: "14-21", time: "Q2 8:12", isLive: true),
            InPlayEvent(id: "3", title: "Barcelona vs Real Madrid", subtitle: "La Liga Soccer", score: "2-1", time: "78'", isLive: true),
            InPlayEvent(id: "4", title: "Celtics vs Heat", subtitle: "NBA Basketball", score: "45-52", time: "Half Time", isLive: false),
            InPlayEvent(id: "5", title: "Yankees vs Red Sox", subtitle: "MLB Baseball", score: "3-5", time: "Bot 7th", isLive: true),
            InPlayEvent(id: "6", title: "Rangers vs Bruins", subtitle: "NHL Hockey", score: "1-2", time: "P2 15:23", isLive: true),
            InPlayEvent(id: "7", title: "Dodgers vs Giants", subtitle: "MLB Baseball", score: "7-4", time: "Top 9th", isLive: true),
            InPlayEvent(id: "8", title: "Cowboys vs Eagles", subtitle: "NFL Football", score: "28-24", time: "Q4 3:45", isLive: true)
        ]
        onEventsUpdated?()
    }
    
    func numberOfEvents() -> Int {
        return events.count
    }
    
    func event(at index: Int) -> InPlayEvent? {
        guard index >= 0 && index < events.count else { return nil }
        return events[index]
    }
}

// MARK: - InPlayEventTableViewCell
class InPlayEventTableViewCell: UITableViewCell {
    static let reuseIdentifier = "InPlayEventTableViewCell"
    
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
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemOrange
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let liveIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let liveLabel: UILabel = {
        let label = UILabel()
        label.text = "LIVE"
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(scoreLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(liveIndicator)
        liveIndicator.addSubview(liveLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: scoreLabel.leadingAnchor, constant: -8),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: scoreLabel.leadingAnchor, constant: -8),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            scoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -12),
            scoreLabel.widthAnchor.constraint(equalToConstant: 60),
            
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: liveIndicator.leadingAnchor, constant: -8),
            timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            liveIndicator.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            liveIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            liveIndicator.widthAnchor.constraint(equalToConstant: 40),
            liveIndicator.heightAnchor.constraint(equalToConstant: 20),
            
            liveLabel.centerXAnchor.constraint(equalTo: liveIndicator.centerXAnchor),
            liveLabel.centerYAnchor.constraint(equalTo: liveIndicator.centerYAnchor)
        ])
    }
    
    func configure(with event: InPlayEvent) {
        titleLabel.text = event.title
        subtitleLabel.text = event.subtitle
        scoreLabel.text = event.score
        timeLabel.text = event.time
        
        liveIndicator.isHidden = !event.isLive
        liveLabel.isHidden = !event.isLive
        
        if event.isLive {
            timeLabel.textColor = .systemRed
            liveIndicator.backgroundColor = .systemRed
        } else {
            timeLabel.textColor = .systemOrange
            liveIndicator.backgroundColor = .systemGray
        }
    }
}

// MARK: - InPlayEventsViewController
class InPlayEventsViewController: UIViewController {
        
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(InPlayEventTableViewCell.self, forCellReuseIdentifier: InPlayEventTableViewCell.reuseIdentifier)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Live Events"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let liveCountLabel: UILabel = {
        let label = UILabel()
        label.text = "8 Live Events"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewModel: InPlayEventsViewModel

    // MARK: Lifetime and cycle
    init(viewModel: InPlayEventsViewModel) {
        self.viewModel = viewModel
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
        
        view.addSubview(titleLabel)
        view.addSubview(liveCountLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            liveCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            liveCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            liveCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: liveCountLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.onEventsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updateLiveCount()
            }
        }
    }
    
    private func updateLiveCount() {
        let liveEvents = viewModel.events.filter { $0.isLive }
        liveCountLabel.text = "\(liveEvents.count) Live Events"
    }
}

// MARK: - UITableViewDataSource
extension InPlayEventsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfEvents()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InPlayEventTableViewCell.reuseIdentifier, for: indexPath) as? InPlayEventTableViewCell,
              let event = viewModel.event(at: indexPath.row) else {
            return UITableViewCell()
        }
        
        cell.configure(with: event)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension InPlayEventsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let event = viewModel.event(at: indexPath.row) {
            print("Selected live event: \(event.title)")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
} 
