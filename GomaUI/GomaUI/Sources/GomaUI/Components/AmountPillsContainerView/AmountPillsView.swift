//
//  File.swift
//  GomaUI
//
//  Created by André Lascas on 09/06/2025.
//

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
        // Clear existing pill views
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pillViews.removeAll()
        
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

@available(iOS 17.0, *)
#Preview("Amount Pills - Default") {
    PreviewUIView {
        AmountPillsView(viewModel: MockAmountPillsViewModel.defaultMock)
    }
    .frame(height: 40)
    .padding()
}

@available(iOS 17.0, *)
#Preview("Amount Pills - With Selection") {
    PreviewUIView {
        AmountPillsView(viewModel: MockAmountPillsViewModel.selectedMock)
    }
    .frame(height: 40)
    .padding()
}

#endif
