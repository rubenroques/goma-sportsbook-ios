//
//  SplashInformativeViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/06/2025.
//

import UIKit

class SplashInformativeViewController: UIViewController {
    
    // MARK: - Private Properties
    private lazy var gradientView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var brandImageView: UIImageView = Self.createBrandImageView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()
    private lazy var loadingMessageLabel: UILabel = Self.createLoadingMessageLabel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        setupSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGradient()
        loadingMessageLabel.text = localized("splash_loading")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

// MARK: - Private Methods
private extension SplashInformativeViewController {
    
    func setupSubviews() {
        view.addSubview(gradientView)
        view.addSubview(brandImageView)
        view.addSubview(loadingMessageLabel)
        view.addSubview(activityIndicatorView)
        
        initConstraints()
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            // Gradient View Constraints - Full screen
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Brand Image View Constraints
            brandImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            brandImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            brandImageView.widthAnchor.constraint(equalToConstant: 140),
            brandImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Loading Message Label Constraints
            loadingMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingMessageLabel.topAnchor.constraint(equalTo: brandImageView.bottomAnchor, constant: 20),
            loadingMessageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            loadingMessageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Activity Indicator View Constraints
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func configureGradient() {
        // Set gradient colors from bottom to top
        gradientView.colors = [
            (color: UIColor.App.backgroundGradientDark, location: 0.0),
            (color: UIColor.App.backgroundGradientLight, location: 1.0)
        ]

        gradientView.startPoint = CGPoint(x: 0.5, y: 1.0) // Bottom
        gradientView.endPoint = CGPoint(x: 0.5, y: 0.0)   // Top
    }
    
}

// MARK: - Factory Methods
private extension SplashInformativeViewController {
    
    static func createBrandImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: TargetVariables.brandLogoAssetName)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.tintColor = .white
        return imageView
    }
    
    static func createActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    static func createLoadingMessageLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = AppFont.with(type: .regular, size: 14)
        label.textColor = UIColor.App.textPrimary
        label.numberOfLines = 0
        return label
    }
    
}
