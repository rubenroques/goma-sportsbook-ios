//
//  SelectOptionsView.swift
//  GomaUI
//
//  Created by Claude on 07/11/2025.
//

import UIKit
import Combine

public final class SelectOptionsView: UIView {
    // MARK: - UI Components
    private lazy var contentStackView: UIStackView = Self.createContentStackView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    
    private var optionViews: [SimpleOptionRowView] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Properties
    private let viewModel: SelectOptionsViewModelProtocol
    public var onOptionSelected: ((String) -> Void)?
    
    // MARK: - Initialization
    public init(viewModel: SelectOptionsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        commonInit()
        configure()
        bindSelection()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configure() {
        if let title = viewModel.title, !title.isEmpty {
            titleLabel.text = title
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }
        
        optionViews.forEach { view in
            contentStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        optionViews.removeAll()
        
        for optionViewModel in viewModel.options {
            let view = SimpleOptionRowView(viewModel: optionViewModel)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.isSelected = viewModel.selectedOptionId.value == optionViewModel.option.id
            view.configure()
            view.didTapOption = { [weak self] option in
                self?.viewModel.selectOption(withId: option.id)
                self?.onOptionSelected?(option.id)
            }
            optionViews.append(view)
            contentStackView.addArrangedSubview(view)
        }
        
        updateSelection(selectedId: viewModel.selectedOptionId.value)
    }
    
    private func bindSelection() {
        viewModel.selectedOptionId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedId in
                self?.updateSelection(selectedId: selectedId)
            }
            .store(in: &cancellables)
    }
    
    private func updateSelection(selectedId: String?) {
        for (index, optionViewModel) in viewModel.options.enumerated() {
            guard optionViews.indices.contains(index) else { continue }
            let optionView = optionViews[index]
            let isSelected = selectedId == optionViewModel.option.id
            if optionView.isSelected != isSelected {
                optionView.isSelected = isSelected
            }
        }
    }
}

// MARK: - Helpers
private extension SelectOptionsView {
    static func createContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.backgroundColor = StyleProvider.Color.backgroundTertiary
        return stackView
    }
    
    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .semibold, size: 12)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 0
        return label
    }
}

// MARK: - Preview
import SwiftUI

@available(iOS 17.0, *)
#Preview("Select Options View") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = StyleProvider.Color.backgroundPrimary
        
        let options = [
            MockSimpleOptionRowViewModel.sampleSelected,
            MockSimpleOptionRowViewModel.sampleUnselected
        ]
        let viewModel = MockSelectOptionsViewModel(title: "Preferences", options: options, selectedOption: "1")
        let selectOptionsView = SelectOptionsView(viewModel: viewModel)
        selectOptionsView.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(selectOptionsView)
        
        NSLayoutConstraint.activate([
            selectOptionsView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            selectOptionsView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
            selectOptionsView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
        
        return vc
    }
}
