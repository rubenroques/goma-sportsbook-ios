
import UIKit

class SnapCenterLayout: UICollectionViewFlowLayout {
  override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
    guard let collectionView = collectionView else {
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }
    let parent = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)

    let itemSpace = itemSize.width + minimumInteritemSpacing
    var currentItemIdx = round(collectionView.contentOffset.x / itemSpace)

    // Skip to the next cell, if there is residual scrolling velocity left.
    // This helps to prevent glitches
    let vX = velocity.x
    if vX > 0 {
      currentItemIdx += 1
    } else if vX < 0 {
      currentItemIdx -= 1
    }

    let nearestPageOffset = currentItemIdx * itemSpace
    return CGPoint(x: nearestPageOffset,
                   y: parent.y)
  }
}

class CenterCellCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var rightOffset: CGFloat
    
    init(rightOffset: CGFloat = 0.0) {
        self.rightOffset = rightOffset
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        if let collectionView = self.collectionView {
            let cvBounds = collectionView.bounds
            let halfWidth = cvBounds.size.width * 0.5;
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth;
            if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {
                var candidateAttributes : UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {
                    if attributes.representedElementCategory != UICollectionView.ElementCategory.cell {
                        continue
                    }
                    if let candAttrs = candidateAttributes {
                        let a = attributes.center.x - proposedContentOffsetCenterX
                        let b = candAttrs.center.x - proposedContentOffsetCenterX
                        if fabsf(Float(a)) < fabsf(Float(b)) {
                            candidateAttributes = attributes;
                        }
                    }
                    else {
                        candidateAttributes = attributes;
                        continue;
                    }
                }
                return CGPoint(x: rightOffset + round(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
            }
        }
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
}

