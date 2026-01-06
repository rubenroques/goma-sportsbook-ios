import Foundation
import UIKit
import Combine
import SwiftUI

final public class AmountPillsView: UIView {
    // MARK: - Private Properties
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: AmountPillsViewModelProtocol
    private var pillViews: [String: AmountPillView] = [:]
    
    // MARK: - Public Properties
    public var onPillSelected: ((String) -> Void) = { _ in }
    
    // MARK: - Initialization
    public init(viewModel: AmountPillsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupSubviews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        backgroundColor = .clear
        
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 40),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.pillsDataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pillsData in
                self?.configure(pillsData: pillsData)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Configuration
    private func configure(pillsData: AmountPillsData) {
        if pillViews.isEmpty {
            
            // Create pill views
            for pillData in pillsData.pills {
                let pillViewModel = MockAmountPillViewModel(pillData: pillData)
                let pillView = AmountPillView(viewModel: pillViewModel)
                
                // Add tap gesture
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pillTapped(_:)))
                pillView.addGestureRecognizer(tapGesture)
                pillView.isUserInteractionEnabled = true
                pillView.tag = Int(pillData.id) ?? 0
                
                stackView.addArrangedSubview(pillView)
                pillViews[pillData.id] = pillView
            }
        }
        // Update selection states
        updateSelectionStates(selectedId: pillsData.selectedPillId)
    }
    
    private func updateSelectionStates(selectedId: String?) {
        for (id, pillView) in pillViews {
            if let viewModel = pillView.viewModel as? MockAmountPillViewModel {
                viewModel.setSelected(id == selectedId)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func pillTapped(_ gesture: UITapGestureRecognizer) {
        guard let pillView = gesture.view as? AmountPillView else { return }
        
        // Find the pill ID
        for (id, view) in pillViews {
            if view == pillView {
                viewModel.selectPill(withId: id)
                onPillSelected(id)
                break
            }
        }
    }
}

// MARK: - Preview Provider
#if DEBUG

#Preview("All States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Helper function to create label
        func createLabel(text: String) -> UILabel {
            let label = UILabel()
            label.text = text
            label.font = StyleProvider.fontWith(type: .medium, size: 12)
            label.textColor = StyleProvider.Color.textSecondary
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }

        // 1. Few pills - No selection (3 pills)
        let label1 = createLabel(text: "Few pills - No selection")
        let fewPillsData = AmountPillsData(
            id: "few_no_selection",
            pills: [
                AmountPillData(id: "100", amount: "100", isSelected: false),
                AmountPillData(id: "500", amount: "500", isSelected: false),
                AmountPillData(id: "1000", amount: "1000", isSelected: false)
            ],
            selectedPillId: nil
        )
        let fewPillsView = AmountPillsView(viewModel: MockAmountPillsViewModel(pillsData: fewPillsData))
        fewPillsView.translatesAutoresizingMaskIntoConstraints = false

        // 2. Few pills - With selection (4 pills, 2nd selected)
        let label2 = createLabel(text: "Few pills - With selection (500)")
        let fewSelectedData = AmountPillsData(
            id: "few_with_selection",
            pills: [
                AmountPillData(id: "250", amount: "250", isSelected: false),
                AmountPillData(id: "500", amount: "500", isSelected: true),
                AmountPillData(id: "1000", amount: "1000", isSelected: false),
                AmountPillData(id: "2000", amount: "2000", isSelected: false)
            ],
            selectedPillId: "500"
        )
        let fewSelectedView = AmountPillsView(viewModel: MockAmountPillsViewModel(pillsData: fewSelectedData))
        fewSelectedView.translatesAutoresizingMaskIntoConstraints = false

        // 3. Many pills - No selection (8 pills, shows scrolling)
        let label3 = createLabel(text: "Many pills - No selection (scrollable)")
        let manyPillsData = AmountPillsData(
            id: "many_no_selection",
            pills: [
                AmountPillData(id: "250", amount: "250", isSelected: false),
                AmountPillData(id: "500", amount: "500", isSelected: false),
                AmountPillData(id: "1000", amount: "1000", isSelected: false),
                AmountPillData(id: "2000", amount: "2000", isSelected: false),
                AmountPillData(id: "3000", amount: "3000", isSelected: false),
                AmountPillData(id: "5000", amount: "5000", isSelected: false),
                AmountPillData(id: "10000", amount: "10000", isSelected: false),
                AmountPillData(id: "20000", amount: "20000", isSelected: false)
            ],
            selectedPillId: nil
        )
        let manyPillsView = AmountPillsView(viewModel: MockAmountPillsViewModel(pillsData: manyPillsData))
        manyPillsView.translatesAutoresizingMaskIntoConstraints = false

        // 4. Many pills - Last selected (6 pills, last selected)
        let label4 = createLabel(text: "Many pills - Last selected (10000)")
        let manySelectedData = AmountPillsData(
            id: "many_last_selected",
            pills: [
                AmountPillData(id: "500", amount: "500", isSelected: false),
                AmountPillData(id: "1000", amount: "1000", isSelected: false),
                AmountPillData(id: "2000", amount: "2000", isSelected: false),
                AmountPillData(id: "3000", amount: "3000", isSelected: false),
                AmountPillData(id: "5000", amount: "5000", isSelected: false),
                AmountPillData(id: "10000", amount: "10000", isSelected: true)
            ],
            selectedPillId: "10000"
        )
        let manySelectedView = AmountPillsView(viewModel: MockAmountPillsViewModel(pillsData: manySelectedData))
        manySelectedView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(label1)
        stackView.addArrangedSubview(fewPillsView)
        stackView.addArrangedSubview(label2)
        stackView.addArrangedSubview(fewSelectedView)
        stackView.addArrangedSubview(label3)
        stackView.addArrangedSubview(manyPillsView)
        stackView.addArrangedSubview(label4)
        stackView.addArrangedSubview(manySelectedView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),

            fewPillsView.heightAnchor.constraint(equalToConstant: 40),
            fewSelectedView.heightAnchor.constraint(equalToConstant: 40),
            manyPillsView.heightAnchor.constraint(equalToConstant: 40),
            manySelectedView.heightAnchor.constraint(equalToConstant: 40)
        ])

        return vc
    }
}

#endif
