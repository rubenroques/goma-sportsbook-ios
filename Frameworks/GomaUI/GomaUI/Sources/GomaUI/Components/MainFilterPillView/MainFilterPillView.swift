import UIKit
import Combine
import SwiftUI

final public class MainFilterPillView: UIView {
    // MARK: - Private Properties
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.allWhite
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    private let filterIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        imageView.image = UIImage(systemName: "line.3.horizontal.decrease.circle.fill")?.withRenderingMode(.alwaysTemplate)
        return imageView
    }()
    
    private let filterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Filter"
        label.font = StyleProvider.fontWith(type: .bold, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = StyleProvider.Color.highlightPrimary
        imageView.image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    private let counterView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        label.font = StyleProvider.fontWith(type: .semibold, size: 10)
        label.textColor = StyleProvider.Color.buttonTextPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let viewModel: MainFilterPillViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    public var onFilterTapped: ((QuickLinkType) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: MainFilterPillViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupSubviews()
        self.setupGestures()
        self.setupPublishers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.cornerRadius = containerView.bounds.height / 2
                
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(filterIconImageView)
        stackView.addArrangedSubview(filterLabel)
        
        stackView.addArrangedSubview(arrowImageView)
        
        containerView.addSubview(counterView)
        
        counterView.addSubview(counterLabel)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 40),
            
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            filterIconImageView.widthAnchor.constraint(equalToConstant: 22),
            filterIconImageView.heightAnchor.constraint(equalToConstant: 22),
            
            arrowImageView.widthAnchor.constraint(equalToConstant: 18),
            arrowImageView.heightAnchor.constraint(equalToConstant: 18),
            
            counterView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            counterView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -4),
            counterView.widthAnchor.constraint(equalToConstant: 16),
            counterView.heightAnchor.constraint(equalTo: counterView.widthAnchor),
            
            counterLabel.leadingAnchor.constraint(equalTo: counterView.leadingAnchor, constant: 1),
            counterLabel.trailingAnchor.constraint(equalTo: counterView.trailingAnchor, constant: -1),
            counterLabel.centerYAnchor.constraint(equalTo: counterView.centerYAnchor)
            
        ])
        
        filterLabel.text = viewModel.mainFilterSubject.value.title
        
        if let filterIcon = viewModel.mainFilterSubject.value.icon {
            filterIconImageView.image = UIImage(named: filterIcon)
        }
        
        if let actionIcon = viewModel.mainFilterSubject.value.actionIcon {
            arrowImageView.image = UIImage(named: actionIcon)
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    private func setupPublishers() {
        
        viewModel.mainFilterState
            .sink(receiveValue: { [weak self] filterState in
                
                switch filterState {
                case .notSelected:
                    self?.counterView.isHidden = true
                case .selected(let selections):
                    self?.counterView.isHidden = false
                    self?.counterLabel.text = selections
                }
            })
            .store(in: &cancellables)
    }
    
    @objc private func handleTap() {
        let mainFilterType = self.viewModel.didTapMainFilterItem()
                
        onFilterTapped(mainFilterType)
    }
    
    // MARK: - Public Methods
    public func setFilterState(filterState: MainFilterStateType) {
        viewModel.mainFilterState.send(filterState)
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Main Filter View") {
    PreviewUIView {
        let containerView = UIView()
        containerView.backgroundColor = StyleProvider.Color.highlightPrimary
        
        let mainFilter = MainFilterItem(type: .mainFilter, title: "Filter")
        
        let viewModel = MockMainFilterPillViewModel(mainFilter: mainFilter)
        
        let filterView = MainFilterPillView(viewModel: viewModel)
        
        filterView.onFilterTapped = { mainFilterType in
            print("Filter tapped: \(mainFilterType)")
        }
        
        containerView.addSubview(filterView)
        
        // Position the filter view on the right side
        filterView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            filterView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16)
        ])
        
        return containerView
    }
    .frame(height: 80)
}
#endif
