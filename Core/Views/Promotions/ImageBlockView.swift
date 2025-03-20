//
//  ImageBlockView.swift
//  Sportsbook
//
//  Created by André Lascas on 12/03/2025.
//

import UIKit

class ImageBlockView: UIView {

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
        if let imageUrl = URL(string: imageName) {
            self.imageView.kf.setImage(with: imageUrl)
        }
    }

}

extension ImageBlockView {
    
    private static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }
    
    func setupSubviews() {
        
        self.addSubview(self.imageView)
        
        self.initConstraints()
    }
    
    func initConstraints() {
        
        NSLayoutConstraint.activate([
            
            self.imageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 15),
            self.imageView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -15),
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}
