
import UIKit
import Combine
import GomaUI

class MyBetsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: MyBetsViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var pillSelectorBarView: PillSelectorBarView = {
        let view = PillSelectorBarView(viewModel: viewModel.pillSelectorBarViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var marketGroupSelectorTabView: MarketGroupSelectorTabView = {
        let view = MarketGroupSelectorTabView(
            viewModel: viewModel.marketGroupSelectorTabViewModel,
            backgroundStyle: .light
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    // MARK: - Navigation Closures
    
    var onLoginRequested: (() -> Void)?
    
    // MARK: - Initialization
    
    init(viewModel: MyBetsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    func refreshData() {
        // Reserved for future implementation
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(marketGroupSelectorTabView)
        view.addSubview(pillSelectorBarView)
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            marketGroupSelectorTabView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            marketGroupSelectorTabView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            marketGroupSelectorTabView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            marketGroupSelectorTabView.heightAnchor.constraint(equalToConstant: 42),
            
            pillSelectorBarView.topAnchor.constraint(equalTo: marketGroupSelectorTabView.bottomAnchor),
            pillSelectorBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pillSelectorBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pillSelectorBarView.heightAnchor.constraint(equalToConstant: 60),
            
            contentView.topAnchor.constraint(equalTo: pillSelectorBarView.bottomAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.selectedTabTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedTab in
                print("🎯 MyBets: Selected tab changed to \(selectedTab.title)")
                // Future: Update content based on selected tab
            }
            .store(in: &cancellables)
        
        viewModel.selectedStatusTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedStatus in
                print("🎯 MyBets: Selected status changed to \(selectedStatus.title)")
                // Future: Update content based on selected status
            }
            .store(in: &cancellables)
    }
}
