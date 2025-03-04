//
//  SeeMoreMarketsCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 13/10/2021.
//

import UIKit

class SeeMoreMarketsCollectionViewCell: UICollectionViewCell {

    // MARK: - Private Properties
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var arrowImageView: UIImageView = Self.createArrowImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()

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

    var tappedAction: (() -> Void)?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        setupSubviews()
        setupConstraints()

        // Setup fonts
        self.titleLabel.font = AppFont.with(type: .heavy, size: 14)
        self.subtitleLabel.font = AppFont.with(type: .bold, size: 12)

        self.baseView.layer.cornerRadius = 9

        self.titleLabel.text = localized("see_all")
        self.setupWithTheme()

        let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
        self.addGestureRecognizer(tapMatchView)
    }

    private func setupSubviews() {
        contentView.addSubview(baseView)
        baseView.addSubview(arrowImageView)
        baseView.addSubview(titleLabel)
        baseView.addSubview(subtitleLabel)
        baseView.addSubview(circularProgressView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Base view constraints
            baseView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            baseView.topAnchor.constraint(equalTo: contentView.topAnchor),
            baseView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // Arrow image view constraints
            arrowImageView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
            arrowImageView.bottomAnchor.constraint(equalTo: baseView.centerYAnchor, constant: -7),
            arrowImageView.widthAnchor.constraint(equalToConstant: 28),
            arrowImageView.heightAnchor.constraint(equalTo: arrowImageView.widthAnchor, multiplier: 1.0),

            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: arrowImageView.bottomAnchor, constant: 11),
            titleLabel.centerXAnchor.constraint(equalTo: arrowImageView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -2),

            // Subtitle label constraints
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            subtitleLabel.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 5),
            subtitleLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -5),

            // Circular progress view constraints
            circularProgressView.centerXAnchor.constraint(equalTo: arrowImageView.centerXAnchor),
            circularProgressView.centerYAnchor.constraint(equalTo: arrowImageView.centerYAnchor),
        ])
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

    @objc private func didTapMatchView(_ sender: Any) {
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
}

// MARK: - Factory Methods Extension
private extension SeeMoreMarketsCollectionViewCell {
    static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.333333, alpha: 1.0) // Default color from XIB
        view.layer.cornerRadius = 9
        return view
    }

    static func createArrowImageView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "arrow_circle_right_icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }

    static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "See All"
        label.textColor = UIColor.white
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }

    static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Label"
        label.numberOfLines = 2
        return label
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI

private struct UIViewPreview: UIViewRepresentable {
    let view: UIView

    func makeUIView(context: Context) -> UIView {
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// Create a container to properly display collection view cells
private class PreviewCellContainer: UIView {
    let cell: SeeMoreMarketsCollectionViewCell
    
    init(cell: SeeMoreMarketsCollectionViewCell) {
        self.cell = cell
        super.init(frame: cell.frame)
        self.addSubview(cell)
        // Add a collection view background to simulate real environment
        self.backgroundColor = .clear
        cell.frame = self.bounds
        
        // Apply rounded corners to match cell appearance
        layer.masksToBounds = true
        layer.cornerRadius = 9
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cell.frame = bounds
    }
}

// iOS 17+ Preview with multiple states in a single preview
@available(iOS 17.0, *)
#Preview("SeeMoreMarketsCell States", traits: .sizeThatFitsLayout) {
    // Prepare all cell variations before the View builder
    let defaultCell = SeeMoreMarketsCollectionViewCell(frame: CGRect(x: 0, y: 0, width: 107, height: 114))
    defaultCell.configureWithSubtitleString("10 Markets")
    
    let cell25pct = SeeMoreMarketsCollectionViewCell(frame: CGRect(x: 0, y: 0, width: 107, height: 114))
    cell25pct.configureWithSubtitleString("10 Markets")
    cell25pct.setAnimationPercentage(0.25)
    
    let cell50pct = SeeMoreMarketsCollectionViewCell(frame: CGRect(x: 0, y: 0, width: 107, height: 114))
    cell50pct.configureWithSubtitleString("10 Markets")
    cell50pct.setAnimationPercentage(0.5)
    
    let cell75pct = SeeMoreMarketsCollectionViewCell(frame: CGRect(x: 0, y: 0, width: 107, height: 114))
    cell75pct.configureWithSubtitleString("10 Markets")
    cell75pct.setAnimationPercentage(0.75)
    
    let cell100pct = SeeMoreMarketsCollectionViewCell(frame: CGRect(x: 0, y: 0, width: 107, height: 114))
    cell100pct.configureWithSubtitleString("10 Markets")
    cell100pct.setAnimationPercentage(1.0)
    
    let darkModeCell = SeeMoreMarketsCollectionViewCell(frame: CGRect(x: 0, y: 0, width: 107, height: 114))
    darkModeCell.configureWithSubtitleString("10 Markets")
    darkModeCell.setAnimationPercentage(0.5)
    
    let hiddenSubtitleCell = SeeMoreMarketsCollectionViewCell(frame: CGRect(x: 0, y: 0, width: 107, height: 114))
    hiddenSubtitleCell.hideSubtitle()
    hiddenSubtitleCell.setAnimationPercentage(0.5)
    
    // Now build the SwiftUI view with prepared cells
    return VStack(spacing: 20) {
        HStack(spacing: 20) {
            // Light mode, default state
            VStack {
                UIViewPreview(view: PreviewCellContainer(cell: defaultCell))
                    .frame(width: 107, height: 114)
                Text("Default").font(.caption)
            }
            
            // Light mode, 25% animation
            VStack {
                UIViewPreview(view: PreviewCellContainer(cell: cell25pct))
                    .frame(width: 107, height: 114)
                Text("25%").font(.caption)
            }
            
            // Light mode, 50% animation
            VStack {
                UIViewPreview(view: PreviewCellContainer(cell: cell50pct))
                    .frame(width: 107, height: 114)
                Text("50%").font(.caption)
            }
        }
        
        HStack(spacing: 20) {
            // Light mode, 75% animation
            VStack {
                UIViewPreview(view: PreviewCellContainer(cell: cell75pct))
                    .frame(width: 107, height: 114)
                Text("75%").font(.caption)
            }
            
            // Light mode, 100% animation
            VStack {
                UIViewPreview(view: PreviewCellContainer(cell: cell100pct))
                    .frame(width: 107, height: 114)
                Text("100%").font(.caption)
            }
            
            // Dark mode version
            VStack {
                UIViewPreview(view: PreviewCellContainer(cell: darkModeCell))
                    .frame(width: 107, height: 114)
                    .preferredColorScheme(.dark)
                Text("Dark Mode").font(.caption)
            }
        }
        
        // Hidden subtitle variation
        HStack(spacing: 20) {
            VStack {
                UIViewPreview(view: PreviewCellContainer(cell: hiddenSubtitleCell))
                    .frame(width: 107, height: 114)
                Text("Hidden Subtitle").font(.caption)
            }
        }
    }
    .padding()
    .background(Color(.systemBackground))
}

#endif
