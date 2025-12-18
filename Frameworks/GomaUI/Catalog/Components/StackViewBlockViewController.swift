//
//  StackViewBlockViewController.swift
//  GomaUICatalog
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit
import GomaUI

class StackViewBlockViewController: UIViewController {
    
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentView: UIView = Self.createContentView()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupWithTheme()
    }
    
    private func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        // Add different states
        let defaultView = StackViewBlockView(viewModel: MockStackViewBlockViewModel.defaultMock)
        let multipleViewsView = StackViewBlockView(viewModel: MockStackViewBlockViewModel.multipleViewsMock)
        let singleViewView = StackViewBlockView(viewModel: MockStackViewBlockViewModel.singleViewMock)
        
        stackView.addArrangedSubview(defaultView)
        stackView.addArrangedSubview(multipleViewsView)
        stackView.addArrangedSubview(singleViewView)
        
        initConstraints()
    }
    
    private func setupWithTheme() {
        view.backgroundColor = .backgroundTestColor
    }
}

// MARK: - Subviews Initialization and Setup
extension StackViewBlockViewController {
    
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }
    
    private static func createContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
}
