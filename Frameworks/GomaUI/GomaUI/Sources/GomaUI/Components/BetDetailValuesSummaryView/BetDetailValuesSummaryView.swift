import UIKit
import Combine
import SwiftUI

public class BetDetailValuesSummaryView: UIView {
    
    // MARK: - Properties
    private let viewModel: BetDetailValuesSummaryViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .green
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        
        stackView.layer.cornerRadius = 8
        stackView.clipsToBounds = true
        return stackView
    }()
    
    // Header container
    private let headerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        view.layer.cornerRadius = 0
        view.isHidden = true
        return view
    }()
    
    private var headerRowView: BetDetailRowView?
    
    // Content container
    private let contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        view.layer.cornerRadius = 0
        return view
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.distribution = .fill
        stackView.layer.cornerRadius = 0
        stackView.clipsToBounds = true
        return stackView
    }()
    
    // Footer container
    private let footerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        view.layer.cornerRadius = 0
        view.isHidden = true
        return view
    }()
    
    private var footerRowView: BetDetailRowView?
    
    // MARK: - Initialization
    public init(viewModel: BetDetailValuesSummaryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        addSubview(mainStackView)
        
        // Add containers to main stack
        mainStackView.addArrangedSubview(headerContainerView)
        mainStackView.addArrangedSubview(contentContainerView)
        mainStackView.addArrangedSubview(footerContainerView)
        
        // Setup content container
        contentContainerView.addSubview(contentStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Main stack view constraints
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Content stack view constraints (inside content container)
            contentStackView.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 8),
            contentStackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 8),
            contentStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -8),
            contentStackView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor, constant: -8)
        ])
    }
    
    private func bindViewModel() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.updateUI(with: data)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Updates
    private func updateUI(with data: BetDetailValuesSummaryData) {
        // Clear existing content
        clearAllContent()
        
        // Setup header section
        setupHeaderSection(with: data.headerRow)
        
        // Setup content section
        setupContentSection(with: data.contentRows)
        
        // Setup footer section
        setupFooterSection(with: data.footerRow)
    }
    
    private func clearAllContent() {
        // Remove existing header row
        headerRowView?.removeFromSuperview()
        headerRowView = nil
        
        // Remove existing content rows
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Remove existing footer row
        footerRowView?.removeFromSuperview()
        footerRowView = nil
    }
    
    private func setupHeaderSection(with headerRowData: BetDetailRowData?) {
        guard let headerRowData = headerRowData else {
            headerContainerView.isHidden = true
            return
        }
        
        let headerViewModel = MockBetDetailRowViewModel()
        headerViewModel.updateData(headerRowData)
        
        let headerView = BetDetailRowView(viewModel: headerViewModel, cornerStyle: .all(radius: 8))
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: headerContainerView.topAnchor, constant: 8),
            headerView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 8),
            headerView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -8),
            headerView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -4)
        ])
        
        headerRowView = headerView
        headerContainerView.isHidden = false
    }
    
    private func setupContentSection(with contentRowsData: [BetDetailRowData]) {
        for (index, rowData) in contentRowsData.enumerated() {
            let rowViewModel = MockBetDetailRowViewModel()
            rowViewModel.updateData(rowData)
            
            // Determine corner style for content rows
            let cornerStyle: BetDetailRowCornerStyle
            if contentRowsData.count == 1 {
                cornerStyle = .none // Container handles corners
            } else if index == 0 {
                cornerStyle = .topOnly(radius: 8)
            } else if index == contentRowsData.count - 1 {
                cornerStyle = .bottomOnly(radius: 8)
            } else {
                cornerStyle = .none
            }
            
            let rowView = BetDetailRowView(viewModel: rowViewModel, cornerStyle: cornerStyle)
            contentStackView.addArrangedSubview(rowView)
        }
    }
    
    private func setupFooterSection(with footerRowData: BetDetailRowData?) {
        guard let footerRowData = footerRowData else {
            footerContainerView.isHidden = true
            return
        }
        
        let footerViewModel = MockBetDetailRowViewModel()
        footerViewModel.updateData(footerRowData)
        
        let footerView = BetDetailRowView(viewModel: footerViewModel, cornerStyle: .all(radius: 8))
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerContainerView.addSubview(footerView)
        
        NSLayoutConstraint.activate([
            footerView.topAnchor.constraint(equalTo: footerContainerView.topAnchor, constant: 4),
            footerView.leadingAnchor.constraint(equalTo: footerContainerView.leadingAnchor, constant: 8),
            footerView.trailingAnchor.constraint(equalTo: footerContainerView.trailingAnchor, constant: -8),
            footerView.bottomAnchor.constraint(equalTo: footerContainerView.bottomAnchor, constant: -8)
        ])
        
        footerRowView = footerView
        footerContainerView.isHidden = false
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("Bet Values Summary - Full Details") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .red
        
        let valuesSummaryView = BetDetailValuesSummaryView(viewModel: MockBetDetailValuesSummaryViewModel.defaultMock())
        valuesSummaryView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(valuesSummaryView)
        
        NSLayoutConstraint.activate([
            valuesSummaryView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            valuesSummaryView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            valuesSummaryView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            valuesSummaryView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Bet Values Summary - Single Row") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .red
        
        let valuesSummaryView = BetDetailValuesSummaryView(viewModel: MockBetDetailValuesSummaryViewModel.singleRowMock())
        valuesSummaryView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(valuesSummaryView)
        
        NSLayoutConstraint.activate([
            valuesSummaryView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            valuesSummaryView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            valuesSummaryView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            valuesSummaryView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])
        
        return vc
    }
}

#endif
