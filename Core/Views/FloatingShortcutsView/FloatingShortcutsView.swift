//
//  FloatingShortcutsView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 29/04/2022.
//

import UIKit
import SceneKit
import Combine

class FloatingShortcutsView: UIView {

    var didTapBetslipButtonAction: () -> Void = { }
    var didTapChatButtonAction: () -> Void = { }
    
    private lazy var containerView: UIView = Self.createContainerView()
    
    private lazy var chatButtonView: UIView = Self.createChatButtonView()

    private lazy var betslipButtonView: UIView = Self.createBetslipButtonView()
    private lazy var betslipIconImageView: UIImageView = Self.createBetslipIconImageView()
    private lazy var flipNumberView: FlipNumberView = Self.createFlipNumberView()
    
    private lazy var betslipCountBaseView: UIView = Self.createBetslipCountBaseView()
    private lazy var betslipCountLabel: UILabel = Self.createBetslipCountLabel()

    private lazy var coinSceneView: SCNView = Self.createBetslipCoinSceneView()
    private let coinScene = SCNScene.init(named: "CilinderSceneKitScene.scn")!
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        super.init(frame: .zero)

        self.commonInit()
    }

    @available(iOS, unavailable)
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
    }

    func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.setupSubviews()
        self.setupWithTheme()

        let tapBetslipView = UITapGestureRecognizer(target: self, action: #selector(didTapBetslipView))
        self.betslipButtonView.addGestureRecognizer(tapBetslipView)
        
        let tapChatView = UITapGestureRecognizer(target: self, action: #selector(didTapChatView))
        self.chatButtonView.addGestureRecognizer(tapChatView)
        
        self.flipNumberView.alpha = 0.0
        
        self.betslipCountBaseView.isHidden = true
        self.betslipCountLabel.isHidden = true
        
        self.betslipButtonView.clipsToBounds = true
        
        Env.betslipManager.bettingTicketsPublisher
            .map(\.count)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] betslipValue in
                self?.triggerCoinAnimation(withValue: betslipValue)
            })
            .store(in: &cancellables)
        
        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .map({ orderedSet -> Double in
                let newArray = orderedSet.map { $0.value }
                let multiple: Double = newArray.reduce(1.0, *)
                return multiple
            })
            .filter({ $0 > 1 })
            .removeDuplicates()
            .sink(receiveValue: { [weak self] multiplier in
                self?.triggerFlipperAnimation(withValue: multiplier)
            })
            .store(in: &cancellables)
        
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = .clear

        self.betslipCountBaseView.backgroundColor = UIColor.clear
        
        self.betslipCountLabel.backgroundColor = UIColor.App.alertError
        self.betslipButtonView.backgroundColor = UIColor.App.highlightPrimary
        self.betslipCountLabel.textColor = UIColor.white
        
        self.chatButtonView.backgroundColor = UIColor.App.buttonActiveHoverSecondary
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.betslipButtonView.layer.cornerRadius = self.betslipButtonView.frame.height / 2
        self.betslipCountLabel.layer.cornerRadius = self.betslipCountLabel.frame.height / 2

        self.chatButtonView.layer.cornerRadius = self.chatButtonView.frame.height / 2
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.containerView.frame.size.width, height: self.containerView.frame.size.height)
    }

    @objc private func didTapBetslipView() {
        self.didTapBetslipButtonAction()
    }
    
    @objc private func didTapChatView() {
        self.didTapChatButtonAction()
    }
    
    func addAnimations() {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.betslipCountLabel.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func triggerFlipperAnimation(withValue value: Double) {
        
        // Hide icon
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: [.curveEaseIn, .beginFromCurrentState],
                       animations: {
            self.betslipIconImageView.alpha = 0.0
            self.flipNumberView.alpha = 1.0
        }, completion: { finished in
            
            if !finished { return }
            
            // show flipper
            UIView.animate(withDuration: 0.1,
                           delay: 0.0,
                           options: [.curveEaseIn, .beginFromCurrentState],
                           animations: {
                self.betslipIconImageView.alpha = 0.0
                self.flipNumberView.alpha = 1.0
            }, completion: { finished in
                
                if !finished { return }
                
                // set flipper
                self.betslipIconImageView.alpha = 0.0
                self.flipNumberView.setNumber(value, animated: true)
                
                // await and hide flipper
                UIView.animate(withDuration: 0.1,
                               delay: 2.20,
                               options: [.curveEaseOut, .beginFromCurrentState],
                               animations: {
                    self.betslipIconImageView.alpha = 0.0
                    self.flipNumberView.alpha = 0.0
                }, completion: { finished in
                    
                    if !finished { return }
                    
                    // show icon
                    UIView.animate(withDuration: 0.3,
                                   delay: 0.0,
                                   options: [.curveEaseOut, .beginFromCurrentState],
                                   animations: {
                        self.betslipIconImageView.alpha = 1.0
                    }, completion: { finished in
                        if finished {
                            self.flipNumberView.alpha = 0.0
                            self.betslipIconImageView.alpha = 1.0
                        }
                    })
                    
                })
                
            })
            
        })
        
    }
    
    func triggerCoinAnimation(withValue value: Int) {
        
        if value != 0 {
            self.betslipCountBaseView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: [.curveEaseIn, .beginFromCurrentState],
                       animations: {
            self.betslipCountBaseView.transform = CGAffineTransform.identity.scaledBy(x: 1.6, y: 1.6)
        }, completion: { _ in
            UIView.animate(withDuration: 1,
                           delay: 0.25,
                           options: .curveEaseOut,
                           animations: {
                self.betslipCountBaseView.transform = CGAffineTransform.identity
            }, completion: { _ in
                if value == 0 {
                    self.betslipCountBaseView.isHidden = true
                }
            })
        })
    
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: [.beginFromCurrentState],
                       animations: {
            self.betslipCountLabel.alpha = 0.0
        }, completion: { _ in
            
            if value != 0 {
                self.betslipCountLabel.isHidden = false
            }
            self.betslipCountLabel.text = "\(value)"
            
            UIView.animate(withDuration: 0.3,
                           delay: 0.9,
                           options: [.beginFromCurrentState],
                           animations: {
                if value != 0 {
                    self.betslipCountLabel.alpha = 1.0
                }
            }, completion: { _ in
                if value == 0 {
                    self.betslipCountLabel.isHidden = true
                }
            })
        })
    
        let coinNode = self.coinScene.rootNode
        let completeRotation = CGFloat(Double.pi * 2) // 360
        let rotate90AboutZ = SCNAction.rotateBy(x: -completeRotation, y: 0.0, z: 0.0, duration: 1.2)
        rotate90AboutZ.timingFunction = { time in
            return simd_smoothstep(0, 1, time)
        }
        coinNode.runAction(rotate90AboutZ)

    }
    
}

extension FloatingShortcutsView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createBetslipButtonView() -> UIView {
        let betslipButtonView = UIView()
        betslipButtonView.translatesAutoresizingMaskIntoConstraints = false
        return betslipButtonView
    }
    
    private static func createBetslipIconImageView() -> UIImageView {
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "betslip_button_icon")
        iconImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
        return iconImageView
    }
    
    private static func createChatButtonView() -> UIView {
        let betslipButtonView = UIView()
        betslipButtonView.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = UIImage(named: "chat_float_icon")
        betslipButtonView.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            betslipButtonView.widthAnchor.constraint(equalToConstant: 46),
            betslipButtonView.widthAnchor.constraint(equalTo: betslipButtonView.heightAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: betslipButtonView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: betslipButtonView.centerYAnchor),
        ])

        return betslipButtonView
    }

    private static func createBetslipCountBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createBetslipCountLabel() -> UILabel {
        let betslipCountLabel = UILabel()
        betslipCountLabel.translatesAutoresizingMaskIntoConstraints = false
        betslipCountLabel.textColor = UIColor.App.textPrimary
        betslipCountLabel.backgroundColor = UIColor.App.bubblesPrimary
        betslipCountLabel.font = AppFont.with(type: .semibold, size: 11)
        betslipCountLabel.textAlignment = .center
        betslipCountLabel.clipsToBounds = true
        betslipCountLabel.layer.masksToBounds = true
        betslipCountLabel.text = "2"
        return betslipCountLabel
    }

    private static func createBetslipCoinView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemYellow
        return view
    }
    
    private static func createBetslipCoinSceneView() -> SCNView {
        let view = SCNView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.transform = CGAffineTransform(rotationAngle: .pi/2)
        view.allowsCameraControl = false
        view.backgroundColor = .clear
        
//        let coinGeometry = SCNCylinder(radius: 20, height: 6)
//
//        let topMaterial = SCNMaterial()
//        topMaterial.diffuse.contents = UIColor.App.bubblesPrimary
//
//        let bottomMaterial = SCNMaterial()
//        bottomMaterial.diffuse.contents = UIColor.systemYellow
//
//        let sidesMaterial = SCNMaterial()
//        sidesMaterial.diffuse.contents = UIColor.systemOrange
//
//        coinGeometry.materials = [sidesMaterial, topMaterial, bottomMaterial]
//
    /*
        let coinNode = coinScene.rootNode // SCNNode()
        
        // coinNode = SCNNode() // (geometry: coinGeometry)
        // coinNode.position = SCNVector3Make(0, 0, 0)
        // coinNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: Float(Double.pi / 2.0))
        
        // coinScene.rootNode.addChildNode(coinNode)
        
        
        // let rotate90AboutZ = SCNAction.rotateBy(x: -CGFloat(Double.pi / 2), y: 0.0, z: CGFloat(Double.pi / 2), duration: 10.0)
        // let rotate90AboutZ = SCNAction.rotateBy(x: CGFloat(Double.pi / 2), y: 0.0, z: 0.0, duration: 4.0)
        
        let completeRotation = CGFloat(Double.pi * 2) // 360
        let rotate90AboutZ = SCNAction.rotateBy(x: -completeRotation, y: 0.0, z: 0.0, duration: 1.8)
        rotate90AboutZ.timingFunction = { time in
            return simd_smoothstep(0, 1, time)
        }
        coinNode.runAction(rotate90AboutZ)
*/
        
//        let rotate90AboutZ = SCNAction.rotateBy(x: completeTripleRotation, y: 0.0, z: 0.0, duration: 4.0)
//        let foreverAnimation = SCNAction.repeatForever(rotate90AboutZ)
//        coinNode.runAction(foreverAnimation)
        
//        let action = SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 5))
//        coinNode.runAction(action)
//
        return view
    }
    
    private static func createFlipNumberView() -> FlipNumberView {
        let view = FlipNumberView()
        view.setNumber(1.00, animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    
    private func setupSubviews() {

        self.addSubview(self.containerView)
        
//        self.betslipCountBaseView.addSubview(self.betslipCoinView)
//        self.betslipCountBaseView.addSubview(self.betslipCountLabel)
        
        self.coinSceneView.scene = self.coinScene
        
        self.betslipCountBaseView.addSubview(self.coinSceneView)
        self.betslipCountBaseView.addSubview(self.betslipCountLabel)

        //
        self.betslipButtonView.addSubview(self.flipNumberView)
        self.betslipButtonView.addSubview(self.betslipIconImageView)

        //
        self.containerView.addSubview(self.betslipButtonView)
        self.containerView.addSubview(self.chatButtonView)

        self.containerView.addSubview(self.betslipCountBaseView)
        // Initialize constraints
        self.initConstraints()

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.betslipButtonView.widthAnchor.constraint(equalToConstant: 56),
            self.betslipButtonView.widthAnchor.constraint(equalTo: self.betslipButtonView.heightAnchor),

            self.betslipIconImageView.widthAnchor.constraint(equalToConstant: 31),
            self.betslipIconImageView.widthAnchor.constraint(equalTo: self.betslipIconImageView.heightAnchor),
            
            self.betslipIconImageView.centerXAnchor.constraint(equalTo: self.betslipButtonView.centerXAnchor),
            self.betslipIconImageView.centerYAnchor.constraint(equalTo: self.betslipButtonView.centerYAnchor),
            
            self.flipNumberView.centerXAnchor.constraint(equalTo: self.betslipButtonView.centerXAnchor),
            self.flipNumberView.centerYAnchor.constraint(equalTo: self.betslipButtonView.centerYAnchor, constant: -0.5),
        ])
        
        NSLayoutConstraint.activate([
            self.chatButtonView.centerXAnchor.constraint(equalTo: self.betslipButtonView.centerXAnchor),
            self.chatButtonView.bottomAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -10),
        ])
        
        NSLayoutConstraint.activate([
            self.betslipButtonView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -1),
            self.betslipButtonView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -1),
        ])
        
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.chatButtonView.topAnchor, constant: -1),
            self.containerView.leadingAnchor.constraint(equalTo: self.betslipButtonView.leadingAnchor, constant: -1),
        ])

        NSLayoutConstraint.activate([
            
            self.betslipCountBaseView.widthAnchor.constraint(equalToConstant: 20),
            self.betslipCountBaseView.widthAnchor.constraint(equalTo: self.betslipCountBaseView.heightAnchor),
            
            self.betslipCountLabel.widthAnchor.constraint(equalToConstant: 20),
            self.betslipCountLabel.widthAnchor.constraint(equalTo: self.betslipCountLabel.heightAnchor),
            
            self.betslipCountLabel.centerXAnchor.constraint(equalTo: self.betslipCountBaseView.centerXAnchor),
            self.betslipCountLabel.centerYAnchor.constraint(equalTo: self.betslipCountBaseView.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.betslipCountBaseView.trailingAnchor.constraint(equalTo: self.betslipButtonView.trailingAnchor, constant: 3),
            self.betslipCountBaseView.topAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -4),
        ])
        
    }

}
