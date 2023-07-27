//
//  StoriesFullScreenItemViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 06/06/2023.
//

import UIKit
import Kingfisher
import AVFoundation
import AVKit

class StoriesFullScreenItemViewModel {

    var storyCellViewModel: StoriesItemCellViewModel

    enum ContentType {
        case image(sourceUrl: URL)
        case video(sourceUrl: URL)
    }

    var contentType: ContentType?

    let supportedImageTypes = ["png", "jpeg", "jpg"]
    let supportedVideoTypes = ["mp4", "avi", "mov"]

//    init(videoSourceURL: URL) {
//        self.contentType = .video(sourceUrl: videoSourceURL)
//    }
//
//    init(imageSourceURL: URL) {
//    }

    init(storyCellViewModel: StoriesItemCellViewModel) {
        self.storyCellViewModel = storyCellViewModel

        if let fileType = storyCellViewModel.contentString.split(separator: ".").last {

            let fileTypeString = String(fileType)

            if self.supportedImageTypes.contains(fileTypeString) {
                if let contentUrl = URL(string: storyCellViewModel.contentString) {

                    self.contentType = .image(sourceUrl: contentUrl)
                }
            }
            else if self.supportedVideoTypes.contains(fileTypeString) {
                if let contentUrl = URL(string: storyCellViewModel.contentString) {

                    self.contentType = .video(sourceUrl: contentUrl)
                }
            }
        }

    }

}

class StoriesFullScreenItemView: UIView {

    var nextPageRequestedAction: ((String?) -> Void)?
    var previousPageRequestedAction: () -> Void = { }

    var closeRequestedAction: () -> Void = { }
    var linkRequestAction: ((String) -> Void)?

    private lazy var baseView: UIView = Self.createBaseView()

    private lazy var nextPageView: UIView = Self.createTapView()
    private lazy var previousPageView: UIView = Self.createTapView()

    private lazy var topView: UIView = Self.createTopView()
    private lazy var topLabel: UILabel = Self.createTopLabel()

    private lazy var smoothProgressBarView: SmoothProgressBarView = Self.createSmoothProgressBarView()

    private lazy var contentImageView: UIImageView = Self.createContentImageView()

    //
    private lazy var videoBaseView: UIView = Self.createVideoBaseView()
    private let videoPlayerViewController = AVPlayerViewController()
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var isReadyToPlayVideo: Bool = false

    //
    private lazy var closeImageBaseView: UIView = Self.createCloseImageBaseView()
    private lazy var closeImageView: UIImageView = Self.createCloseImageView()
    private lazy var actionButton: UIButton = Self.createActionButton()

    override var tag: Int {
        didSet {
            self.smoothProgressBarView.tag = self.tag
        }
    }

    var viewModel: StoriesFullScreenItemViewModel?

    var markedReadAction: ((String) -> Void)?

    // MARK: - Lifetime and Cycle
    init(index: Int, viewModel: StoriesFullScreenItemViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)
        self.commonInit()
    }

    @available(iOS, unavailable)
    override init(frame: CGRect) {
        fatalError()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func commonInit() {
        self.setupSubviews()
        self.setupWithTheme()

        self.smoothProgressBarView.progressBarFinishedAction = { [weak self] in
            self?.nextPageRequestedAction?(nil)
        }

        let nextTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapNextPageView))
        self.nextPageView.addGestureRecognizer(nextTapGesture)

        let previousTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPreviousPageView))
        self.previousPageView.addGestureRecognizer(previousTapGesture)

        let closeTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCloseButton))
        self.closeImageView.addGestureRecognizer(closeTapGesture)
        self.closeImageView.isUserInteractionEnabled = true

        self.actionButton.addTarget(self, action: #selector(didTapActionButton), for: .primaryActionTriggered)

        if let viewModel = self.viewModel {
            self.topLabel.text = viewModel.storyCellViewModel.title

            if let contentType = viewModel.contentType {
                switch contentType {
                case .video(let sourceUrl):
                    self.videoBaseView.isHidden = false
                    self.contentImageView.isHidden = true

                    self.addVideoView(withURL: sourceUrl)
                case .image(let sourceUrl):
                    self.videoBaseView.isHidden = true
                    self.contentImageView.isHidden = false

                    self.contentImageView.kf.setImage(with: sourceUrl)

                }
            }

        }

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .black
        self.smoothProgressBarView.backgroundColor = .clear
        self.baseView.backgroundColor = .clear
        self.topView.backgroundColor = .clear

        self.closeImageBaseView.backgroundColor = .clear
        self.closeImageView.setImageColor(color: .white)

        self.smoothProgressBarView.foregroundBarColor = .white
        self.smoothProgressBarView.backgroundBarColor = UIColor.App.scroll

        self.videoBaseView.backgroundColor = .black

        StyleHelper.styleButton(button: self.actionButton)
        self.actionButton.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        self.actionButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .normal)

    }

    func resetProgress() {
        self.smoothProgressBarView.resetProgress()

        self.resetVideo()
    }

    func startProgress() {
        if let contentType = self.viewModel?.contentType {
            switch contentType {
            case .video:
                self.playVideo()

                if let duration = self.videoPlayerViewController.player?.currentItem?.duration.seconds {
                    self.smoothProgressBarView.startProgress(duration: TimeInterval(duration))
                }
                else {
                    self.smoothProgressBarView.startProgress()
                }

            case .image:
                self.smoothProgressBarView.startProgress()
            }
        }

        if let viewModel = self.viewModel {
            self.markedReadAction?(viewModel.storyCellViewModel.id)
        }

    }

    func resumeProgress() {
        self.smoothProgressBarView.resumeAnimation()

        self.resumeVideo()
    }

    func pauseProgress() {
        self.smoothProgressBarView.pauseAnimation()

        self.pauseVideo()
    }

    // Video handling
    private func playVideo() {
        if isReadyToPlayVideo {
            self.videoPlayerViewController.player?.play()
        }
    }

    private func pauseVideo() {
        self.videoPlayerViewController.player?.pause()
    }

    private func resumeVideo() {
        self.videoPlayerViewController.player?.play()
    }

    private func resetVideo() {
        self.videoPlayerViewController.player?.seek(to: CMTime(value: 0, timescale: 1))
        self.videoPlayerViewController.player?.pause()
    }

    // Navigation between items
    @objc func didTapNextPageView() {
        if let storyId = self.viewModel?.storyCellViewModel.id {
            self.resetVideo()
            self.nextPageRequestedAction?(storyId)
        }
    }

    @objc func didTapPreviousPageView() {
        self.resetVideo()
        self.previousPageRequestedAction()
    }

    @objc func didTapCloseButton() {
        self.resetVideo()
        self.closeRequestedAction()
    }

    @objc func didTapActionButton() {

        if let linkString = self.viewModel?.storyCellViewModel.link {

            let fullLink = "\(Env.urlApp)\(linkString)"

            self.linkRequestAction?(fullLink)
        }
    }

}

extension StoriesFullScreenItemView {

    func addVideoView(withURL sourceUrl: URL) {

        let playerItem = AVPlayerItem(url: sourceUrl)

        let videoPlayer = AVPlayer(playerItem: playerItem)

        videoPlayer.isMuted = true

        // Observe the playerItem's status
        self.playerItemStatusObserver = playerItem.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in

            switch item.status {
            case .unknown:
                self?.isReadyToPlayVideo = false

            case .readyToPlay:
                self?.isReadyToPlayVideo = true

            case .failed:
                if let error = item.error {
                    print("VideoStatus: Player item error: \( dump(error) )")
                    self?.isReadyToPlayVideo = false
                }
            @unknown default:
                self?.isReadyToPlayVideo = false
            }

        }

        //
        //
        self.videoPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.videoPlayerViewController.showsPlaybackControls = false
        self.videoPlayerViewController.player = videoPlayer
        self.videoPlayerViewController.videoGravity = .resizeAspectFill

        self.videoBaseView.addSubview(self.videoPlayerViewController.view)

        NSLayoutConstraint.activate([
            self.videoPlayerViewController.view.topAnchor.constraint(equalTo: self.videoBaseView.topAnchor),
            self.videoPlayerViewController.view.leadingAnchor.constraint(equalTo: self.videoBaseView.leadingAnchor),
            self.videoPlayerViewController.view.trailingAnchor.constraint(equalTo: self.videoBaseView.trailingAnchor),
            self.videoPlayerViewController.view.bottomAnchor.constraint(equalTo: self.videoBaseView.bottomAnchor)
        ])

        if let mainPlayerLayer = self.videoPlayerViewController.view.layer.sublayers?.compactMap({ $0 as? AVPlayerLayer }).first {
            mainPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }

    }

}

extension StoriesFullScreenItemView {

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTapView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSmoothProgressBarView() -> SmoothProgressBarView {
        let view = SmoothProgressBarView(backgroundColor: .gray, foregroundColor: .blue)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTopLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = AppFont.with(type: .semibold, size: 15)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }

    private static func createVideoBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createContentImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private static func createCloseImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "arrow_close_icon")
        imageView.setImageColor(color: .white)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private static func createCloseImageBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createActionButton() -> UIButton {
        let button = UIButton()
        button.setTitle(localized("see"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func setupSubviews() {

        self.addSubview(self.baseView)

        self.baseView.addSubview(self.videoBaseView)
        self.baseView.addSubview(self.contentImageView)
        self.baseView.addSubview(self.previousPageView)
        self.baseView.addSubview(self.nextPageView)

        self.baseView.addSubview(self.topView)

        self.topView.addSubview(self.smoothProgressBarView)
        self.topView.addSubview(self.topLabel)
        self.topView.addSubview(self.closeImageBaseView)
        self.closeImageBaseView.addSubview(self.closeImageView)

        self.baseView.addSubview(self.actionButton)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.videoBaseView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.videoBaseView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.videoBaseView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.videoBaseView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),

            self.contentImageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.contentImageView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.contentImageView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.contentImageView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),

            self.previousPageView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.previousPageView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.previousPageView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
            self.previousPageView.widthAnchor.constraint(equalTo: self.baseView.widthAnchor, multiplier: 0.5),

            self.nextPageView.leadingAnchor.constraint(equalTo: self.previousPageView.trailingAnchor),
            self.nextPageView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.nextPageView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
            self.nextPageView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 66),

            self.topLabel.leadingAnchor.constraint(equalTo: self.smoothProgressBarView.leadingAnchor, constant: 1),
            self.topLabel.trailingAnchor.constraint(equalTo: self.closeImageBaseView.leadingAnchor, constant: -6),
            self.topLabel.bottomAnchor.constraint(equalTo: self.topView.bottomAnchor),
            self.topLabel.topAnchor.constraint(equalTo: self.smoothProgressBarView.bottomAnchor),

            self.closeImageBaseView.heightAnchor.constraint(equalToConstant: 44),
            self.closeImageBaseView.heightAnchor.constraint(equalTo: self.closeImageBaseView.widthAnchor),
            self.closeImageBaseView.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -2),
            self.closeImageBaseView.centerYAnchor.constraint(equalTo: self.topLabel.centerYAnchor),

            self.closeImageView.heightAnchor.constraint(equalToConstant: 22),
            self.closeImageView.heightAnchor.constraint(equalTo: self.closeImageView.widthAnchor),
            self.closeImageView.centerXAnchor.constraint(equalTo: self.closeImageBaseView.centerXAnchor),
            self.closeImageView.centerYAnchor.constraint(equalTo: self.closeImageBaseView.centerYAnchor),

            self.smoothProgressBarView.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 12),
            self.smoothProgressBarView.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -12),
            self.smoothProgressBarView.topAnchor.constraint(equalTo: self.topView.topAnchor, constant: 12),
            self.smoothProgressBarView.heightAnchor.constraint(equalToConstant: 4),
        ])

        NSLayoutConstraint.activate([
            self.actionButton.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.actionButton.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),
            self.actionButton.heightAnchor.constraint(equalToConstant: 50),
            self.actionButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

    }

}
