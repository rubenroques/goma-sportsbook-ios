//
//  CubicScrollView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 06/06/2023.
//

import Foundation
import UIKit

@objc protocol CubicScrollViewDelegate: AnyObject {
    @objc func cubeViewDidScroll(_ cubeView: CubicScrollView)
    @objc func cubeViewDidEndScrolling(_ cubeView: CubicScrollView, toPageIndex pageIndex: Int)
    @objc func cubeViewStartDragging(_ cubeView: CubicScrollView)
    @objc func cubeViewEndDragging(_ cubeView: CubicScrollView)
}

open class CubicScrollView: UIScrollView, UIScrollViewDelegate {

    var currentPage: Int = 0
    weak var cubeDelegate: CubicScrollViewDelegate?

    fileprivate let maxAngle: CGFloat = 60.0

    fileprivate var childViews = [UIView]()

    fileprivate lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        return stackView
    }()

    open override func awakeFromNib() {
        super.awakeFromNib()
        self.configureScrollView()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureScrollView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
    }

    open func addChildViews(_ views: [UIView]) {

        self.stackView.removeAllArrangedSubviews()
        
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.masksToBounds = true

            self.stackView.addArrangedSubview(view)

            self.addConstraint(NSLayoutConstraint(
                item: view,
                attribute: .width,
                relatedBy: .equal,
                toItem: self,
                attribute: .width,
                multiplier: 1,
                constant: 0)
            )

            self.childViews.append(view)
        }

    }

    open func addChildView(_ view: UIView) {
        self.addChildViews([view])
    }

    open func scrollToNextPage(animated: Bool) {
        self.scrollToViewAtIndex(self.currentPage + 1, animated: animated)
    }

    open func scrollToPreviousPage(animated: Bool) {
        self.scrollToViewAtIndex(self.currentPage - 1, animated: animated)
    }

    open func scrollToViewAtIndex(_ index: Int, animated: Bool) {
        if index > -1 && index < childViews.count {

            let width = self.frame.size.width
            let height = self.frame.size.height

            let frame = CGRect(x: CGFloat(index)*width, y: 0, width: width, height: height)
            self.scrollRectToVisible(frame, animated: animated)

            self.currentPage = index
            self.cubeDelegate?.cubeViewDidEndScrolling(self, toPageIndex: index)
        }
    }

    open func setContentOffsetToIndex(_ index: Int) {
        if index > -1 && index < childViews.count {
            let width = self.frame.size.width
            self.contentOffset = CGPoint(x: CGFloat(index)*width, y: 0)
            self.currentPage = index
        }
    }

    // MARK: Scroll view delegate

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.transformViewsInScrollView(scrollView)
        self.cubeDelegate?.cubeViewDidScroll(self)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let currentPage = Int(scrollView.contentOffset.x / pageWidth)
        self.currentPage = currentPage
        self.cubeDelegate?.cubeViewDidEndScrolling(self, toPageIndex: currentPage)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.cubeDelegate?.cubeViewStartDragging(self)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.cubeDelegate?.cubeViewEndDragging(self)
    }

    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            // Long press started
            self.cubeDelegate?.cubeViewStartDragging(self)
        }
        else if gestureRecognizer.state == .ended {
            // Long press ended
            self.cubeDelegate?.cubeViewEndDragging(self)
        }
    }

    // MARK: Private methods
    fileprivate func configureScrollView() {

        // Configure scroll view properties

        self.backgroundColor = UIColor.black
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.isPagingEnabled = true
        self.bounces = true
        self.delegate = self

        // Add layout constraints

        self.addSubview(self.stackView)

        self.addConstraint(NSLayoutConstraint(
            item: stackView,
            attribute: NSLayoutConstraint.Attribute.leading,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self,
            attribute: NSLayoutConstraint.Attribute.leading,
            multiplier: 1,
            constant: 0)
        )

        self.addConstraint(NSLayoutConstraint(
            item: stackView,
            attribute: NSLayoutConstraint.Attribute.top,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self,
            attribute: NSLayoutConstraint.Attribute.top,
            multiplier: 1,
            constant: 0)
        )

        self.addConstraint(NSLayoutConstraint(
            item: stackView,
            attribute: NSLayoutConstraint.Attribute.height,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self,
            attribute: NSLayoutConstraint.Attribute.height,
            multiplier: 1,
            constant: 0)
        )

        self.addConstraint(NSLayoutConstraint(
            item: stackView,
            attribute: NSLayoutConstraint.Attribute.centerY,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: self,
            attribute: NSLayoutConstraint.Attribute.centerY,
            multiplier: 1,
            constant: 0)
        )

        self.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutConstraint.Attribute.trailing,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: stackView,
            attribute: NSLayoutConstraint.Attribute.trailing,
            multiplier: 1,
            constant: 0)
        )

        self.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutConstraint.Attribute.bottom,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: stackView,
            attribute: NSLayoutConstraint.Attribute.bottom,
            multiplier: 1,
            constant: 0)
        )

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.3
        self.addGestureRecognizer(longPressGesture)

    }

    fileprivate func transformViewsInScrollView(_ scrollView: UIScrollView) {

        let xOffset = scrollView.contentOffset.x
        let svWidth = scrollView.frame.width
        var deg = maxAngle / bounds.size.width * xOffset

        for index in 0 ..< childViews.count {

            let view = childViews[index]

            deg = index == 0 ? deg : deg - maxAngle
            let rad = deg * CGFloat(Double.pi / 180)

            var transform = CATransform3DIdentity
            transform.m34 = 1 / 500
            transform = CATransform3DRotate(transform, rad, 0, 1, 0)

            view.layer.transform = transform

            let xValue = xOffset / svWidth > CGFloat(index) ? 1.0 : 0.0
            self.setAnchorPoint(CGPoint(x: xValue, y: 0.5), forView: view)

            self.applyShadowForView(view, index: index)
        }
    }

    fileprivate func applyShadowForView(_ view: UIView, index: Int) {

        let width = self.frame.size.width
        let height = self.frame.size.height

        let r1 = self.frameFor(origin: contentOffset,
                               size: self.frame.size)
        
        let r2 = self.frameFor(origin: CGPoint(x: CGFloat(index)*width, y: 0),
                          size: CGSize(width: width, height: height))

        // Only show shadow on right-hand side
        if r1.origin.x <= r2.origin.x {

            let intersection = r1.intersection(r2)
            let intArea = intersection.size.width*intersection.size.height
            let union = r1.union(r2)
            let unionArea = union.size.width*union.size.height

            view.layer.opacity = Float(intArea / unionArea)
        }
    }

    fileprivate func setAnchorPoint(_ anchorPoint: CGPoint, forView view: UIView) {

        var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x, y: view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x, y: view.bounds.size.height * view.layer.anchorPoint.y)

        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)

        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }

    fileprivate func frameFor(origin: CGPoint, size: CGSize) -> CGRect {
        return CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
    }
}
