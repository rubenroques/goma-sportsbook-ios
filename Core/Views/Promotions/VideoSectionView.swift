//
//  VideoSectionView.swift
//  Sportsbook
//
//  Created by André Lascas on 13/03/2025.
//

import UIKit
import AVFoundation

class VideoSectionView: UIView {

    // MARK: Private properties
    private lazy var videoContainerView: UIView = Self.createVideoContainerView()
    private lazy var playPauseButton: UIButton = Self.createPlayPauseButton()
    
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var isPlaying = false
    
    private let videoHeight: CGFloat = 400

    // MARK: Lifetime and cycle
    init() {
        super.init(frame: .zero)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.togglePlayPause))
        self.videoContainerView.addGestureRecognizer(tapGesture)
        self.videoContainerView.isUserInteractionEnabled = true

        NotificationCenter.default.addObserver(self,
                                             selector: #selector(appDidEnterBackground),
                                             name: UIApplication.didEnterBackgroundNotification,
                                             object: nil)
        
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(appWillEnterForeground),
                                             name: UIApplication.willEnterForegroundNotification,
                                             object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Layout and theme
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.videoContainerView.layer.cornerRadius = CornerRadius.button
        self.playerLayer?.frame = self.videoContainerView.bounds
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.videoContainerView.backgroundColor = .clear
    }
    
    // MARK: Functions
    func configure(videoURL: URL) {
        self.player?.pause()
        self.playerLayer?.removeFromSuperlayer()
        
        self.player = AVPlayer(url: videoURL)
        
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = self.videoContainerView.bounds
        self.videoContainerView.layer.addSublayer(playerLayer)
        self.playerLayer = playerLayer
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerDidFinishPlaying),
                                             name: .AVPlayerItemDidPlayToEndTime,
                                             object: self.player?.currentItem)
    }
    
    func play() {
        self.player?.play()
        self.isPlaying = true
        self.playPauseButton.alpha = 0
    }
    
    func pause() {
        self.player?.pause()
        self.isPlaying = false
        self.playPauseButton.alpha = 1

    }
    
    // MARK: Actions
    @objc private func togglePlayPause() {
        if self.isPlaying {
            self.pause()
        } else {
            self.play()
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        self.player?.seek(to: CMTime.zero)
        self.isPlaying = false
        self.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        self.playPauseButton.alpha = 1
    }
    
    @objc private func appDidEnterBackground() {
        if self.isPlaying {
            self.pause()
        }
    }
    
    @objc private func appWillEnterForeground() {
        // Optionally auto-resume
        // self.play()
    }
}

extension VideoSectionView {
    private static func createVideoContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }
    
    private static func createPlayPauseButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 25
        button.alpha = 1
        button.isUserInteractionEnabled = false
        return button
    }
    
    func setupSubviews() {
        self.addSubview(self.videoContainerView)
        self.addSubview(self.playPauseButton)
        
        self.initConstraints()
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            // Video container constraints
            self.videoContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.videoContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.videoContainerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.videoContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.heightAnchor.constraint(equalToConstant: self.videoHeight),
            
            // Play/pause button constraints
            self.playPauseButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.playPauseButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.playPauseButton.widthAnchor.constraint(equalToConstant: 50),
            self.playPauseButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
