//
//  VideoBlockView.swift
//  GomaUI
//
//  Created by André Lascas on 14/03/2025.
//

import UIKit
import AVFoundation

public class VideoBlockView: UIView {
    
    // MARK: Private properties
    private lazy var videoContainerView: UIView = Self.createVideoContainerView()
    private lazy var playPauseButton: UIButton = Self.createPlayPauseButton()
    private lazy var heightConstraint: NSLayoutConstraint = Self.createHeightConstraint()
    
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var isPlaying = false
    
    private let defaultVideoHeight: CGFloat = 250
    private let maxVideoHeight: CGFloat = 500
    
    private let viewModel: VideoBlockViewModelProtocol
    
    // MARK: - Lifetime and Cycle
    public init(viewModel: VideoBlockViewModelProtocol) {
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
        
        self.configure()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = self.videoContainerView.bounds
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.videoContainerView.backgroundColor = .clear
    }
    
    // MARK: Functions
    private func configure() {
        guard let videoURL = self.viewModel.videoURL else { return }
        
        self.player?.pause()
        self.playerLayer?.removeFromSuperlayer()
        
        // Get video dimensions and set height before creating player
        self.setVideoHeight(from: videoURL) { [weak self] in
            guard let self = self else { return }
            
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
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    private func setVideoHeight(from url: URL, completion: @escaping () -> Void) {
        let asset = AVAsset(url: url)
        
        Task {
            do {
                let tracks = try await asset.loadTracks(withMediaType: .video)
                if let videoTrack = tracks.first {
                    let size = try await videoTrack.load(.naturalSize)
                    let transform = try await videoTrack.load(.preferredTransform)
                    
                    await MainActor.run {
                        // Account for video rotation
                        let videoRect = CGRect(origin: .zero, size: size).applying(transform)
                        let videoHeight = abs(videoRect.height)
                        let videoWidth = abs(videoRect.width)
                        
                        // Calculate height maintaining aspect ratio based on screen width
                        let screenWidth = UIScreen.main.bounds.width - 30 // Account for leading/trailing margins
                        let aspectRatio = videoHeight / videoWidth
                        var finalHeight = screenWidth * aspectRatio
                        
                        // Update height constraint
                        self.heightConstraint.constant = finalHeight
                        
                        completion()
                    }
                } else {
                    await MainActor.run {
                        // Fallback to default height if no video track
                        self.heightConstraint.constant = self.defaultVideoHeight
                        
                        completion()
                    }
                }
            } catch {
                await MainActor.run {
                    // Fallback to default height on error
                    self.heightConstraint.constant = self.defaultVideoHeight
                    
                    completion()
                }
            }
        }
    }
    
    public func play() {
        self.player?.play()
        self.isPlaying = true
        self.playPauseButton.alpha = 0
    }
    
    public func pause() {
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

// MARK: - Subviews Initialization and Setup
extension VideoBlockView {
    
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
    
    private static func createHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private func setupSubviews() {
        self.addSubview(self.videoContainerView)
        self.addSubview(self.playPauseButton)
        self.initConstraints()
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // Video container constraints
            self.videoContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.videoContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            self.videoContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.videoContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            
            // Play/pause button constraints
            self.playPauseButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.playPauseButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.playPauseButton.widthAnchor.constraint(equalToConstant: 50),
            self.playPauseButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: self.defaultVideoHeight)
        self.heightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            self.videoContainerView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -10)
        ])
    }
}
