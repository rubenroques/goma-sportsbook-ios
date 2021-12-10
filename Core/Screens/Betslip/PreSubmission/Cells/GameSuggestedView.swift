//
//  GameSuggestedView.swift
//  Sportsbook
//
//  Created by Teresa on 10/12/2021.
//

import Foundation
import UIKit

class GameSuggestedView: NibView {

    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var gameTitleLabel: UILabel!
    @IBOutlet weak var gameInfoLabel: UILabel!
    
    
    // Variables
    var onClose:(() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setupWithTheme()
    }

    override func commonInit() {

     
        gameTitleLabel.text = "Alert"

        gameInfoLabel.text = "Lorem ipsum dolor."
        
    }

    func setupWithTheme() {
        self.alpha = 0

        gameView.backgroundColor = UIColor.App.mainBackground

        gameTitleLabel.textColor = UIColor.App.headingMain
        gameInfoLabel.textColor = UIColor.App.headingMain
    }

    func setAlertTitle(_ title: String) {
        gameTitleLabel.text = title
    }

    func setAlertText(_ text: String) {
        gameInfoLabel.text = text
    }

    @IBAction private func closeView() {
        onClose?()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: 100)
    }

}
