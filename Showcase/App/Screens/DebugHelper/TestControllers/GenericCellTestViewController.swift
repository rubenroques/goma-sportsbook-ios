import UIKit

class GenericCellTestViewController<T: UITableViewCell>: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView: UITableView
    private let cellIdentifier: String
    private let configureCell: (T, IndexPath) -> Void
    private let numberOfRows: Int
    
    init(cellClass: T.Type,
         configureCell: @escaping (T, IndexPath) -> Void,
         numberOfRows: Int = 1) {
        self.tableView = UITableView(frame: .zero, style: .plain)
        self.cellIdentifier = String(describing: cellClass)
        self.configureCell = configureCell
        self.numberOfRows = numberOfRows
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(T.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue cell of type \(T.self)")
        }
        configureCell(cell, indexPath)
        return cell
    }
}
