//
//  SeeMoreMarketsCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 13/10/2021.
//

import UIKit

class SeeMoreMarketsCollectionViewCell: UICollectionViewCell {

    lazy var circularProgressView: KDCircularProgress = {
        let circularProgressView = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 47, height: 47))
        circularProgressView.translatesAutoresizingMaskIntoConstraints = false
        circularProgressView.startAngle = -90
        circularProgressView.progressThickness = 0.5
        circularProgressView.trackThickness = 0.5
        circularProgressView.clockwise = true
        
        NSLayoutConstraint.activate([
            circularProgressView.heightAnchor.constraint(equalToConstant: 47),
            circularProgressView.widthAnchor.constraint(equalToConstant: 47)
        ])
        
        return circularProgressView
    }()
    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    var tappedAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

//        self.flipSideBackView.transform3D = CATransform3DRotate(CATransform3DIdentity, Double.pi, 0, 1, 0)
//        // self.flipSideBackView.layer.isDoubleSided = false
//
//        self.baseView.addSubview(self.flipSideBackView)
//
//        NSLayoutConstraint.activate([
//            self.flipSideBackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
//            self.flipSideBackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
//            self.flipSideBackView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
//            self.flipSideBackView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor)
//        ])
//
//        // self.flipSideFrontView.layer.isDoubleSided = false
//        self.baseView.addSubview(self.flipSideFrontView)
//
//        NSLayoutConstraint.activate([
//            self.flipSideFrontView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
//            self.flipSideFrontView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
//            self.flipSideFrontView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
//            self.flipSideFrontView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor)
//        ])
//
//        self.baseView.sendSubviewToBack(self.flipSideFrontView)
//        self.baseView.sendSubviewToBack(self.flipSideBackView)
//        // self.layer.isDoubleSided = false
//
//        self.baseView.clipsToBounds = true

        //
        // Setup fonts
        self.titleLabel.font = AppFont.with(type: .heavy, size: 14)
        self.subtitleLabel.font = AppFont.with(type: .bold, size: 12)
            
        self.baseView.layer.cornerRadius = 9

        self.baseView.addSubview(self.circularProgressView)
                
        NSLayoutConstraint.activate([
            self.circularProgressView.centerXAnchor.constraint(equalTo: self.arrowImageView.centerXAnchor),
            self.circularProgressView.centerYAnchor.constraint(equalTo: self.arrowImageView.centerYAnchor),
        ])
        
        self.titleLabel.text = localized("see_all")
        self.setupWithTheme()

        let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
        self.addGestureRecognizer(tapMatchView)

    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.subtitleLabel.isHidden = false
        self.subtitleLabel.text = ""
        
        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.backgroundCards

        self.circularProgressView.trackColor = UIColor.App.textPrimary
        self.circularProgressView.progressColors = [UIColor.App.highlightPrimary]
        
        self.titleLabel.textColor = UIColor.App.textPrimary
        self.subtitleLabel.textColor = UIColor.App.textSecondary
    }

    @IBAction private func didTapMatchView(_ sender: Any) {
        self.tappedAction?()
    }

    func configureWithSubtitleString(_ subtitle: String) {
        self.subtitleLabel.text = subtitle
    }

    func hideSubtitle() {
        self.subtitleLabel.isHidden = true
    }
    
    func setAnimationPercentage(_ percentage: Double) {
        
        var clippedPercentage = percentage
        if clippedPercentage > 1.0 {
            clippedPercentage = 1.0
        }
        if clippedPercentage < 0.0 {
            clippedPercentage = 0.0
        }
        
        //
        // ===
        let rotationClippedPercentage = self.scaledPercentage(percentage: percentage, minimum: 0.1, maximum: 1)
        
        // let percentageDegrees = -(rotationClippedPercentage * 180.0) / 1
        // let rads = percentageDegrees * (Double.pi/180.0)
        // let rotationTransform = CGAffineTransform.init(rotationAngle: rads)
        self.circularProgressView.angle = (rotationClippedPercentage * 360.0)
        
        let scaleClippedPercentage = self.scaledPercentage(percentage: percentage, minimum: 0.0, maximum: 0.6)
        
        let scale = 1.0 + (0.6 * scaleClippedPercentage)
        let scaleTransform = CGAffineTransform.init(scaleX: scale, y: scale)
        
        // rotationTransform.concatenating(scaleTransform)
        self.arrowImageView.transform = scaleTransform
    }

    func scaledPercentage(percentage: Double, minimum: Double = 0.0, maximum: Double = 1.0) -> Double {
        let percentageInterval = maximum - minimum
        
        var clippedPercentage = ((percentage-minimum) * 1.0) / percentageInterval
        if clippedPercentage > 1.0 {
            clippedPercentage = 1.0
        }
        if clippedPercentage < 0.0 {
            clippedPercentage = 0.0
        }
        return clippedPercentage
    }
    
    //
    /*
 
 V1
 
 func setAnimationPercentage(_ percentage: Double) {
     
     var clippedPercentage = percentage
     if clippedPercentage > 1.0 {
         clippedPercentage = 1.0
     }
     if clippedPercentage < 0.0 {
         clippedPercentage = 0.0
     }
     
     // ===
     let percentageDegrees = -(clippedPercentage * 180.0) / 1
     let rads = percentageDegrees * (Double.pi/180.0)
     
     let rotationTransform = CGAffineTransform.init(rotationAngle: rads)
     
     let scalePercentageMax = 0.3
     
     var scalePercentage = (clippedPercentage * 1.0) / scalePercentageMax
     scalePercentage = scalePercentage > 1.0 ? 1.0 : scalePercentage
     
     let scale = 1.0 + (0.72 * scalePercentage)
     let scaleTransform = CGAffineTransform.init(scaleX: scale, y: scale)
     
     self.arrowImageView.transform = rotationTransform.concatenating(scaleTransform)
     
     self.arrowImageView.alpha = 0.25 + clippedPercentage
 }
 
     
     
     V2
     func setAnimationPercentage(_ percentage: Double) {
         
         var clippedPercentage = percentage
         if clippedPercentage > 1.0 {
             clippedPercentage = 1.0
         }
         if clippedPercentage < 0.0 {
             clippedPercentage = 0.0
         }
         
         // ======
         // Rotation
         let rotationClippedPercentage = self.scaledPercentage(percentage: percentage, minimum: 0.2, maximum: 0.99)
         
         let percentageDegrees = (rotationClippedPercentage * 180.0) / 1
         let rads = percentageDegrees * (Double.pi/180.0)
         
         var transform = CATransform3DIdentity
         transform.m34 = 1.0 / 320.0
         
         let rotationTransform = CATransform3DRotate(transform, rads, 0, 1, 0)
         

         let scaleClippedPercentage = self.scaledPercentage(percentage: percentage, minimum: 0.0, maximum: 0.5)
         
         let scale = 1.0 + (0.15 * scaleClippedPercentage)
         
         self.transform3D = CATransform3DScale(rotationTransform, scale, scale, scale)
         
     }
     
     
 */
    
    
    
}


