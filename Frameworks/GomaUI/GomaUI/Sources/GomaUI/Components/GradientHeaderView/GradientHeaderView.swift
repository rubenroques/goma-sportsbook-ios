//
//  GradientHeaderView.swift
//  GomaUI
//
//  Created by André Lascas on 12/03/2025.
//

import UIKit

public class GradientHeaderView: UIView {
    
    // MARK: Private properties
    private lazy var gradientView: GradientView = Self.createGradientView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private var viewModel: GradientHeaderViewModelProtocol
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: GradientHeaderViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
        self.setupWithTheme()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.setupSubviews()
        self.configure(viewModel: self.viewModel)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientView.startPoint = CGPoint(x: 0.0, y: 1.0)
        self.gradientView.endPoint = CGPoint(x: 1.0, y: 0.0)
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.gradientView.colors = self.viewModel.gradientColors
        self.titleLabel.textColor = StyleProvider.Color.buttonTextPrimary
    }
    
    // MARK: Functions
    public func configure(viewModel: GradientHeaderViewModelProtocol) {
        self.viewModel = viewModel
        self.titleLabel.text = viewModel.title
    }
}

// MARK: - Subviews Initialization and Setup
extension GradientHeaderView {
    
    private static func createGradientView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = StyleProvider.fontWith(type: .bold, size: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }
    
    private func setupSubviews() {
        self.addSubview(self.gradientView)
        self.gradientView.addSubview(self.titleLabel)
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.gradientView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.gradientView.topAnchor.constraint(equalTo: self.topAnchor),
            self.gradientView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.gradientView.heightAnchor.constraint(equalToConstant: 208),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.gradientView.leadingAnchor, constant: 15),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.gradientView.trailingAnchor, constant: -15),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.gradientView.centerYAnchor)
        ])
    }
}
