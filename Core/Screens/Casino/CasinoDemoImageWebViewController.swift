//
//  CasinoDemoImageWebViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/02/2025.
//

import UIKit
import Combine

// MARK: - Option 1: TopAlignedImageView
class TopAlignedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let image = image else { return }
        
        // Scale the image based on the view's width
        let scale = bounds.width / image.size.width
        let scaledHeight = image.size.height * scale
        
        // If the image’s scaled height is taller than the view, only show the top portion.
        if scaledHeight > bounds.height {
            let visibleFraction = bounds.height / scaledHeight
            layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: visibleFraction)
        } else {
            layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
    }
}

class CasinoDemoImageWebViewController: UIViewController {
    
    // MARK: - Private Properties
    // Instead of the webView, we now create a scroll view that will host our image.
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // Hold a reference to the top aligned image view
    private var topAlignedImageView: TopAlignedImageView?
    
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var botttomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var cancellables = Set<AnyCancellable>()
    private var viewModel: CasinoViewModel

    init(viewModel: CasinoViewModel = CasinoViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSubviews()
        self.setupWithTheme()

        self.viewModel.isUserLoggedPublisher
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.refreshContent()
            }
            .store(in: &self.cancellables)
        
        // Load the long image
        self.loadImage()
    }
    
    @objc func refreshContent() {
        // Here you can reload or update your image if needed.
        self.loadImage()
    }
    
    func loadImage() {
        // Assuming you have a long image in your assets named "longImage"
        guard let image = UIImage(named: "casino_dummy_image") else { return }
        
        // Calculate the proper scaling so that the image fills side-to-side
        let width = self.view.frame.width
        let scale = width / image.size.width
        let height = image.size.height * scale
        
        // Remove any existing image view from the scroll view
        self.topAlignedImageView?.removeFromSuperview()
        
        // Create and configure the custom image view
        let imageView = TopAlignedImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        // Add to the scroll view and update its content size
        self.scrollView.addSubview(imageView)
        self.scrollView.contentSize = CGSize(width: width, height: height)
        self.topAlignedImageView = imageView
    }
    
    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.hideLoading()
        self.setupWithTheme()
    }
    
    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.botttomSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.loadingBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.loadingActivityIndicatorView.color = UIColor.lightGray
    }
    
    private func showLoading() {
        self.loadingBaseView.isHidden = false
        self.loadingActivityIndicatorView.startAnimating()
    }
    
    private func hideLoading() {
        self.loadingBaseView.isHidden = true
        self.loadingActivityIndicatorView.stopAnimating()
    }
}

// MARK: - Subviews and Constraints Setup
extension CasinoDemoImageWebViewController {
    
    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }
    
    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.botttomSafeAreaView)
        self.view.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)
        
        initConstraints()
    }
    
    private func initConstraints() {
        // Place the scroll view exactly where the web view used to be.
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            
            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.view.topAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])
    }
}
