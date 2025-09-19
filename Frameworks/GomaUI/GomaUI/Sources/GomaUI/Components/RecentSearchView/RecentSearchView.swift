//
//  RecentSearchView.swift
//  GomaUI
//
//  Created by Assistant on 2024-12-19.
//

import UIKit

public class RecentSearchView: UIView {
    
    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()
    private lazy var searchIconImageView: UIImageView = Self.createSearchIconImageView()
    private lazy var searchTextLabel: UILabel = Self.createSearchTextLabel()
    private lazy var deleteButton: UIButton = Self.createDeleteButton()
    private lazy var separatorLine: UIView = Self.createSeparatorLine()
    
    // MARK: ViewModel
    private let viewModel: RecentSearchViewModelProtocol
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: RecentSearchViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
        self.setupWithTheme()
        self.setupBindings()
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented. Use init(viewModel:) instead.")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(viewModel:) instead.")
    }
    
    func commonInit() {
        self.setupSubviews()
        self.configure()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupWithTheme() {
        self.searchTextLabel.textColor = StyleProvider.Color.textPrimary
        self.searchIconImageView.tintColor = StyleProvider.Color.highlightPrimary
        self.deleteButton.tintColor = StyleProvider.Color.highlightPrimary
        self.containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
        self.separatorLine.backgroundColor = StyleProvider.Color.separatorLine
    }
    
    private func setupBindings() {
        // Set up tap gesture for the entire view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
        
        // Set up delete button action
        self.deleteButton.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
    }
    
    // MARK: Functions
    public func configure() {
        self.searchTextLabel.text = viewModel.searchText
    }
    
    @objc private func handleTap() {
        viewModel.onTap?()
    }
    
    @objc private func handleDelete() {
        viewModel.onDelete?()
    }
}

// MARK: - Subviews Initialization and Setup
extension RecentSearchView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }
    
    private static func createSearchIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if let customImage = UIImage(named: "search_icon") {
            imageView.image = customImage
        }
        else if let systemImage = UIImage(systemName: "magnifyingglass") {
            imageView.image = systemImage
        }
        return imageView
    }
    
    private static func createSearchTextLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }
    
    private static func createSeparatorLine() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createDeleteButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        if let customImage = UIImage(named: "cancel_search_icon") {
            button.setImage(customImage, for: .normal)
        }
        else if let systemImage = UIImage(systemName: "xmark") {
            button.setImage(systemImage, for: .normal)
        }
        button.contentMode = .scaleAspectFit
        return button
    }
    
    private func setupSubviews() {
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.stackView)
        self.containerView.addSubview(self.separatorLine)
        
        self.stackView.addArrangedSubview(self.searchIconImageView)
        self.stackView.addArrangedSubview(self.searchTextLabel)
        self.stackView.addArrangedSubview(self.deleteButton)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Container
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 50),
            
            // StackView
            self.stackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.stackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.stackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 16),
            self.stackView.bottomAnchor.constraint(equalTo: self.separatorLine.topAnchor, constant: -16),
            
            // Separator line
            self.separatorLine.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.separatorLine.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.separatorLine.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            // Search icon size
            self.searchIconImageView.widthAnchor.constraint(equalToConstant: 16),
            self.searchIconImageView.heightAnchor.constraint(equalTo: self.searchIconImageView.widthAnchor),
            
            // Delete button size
            self.deleteButton.widthAnchor.constraint(equalToConstant: 40),
            self.deleteButton.heightAnchor.constraint(equalTo: self.deleteButton.widthAnchor)
        ])
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("RecentSearchView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.systemBackground
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        // Recent search examples
        let recentSearch1 = MockRecentSearchViewModel(searchText: "Liverpool")
        let recentSearchView1 = RecentSearchView(viewModel: recentSearch1)
        recentSearchView1.configure()
        
        let recentSearch2 = MockRecentSearchViewModel(searchText: "Manchester United")
        let recentSearchView2 = RecentSearchView(viewModel: recentSearch2)
        recentSearchView2.configure()
        
        let recentSearch3 = MockRecentSearchViewModel(searchText: "Premier League")
        let recentSearchView3 = RecentSearchView(viewModel: recentSearch3)
        recentSearchView3.configure()
        
        stackView.addArrangedSubview(recentSearchView1)
        stackView.addArrangedSubview(recentSearchView2)
        stackView.addArrangedSubview(recentSearchView3)
        
        vc.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        return vc
    }
}
#endif
