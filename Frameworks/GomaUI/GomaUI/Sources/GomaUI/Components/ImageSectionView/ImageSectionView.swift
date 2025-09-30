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
        self.imageView.layer.cornerRadius = 8 // Using fixed corner radius for now
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.imageView.backgroundColor = .clear
    }
    
    // MARK: Functions
    private func configure() {
        if let imageUrl = URL(string: self.viewModel.imageUrl) {
            // Note: In a real implementation, you would use an image loading library like Kingfisher
            // For now, we'll set a placeholder or system image
            self.imageView.image = UIImage(systemName: "photo")
        } else {
            self.imageView.image = UIImage(systemName: "photo")
        }
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
