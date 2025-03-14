//
//  ImageSectionView.swift
//  Sportsbook
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit

class ImageSectionView: UIView {

    // MARK: Private properties
    private lazy var imageView: UIImageView = Self.createImageView()

    // MARK: Lifetime and cycle
    init() {
                
        super.init(frame: .zero)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func commonInit() {
    }
    
    // MARK: Layout and theme
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.layer.cornerRadius = CornerRadius.button
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        
        self.imageView.backgroundColor = .clear
    }
    
    // MARK: Functions
    func configure(imageName: String) {
        self.imageView.image = UIImage(named: imageName)
    }

}

extension ImageSectionView {
    
    private static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    func setupSubviews() {
        
        self.addSubview(self.imageView)
        
        self.initConstraints()
    }
    
    func initConstraints() {
        
        NSLayoutConstraint.activate([
            
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
