//
//  CardsCollectionViewLayout.swift
//  Sportsbook
//
//  Created by Ruben Roques on 01/06/2023.
//

import Foundation
import UIKit

class QuickSwipeStackCollectionViewLayout: UICollectionViewLayout {

    public var maximumVisibleItems: Int = 4 {
        didSet{
            invalidateLayout()
        }
    }

    private func getItemSize() -> CGSize {
        guard
            let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
            let size = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: IndexPath(item: 0, section: 0))
        else {
            return CGSize(width: 100, height: 80)
        }

        return size
    }

    override open var collectionViewContentSize: CGSize {
        guard
            let collectionView = collectionView
        else {
            return .zero
        }

        let itemsCount = CGFloat(collectionView.numberOfItems(inSection: 0))
        return CGSize(width: collectionView.bounds.width * itemsCount,
                      height: collectionView.bounds.height)
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard
            let collectionView = collectionView
        else {
            return nil
        }

        let totalItemsCount = collectionView.numberOfItems(inSection: 0)

        let minVisibleIndex = max(Int(collectionView.contentOffset.x) / Int(collectionView.bounds.width), 0)
        let maxVisibleIndex = min(minVisibleIndex + maximumVisibleItems, totalItemsCount)

        let deltaOffset = Int(collectionView.contentOffset.x) % Int(collectionView.bounds.width)
        let percentageDeltaOffset = CGFloat(deltaOffset) / collectionView.bounds.width

        let visibleIndices = stride(from: minVisibleIndex, to: maxVisibleIndex, by: 1)

        let attributes: [UICollectionViewLayoutAttributes] = visibleIndices.map { index in
            let indexPath = IndexPath(item: index, section: 0)
            return computeLayoutAttributesForItem(indexPath: indexPath,
                                                  minVisibleIndex: minVisibleIndex,

                                                  deltaOffset: CGFloat(deltaOffset),
                                                  percentageDeltaOffset: percentageDeltaOffset)
        }

        return attributes
    }

    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    func computeLayoutAttributesForItem(indexPath: IndexPath,
                                        minVisibleIndex: Int,
                                        deltaOffset: CGFloat,
                                        percentageDeltaOffset: CGFloat) -> UICollectionViewLayoutAttributes {

        guard
            let collectionView = collectionView
        else {
            return UICollectionViewLayoutAttributes(forCellWith:indexPath)
        }

        var croppedPercentage = percentageDeltaOffset
        if croppedPercentage < 0.0 {
            croppedPercentage = 0.0
        }
        else if croppedPercentage > 1.0 {
            croppedPercentage = 1.0
        }

        let attributes = UICollectionViewLayoutAttributes(forCellWith:indexPath)

        let midY = collectionView.bounds.midY
        let midX = collectionView.bounds.midX
        attributes.center = CGPoint(x: midX, y: midY)

        attributes.size = self.getItemSize()

        attributes.zIndex = maximumVisibleItems - indexPath.row + minVisibleIndex

        let currentIndex = indexPath.row - minVisibleIndex
        switch currentIndex {
        case 0:
            attributes.alpha = 1.0
            attributes.center.x -= deltaOffset
            attributes.transform = .identity

        case 1...3:
            attributes.alpha = currentIndex >= (maximumVisibleItems-1) ? croppedPercentage : 1.0

            let scalePercentage = croppedPercentage * 0.1
            let scaleValue = (1.0 - (CGFloat(currentIndex) / 10.0)) + scalePercentage
            let scaleTransform = CGAffineTransform(scaleX: scaleValue, y: scaleValue)

            let translationPercentage = croppedPercentage * 25.0
            let translationValue = -(25.0 * CGFloat(currentIndex)) + translationPercentage
            let translationTransform = CGAffineTransform.init(translationX: 0, y: translationValue)
            let joinedTransform = translationTransform.concatenating(scaleTransform)

            attributes.transform = joinedTransform
        default:
            attributes.alpha = 0
        }
        return attributes
    }
}
