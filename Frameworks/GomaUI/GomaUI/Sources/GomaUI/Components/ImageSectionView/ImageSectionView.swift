//
//  ImageSectionView.swift
//  GomaUI
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit

public class ImageSectionView: UIView {
    
    // MARK: Private properties
    private lazy var imageView: UIImageView = Self.createImageView()
    private let viewModel: ImageSectionViewModelProtocol
    
    // MARK: - Aspect Ratio Properties
    private var aspectRatio: CGFloat = 1.0
    private var dynamicHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: ImageSectionViewModelProtocol) {
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
        self.configure()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.imageView.backgroundColor = .clear
    }
    
    // MARK: Functions
    private func configure() {
        if let imageUrl = URL(string: self.viewModel.imageUrl) {
            self.imageView.kf.setImage(with: imageUrl) { [weak self] result in
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        self?.resizeImageView(with: value.image)
                    }
                case .failure(let error):
                    print("Failed to load image: \(error)")
                }
            }
        }
    }
    
    private func resizeImageView(with image: UIImage) {
        // Calculate aspect ratio
        self.aspectRatio = image.size.width / image.size.height
        
        // Deactivate existing dynamic height constraint if it exists
        self.dynamicHeightConstraint?.isActive = false
        
        // Create new dynamic height constraint based on aspect ratio
        self.dynamicHeightConstraint = NSLayoutConstraint(
            item: self.imageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: self.imageView,
            attribute: .width,
            multiplier: 1 / self.aspectRatio,
            constant: 0
        )
        
        self.dynamicHeightConstraint?.isActive = true
        
        // Force layout update
        self.layoutIfNeeded()
    }
}

// MARK: - Subviews Initialization and Setup
extension ImageSectionView {
    
    private static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }
    
    private func setupSubviews() {
        self.addSubview(self.imageView)
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
