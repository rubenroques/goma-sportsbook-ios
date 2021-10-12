import UIKit

class FadeInCenterHorizontalFlowLayout: UICollectionViewFlowLayout {

    // If the cell is in between this middle position it will appear as a normal cell
    var normalCellMiddleMarginMultiplier = 0.19
    var alpha = 0.9
    var minimumScale = 0.8

    override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.scrollDirection = .horizontal
    }

    override func prepare() {
        super.prepare()
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard
            let collectionView = self.collectionView,
            let attributes = super.layoutAttributesForElements(in: rect) else {
            return super.layoutAttributesForElements(in: rect)
        }

        let maxdistance = collectionView.frame.size.width/2

        let offset = collectionView.contentOffset
        let middleNormalCellZone = CGFloat(normalCellMiddleMarginMultiplier) * collectionView.frame.size.width

        let offsetMiddle = offset.x + collectionView.frame.size.width/2

        let leftOffsetPosition = offsetMiddle-middleNormalCellZone
        let rightOffsetPosition = offsetMiddle+middleNormalCellZone

        attributes.forEach { att in

            // is between
            if leftOffsetPosition...rightOffsetPosition ~= att.center.x {
                att.alpha = 1.0
                att.transform = .identity
            }
            else {
                let distanceToCenter = abs(att.center.x - offsetMiddle)-middleNormalCellZone

                var distanceToCenterPercentage = distanceToCenter/maxdistance
                if distanceToCenterPercentage > CGFloat(alpha) {
                    distanceToCenterPercentage = CGFloat(alpha)
                }
                att.alpha = 1.0 - distanceToCenterPercentage

                let minimumScaleValue = CGFloat(minimumScale)
                let reversedDistanceToCenterPercentage = 1.0 - distanceToCenterPercentage
                let remainingValue = (1.0-minimumScaleValue) * reversedDistanceToCenterPercentage

                att.transform = .init(scaleX: minimumScaleValue+remainingValue, y: minimumScaleValue+remainingValue)

            }
        }

        return attributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        if let collectionView = self.collectionView {
            let cvBounds = collectionView.bounds
            let halfWidth = cvBounds.size.width * 0.5
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth
            if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {
                var candidateAttributes: UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {
                    if attributes.representedElementCategory != UICollectionView.ElementCategory.cell {
                        continue
                    }
                    if let candAttrs = candidateAttributes {
                        let aDiff = attributes.center.x - proposedContentOffsetCenterX
                        let bDiff = candAttrs.center.x - proposedContentOffsetCenterX
                        if fabsf(Float(aDiff)) < fabsf(Float(bDiff)) {
                            candidateAttributes = attributes
                        }
                    }
                    else {
                        candidateAttributes = attributes
                        continue
                    }
                }
                return CGPoint(x: round(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
            }
        }
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }

}
