//
//  PictureInPictureView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/05/2022.
//

import UIKit
import WebKit

class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}

class PictureInPictureView: UIView {

    private lazy var pictureInPictureBackgroundView: UIView = Self.createPictureInPictureBackgroundView()
    private lazy var pictureInPictureView: UIView = Self.createPictureInPictureView()
    private lazy var pictureInPictureCloseView: UIView = Self.pictureInPictureCloseView()
    private lazy var pictureInPictureExpandView: UIView = Self.createPictureInPictureExpandView()
    private var pictureInPictureWebView: WKWebView?

    private var initialMovementOffset: CGPoint = .zero
    private var latestCenterPosition: CGPoint?

    private var pictureInPictureViewWidthConstraint: NSLayoutConstraint?
    private var pictureInPictureViewHeightConstraint: NSLayoutConstraint?

    private let pictureInPictureViewWidth: CGFloat = 192
    private let pictureInPictureViewHeight: CGFloat = 108

    private let horizontalSpacing: CGFloat = 20
    private let verticalSpacing: CGFloat = 20

    private var pictureInPicturePositionViews = [UIView]()
    private var pictureInPicturePositions: [CGPoint] {
        return pictureInPicturePositionViews.map { $0.center }
    }

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

    //
    func commonInit() {
        self.setupSubviews()
        self.setupWithTheme()

        let closeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapPictureInPictureCloseView))
        closeTapGestureRecognizer.numberOfTapsRequired = 1
        self.pictureInPictureCloseView.addGestureRecognizer(closeTapGestureRecognizer)

        let expandTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapPictureInPictureExpandView))
        expandTapGestureRecognizer.numberOfTapsRequired = 1
        self.pictureInPictureExpandView.addGestureRecognizer(expandTapGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapPictureInPictureView))
        tapGestureRecognizer.numberOfTapsRequired = 2
        self.pictureInPictureView.addGestureRecognizer(tapGestureRecognizer)

        let panRecognizer = UIPanGestureRecognizer()
        panRecognizer.addTarget(self, action: #selector(pictureInPicturePanned(recognizer:)))
        self.pictureInPictureView.addGestureRecognizer(panRecognizer)

        // Prepare initial state
        self.pictureInPictureBackgroundView.alpha = 0.0
        self.pictureInPictureView.alpha = 0.0

        self.pictureInPictureCloseView.alpha = 0.0
        self.pictureInPictureExpandView.alpha = 0.0
    }

    private func setupWithTheme() {
        self.backgroundColor = .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.pictureInPictureView.center = self.latestCenterPosition ?? self.center // (pictureInPicturePositions.last ?? .zero)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        // if there are subviews, step through them
        // if the subview contains the point, call hitTest on the subview to see if the subview's subviews contain the point
        // if they do, return the result,
        // if they don't, return the subview that does contain the point.
        for subview in self.subviews.reversed() {

            if subview != self.pictureInPictureView {
                continue
            }

            if subview.alpha == 0.0 {
                continue
            }

            let subPoint = subview.convert(point, from:self)
            if subview.point(inside: subPoint, with: event) == true {
                if let result = subview.hitTest(subPoint, with: event) {
                    return result
                } else {
                    return subview
                }
            }
        }

        return nil

        // none of the subviews contain the point,(or there are no subviews) does the current view contain the point?
        // if yes, return self. otherwise, return nil
//        if self.point(inside: point, with: event) == true {
//            return self
//        } else {
//            return nil
//        }
    }

    @objc private func pictureInPicturePanned(recognizer: UIPanGestureRecognizer) {
        let touchPoint = recognizer.location(in: self)
        switch recognizer.state {
        case .began:
            initialMovementOffset = CGPoint(x: touchPoint.x - pictureInPictureView.center.x, y: touchPoint.y - pictureInPictureView.center.y)

            UIView.animate(withDuration: 0.20) {
                self.pictureInPictureCloseView.alpha = 1.0
                self.pictureInPictureExpandView.alpha = 1.0

                self.pictureInPictureBackgroundView.alpha = 0.0

                self.pictureInPictureViewWidthConstraint?.constant = self.pictureInPictureViewWidth
                self.pictureInPictureViewHeightConstraint?.constant = self.pictureInPictureViewHeight
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }

        case .changed:
            pictureInPictureView.center = CGPoint(x: touchPoint.x - initialMovementOffset.x, y: touchPoint.y - initialMovementOffset.y)
        case .ended, .cancelled:
            let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue
            let velocity = recognizer.velocity(in: self)
            let projectedPosition = CGPoint(
                x: pictureInPictureView.center.x + project(initialVelocity: velocity.x, decelerationRate: decelerationRate),
                y: pictureInPictureView.center.y + project(initialVelocity: velocity.y, decelerationRate: decelerationRate)
            )
            let nearestCornerPosition = nearestCorner(to: projectedPosition)
            let relativeInitialVelocity = CGVector(
                dx: relativeVelocity(forVelocity: velocity.x, from: pictureInPictureView.center.x, to: nearestCornerPosition.x),
                dy: relativeVelocity(forVelocity: velocity.y, from: pictureInPictureView.center.y, to: nearestCornerPosition.y)
            )

            let timingParameters = UISpringTimingParameters(dampingRatio: 1, initialVelocity: relativeInitialVelocity)
            let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
            animator.addAnimations {
                self.pictureInPictureView.center = nearestCornerPosition
            }
            animator.startAnimation()

            self.latestCenterPosition = nearestCornerPosition

        default: break
        }
    }
}

extension PictureInPictureView {
    func playVideo(fromURL url: URL) {
        self.openExternalVideo(fromURL: url)
    }
}

extension PictureInPictureView {

    @objc private func didTapPictureInPictureCloseView() {
        self.hidePictureInPicture()
    }

    @objc private func didTapPictureInPictureExpandView() {
        self.expandPictureInPicture()
    }

    @objc private func didTapPictureInPictureView() {
        self.hidePictureInPicture()
    }

    private func openExternalVideo(fromURL url: URL) {

        self.pictureInPictureWebView?.removeFromSuperview()
        self.pictureInPictureWebView = nil

        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        self.pictureInPictureWebView = WKWebView(frame: .zero, configuration: configuration)
        self.pictureInPictureWebView!.translatesAutoresizingMaskIntoConstraints = false

        let request = URLRequest(url: url)
        self.pictureInPictureWebView!.load(request)

        self.pictureInPictureView.addSubview(self.pictureInPictureWebView!)

        NSLayoutConstraint.activate([
            self.pictureInPictureWebView!.leadingAnchor.constraint(equalTo: self.pictureInPictureView.leadingAnchor),
            self.pictureInPictureWebView!.trailingAnchor.constraint(equalTo: self.pictureInPictureView.trailingAnchor),
            self.pictureInPictureWebView!.bottomAnchor.constraint(equalTo: self.pictureInPictureView.bottomAnchor),
            self.pictureInPictureWebView!.topAnchor.constraint(equalTo: self.pictureInPictureView.topAnchor),
        ])

        self.pictureInPictureView.bringSubviewToFront(self.pictureInPictureCloseView)
        self.pictureInPictureView.bringSubviewToFront(self.pictureInPictureExpandView)

        self.expandPictureInPicture()

        self.showPictureInPicture()
    }

    private func expandPictureInPicture() {

        UIView.animate(withDuration: 0.45) {

            self.latestCenterPosition = self.center
            self.pictureInPictureView.center = self.center

            self.pictureInPictureBackgroundView.alpha = 1.0

            self.pictureInPictureCloseView.alpha = 0.0
            self.pictureInPictureExpandView.alpha = 0.0

            let width = self.frame.size.width - 20
            let height = width * (9/16)

            self.pictureInPictureViewWidthConstraint?.constant = width
            self.pictureInPictureViewHeightConstraint?.constant = height

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    private func hidePictureInPicture() {

        UIView.animate(withDuration: 0.35) {
            self.pictureInPictureView.alpha = 0.0
        }
    completion: { _ in
        self.pictureInPictureWebView?.removeFromSuperview()
        self.pictureInPictureWebView = nil
    }

        UIView.animate(withDuration: 0.3) {
            self.pictureInPictureBackgroundView.alpha = 0.0
        }

    }

    func showPictureInPicture() {

        UIView.animate(withDuration: 0.35) {
            self.pictureInPictureView.alpha = 1.0
        }

        UIView.animate(withDuration: 0.3) {
            self.pictureInPictureBackgroundView.alpha = 1.0
        }

    }

}


extension PictureInPictureView {

    // Distance traveled after decelerating to zero velocity at a constant rate.
    private func project(initialVelocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
        return (initialVelocity / 1000) * decelerationRate / (1 - decelerationRate)
    }

    // Finds the position of the nearest corner to the given point.
    private func nearestCorner(to point: CGPoint) -> CGPoint {
        var minDistance = CGFloat.greatestFiniteMagnitude
        var closestPosition = CGPoint.zero
        for position in pictureInPicturePositions {
            let distance = point.distance(to: position)
            if distance < minDistance {
                closestPosition = position
                minDistance = distance
            }
        }
        return closestPosition
    }

    // Calculates the relative velocity needed for the initial velocity of the animation.
    private func relativeVelocity(forVelocity velocity: CGFloat, from currentValue: CGFloat, to targetValue: CGFloat) -> CGFloat {
        guard currentValue - targetValue != 0 else { return 0 }
        return velocity / (targetValue - currentValue)
    }

}


extension PictureInPictureView {

    private static func createPictureInPictureBackgroundView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.9)

        let tipLabel = UILabel()
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tipLabel.font = AppFont.with(type: .medium, size: 13)
        tipLabel.alpha = 0.5
        tipLabel.textAlignment = .center
        tipLabel.textColor = .white
        tipLabel.text = "Drag video for Miniplayer"
        view.addSubview(tipLabel)

        let imageView = UIImageView.init(image: UIImage(systemName: "multiply.circle"))
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        view.addSubview(imageView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapPictureInPictureCloseView))
        imageView.addGestureRecognizer(tapGesture)

        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 45),
            imageView.heightAnchor.constraint(equalToConstant: 45),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            tipLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tipLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tipLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -24)
        ])
        return view
    }

    private static func pictureInPictureCloseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.buttonActiveHoverSecondary
        view.clipsToBounds = true
        view.layer.cornerRadius = 8

        let imageView = UIImageView.init(image: UIImage(systemName: "multiply"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        view.addSubview(imageView, anchors: [LayoutAnchor.centerX(0), LayoutAnchor.centerY(0), LayoutAnchor.width(17), LayoutAnchor.height(17)])

        return view
    }

    private static func createPictureInPictureView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }

    private static func createPictureInPictureExpandView() -> UIView {

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.buttonActiveHoverSecondary
        view.clipsToBounds = true
        view.layer.cornerRadius = 8

        let imageView = UIImageView.init(image: UIImage(systemName: "arrow.up.left.and.arrow.down.right.circle"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        view.addSubview(imageView, anchors: [LayoutAnchor.centerX(0), LayoutAnchor.centerY(0), LayoutAnchor.width(17), LayoutAnchor.height(17)])

        return view
    }

    private func pictureInPictureCornerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: pictureInPictureViewWidth).isActive = true
        view.heightAnchor.constraint(equalToConstant: pictureInPictureViewHeight).isActive = true
        return view
    }

    private func setupSubviews() {

        let topLeftView = self.pictureInPictureCornerView()
        topLeftView.isUserInteractionEnabled = false
        self.addSubview(topLeftView)
        self.sendSubviewToBack(topLeftView)
        self.pictureInPicturePositionViews.append(topLeftView)
        topLeftView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: horizontalSpacing).isActive = true
        topLeftView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: verticalSpacing).isActive = true

        let topRightView = self.pictureInPictureCornerView()
        topRightView.isUserInteractionEnabled = false
        self.addSubview(topRightView)
        self.sendSubviewToBack(topRightView)
        self.pictureInPicturePositionViews.append(topRightView)
        topRightView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -horizontalSpacing).isActive = true
        topRightView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: verticalSpacing).isActive = true

        let bottomLeftView = self.pictureInPictureCornerView()
        bottomLeftView.isUserInteractionEnabled = false
        self.addSubview(bottomLeftView)
        self.sendSubviewToBack(bottomLeftView)
        self.pictureInPicturePositionViews.append(bottomLeftView)
        bottomLeftView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: horizontalSpacing).isActive = true
        bottomLeftView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -verticalSpacing).isActive = true

        let bottomRightView = self.pictureInPictureCornerView()
        bottomRightView.isUserInteractionEnabled = false
        self.addSubview(bottomRightView)
        self.sendSubviewToBack(bottomRightView)
        self.pictureInPicturePositionViews.append(bottomRightView)
        bottomRightView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -horizontalSpacing).isActive = true
        bottomRightView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -verticalSpacing).isActive = true

        self.addSubview(self.pictureInPictureBackgroundView)
        self.pictureInPictureView.addSubview(self.pictureInPictureCloseView)
        self.pictureInPictureView.addSubview(self.pictureInPictureExpandView)
        self.addSubview(self.pictureInPictureView)

        self.initConstraints()
    }

    private func initConstraints() {

        self.pictureInPictureViewWidthConstraint = self.pictureInPictureView.widthAnchor.constraint(equalToConstant: pictureInPictureViewWidth)
        self.pictureInPictureViewWidthConstraint?.isActive = true
        self.pictureInPictureViewHeightConstraint = self.pictureInPictureView.heightAnchor.constraint(equalToConstant: pictureInPictureViewHeight)
        self.pictureInPictureViewHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            self.pictureInPictureBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.pictureInPictureBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.pictureInPictureBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.pictureInPictureBackgroundView.topAnchor.constraint(equalTo: self.topAnchor),
        ])

        NSLayoutConstraint.activate([
            self.pictureInPictureExpandView.trailingAnchor.constraint(equalTo: self.pictureInPictureView.trailingAnchor, constant: -6),
            self.pictureInPictureExpandView.bottomAnchor.constraint(equalTo: self.pictureInPictureView.bottomAnchor, constant: -7),
            self.pictureInPictureExpandView.widthAnchor.constraint(equalToConstant: 30),
            self.pictureInPictureExpandView.heightAnchor.constraint(equalToConstant: 26),
        ])

        NSLayoutConstraint.activate([
            self.pictureInPictureCloseView.leadingAnchor.constraint(equalTo: self.pictureInPictureView.leadingAnchor, constant: 6),
            self.pictureInPictureCloseView.topAnchor.constraint(equalTo: self.pictureInPictureView.topAnchor, constant: 7),
            self.pictureInPictureCloseView.widthAnchor.constraint(equalToConstant: 30),
            self.pictureInPictureCloseView.heightAnchor.constraint(equalToConstant: 26),
        ])

    }

}
