import UIKit

/// Coordinates progress segment layout and animations with manual constraint-based width animations
///
/// This coordinator manages a collection of progress segments with coordinated animations where
/// all segments resize simultaneously when segments are added or removed, creating a smooth
/// "push" effect rather than instant repositioning.
///
/// **Usage Example:**
/// ```swift
/// private let segmentCoordinator = ProgressSegmentCoordinator()
///
/// // Update segments
/// segmentCoordinator.updateSegments(
///     filledCount: 2,
///     totalCount: 3,
///     in: progressContainer,
///     animated: true
/// )
///
/// // Handle layout changes (e.g., rotation)
/// override func layoutSubviews() {
///     super.layoutSubviews()
///     segmentCoordinator.handleLayoutUpdate(
///         containerWidth: progressContainer.bounds.width
///     )
/// }
/// ```
final class ProgressSegmentCoordinator {

    // MARK: - State

    /// The progress segment views being managed
    private(set) var segments: [ProgressSegmentView] = []

    /// Width constraints for animating segment widths
    private var widthConstraints: [NSLayoutConstraint] = []

    /// Leading constraints for chaining segments together
    private var leadingConstraints: [NSLayoutConstraint] = []

    // MARK: - Width Calculation

    /// Calculates the target width for each segment based on container width and segment count
    /// - Parameters:
    ///   - count: Total number of segments
    ///   - containerWidth: Available width in the container
    /// - Returns: Width in points for each segment
    func calculateSegmentWidth(for count: Int, containerWidth: CGFloat) -> CGFloat {
        guard count > 0 else { return 0 }
        let totalGaps = CGFloat(max(0, count - 1)) * 2.0  // 2px gaps between segments
        return (containerWidth - totalGaps) / CGFloat(count)
    }

    // MARK: - Layout Management

    /// Sets up or updates constraints for all segments with manual layout
    /// - Parameters:
    ///   - container: The container view that holds the segments
    ///   - targetWidth: The width each segment should have (use 0 for new segments before animation)
    func layoutSegments(
        in container: UIView,
        targetWidth: CGFloat? = nil
    ) {
        // Clear old constraints
        NSLayoutConstraint.deactivate(widthConstraints + leadingConstraints)
        widthConstraints.removeAll()
        leadingConstraints.removeAll()

        let width = targetWidth ?? calculateSegmentWidth(
            for: segments.count,
            containerWidth: container.bounds.width
        )

        // Create new constraints for each segment
        for (index, segment) in segments.enumerated() {
            // Width constraint (animatable)
            let widthConstraint = segment.widthAnchor.constraint(equalToConstant: width)
            widthConstraints.append(widthConstraint)

            // Leading constraint (chains segments together with 2px gaps)
            let leadingConstraint: NSLayoutConstraint
            if index == 0 {
                leadingConstraint = segment.leadingAnchor.constraint(equalTo: container.leadingAnchor)
            } else {
                leadingConstraint = segment.leadingAnchor.constraint(
                    equalTo: segments[index - 1].trailingAnchor,
                    constant: 2
                )
            }
            leadingConstraints.append(leadingConstraint)

            // Activate all constraints
            NSLayoutConstraint.activate([
                widthConstraint,
                leadingConstraint,
                segment.heightAnchor.constraint(equalToConstant: 8),
                segment.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        }
    }

    // MARK: - Segment Updates

    /// Updates progress segments with diff-based approach and coordinated width animations
    /// - Parameters:
    ///   - filledCount: Number of segments that should be filled (for wave effect)
    ///   - totalCount: Total number of segments to display
    ///   - container: The container view that holds the segments
    ///   - animated: Whether to animate changes (default: true)
    func updateSegments(
        filledCount: Int,
        totalCount: Int,
        in container: UIView,
        animated: Bool = true
    ) {
        let currentCount = segments.count
        let containerWidth = container.bounds.width

        // 1. Add segments - coordinated animation with all segments
        if totalCount > currentCount {
            // Create new segments
            let newSegments = (currentCount..<totalCount).map { _ -> ProgressSegmentView in
                let segment = ProgressSegmentView()
                segment.translatesAutoresizingMaskIntoConstraints = false
                return segment
            }

            // Add to container and array
            newSegments.forEach { container.addSubview($0) }
            segments.append(contentsOf: newSegments)

            // Calculate old and new target widths
            let oldTargetWidth = calculateSegmentWidth(for: currentCount, containerWidth: containerWidth)
            let newTargetWidth = calculateSegmentWidth(for: totalCount, containerWidth: containerWidth)

            // Set up constraints - new segments start with width 0
            layoutSegments(in: container, targetWidth: 0)

            // Set existing segments to their old width
            for i in 0..<currentCount {
                widthConstraints[i].constant = oldTargetWidth
            }

            // Force layout before animation
            container.layoutIfNeeded()

            if animated {
                // Animate all segment widths simultaneously
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    options: [.curveEaseOut],
                    animations: {
                        // Animate all segments to new target width
                        self.widthConstraints.forEach { $0.constant = newTargetWidth }
                        container.layoutIfNeeded()
                    }
                )
            } else {
                widthConstraints.forEach { $0.constant = newTargetWidth }
            }
        }
        // 2. Remove segments - coordinated animation
        else if totalCount < currentCount {
            let segmentsToRemove = segments[totalCount...]
            let newTargetWidth = calculateSegmentWidth(for: totalCount, containerWidth: containerWidth)

            if animated {
                UIView.animate(
                    withDuration: 0.2,
                    animations: {
                        // Shrink removed segments to 0
                        for i in totalCount..<self.widthConstraints.count {
                            self.widthConstraints[i].constant = 0
                        }
                        // Expand remaining segments to new target width
                        for i in 0..<totalCount {
                            self.widthConstraints[i].constant = newTargetWidth
                        }
                        container.layoutIfNeeded()
                    },
                    completion: { _ in
                        // Remove segments and their constraints after animation
                        segmentsToRemove.forEach { $0.removeFromSuperview() }

                        // Use segmentsToRemove.count to avoid race conditions with multiple rapid calls
                        let countToRemove = min(segmentsToRemove.count, self.segments.count)
                        guard countToRemove > 0 else { return }
                        self.segments.removeLast(countToRemove)

                        // Rebuild constraints for remaining segments
                        self.layoutSegments(in: container)
                    }
                )
            } else {
                segmentsToRemove.forEach { $0.removeFromSuperview() }

                // Use segmentsToRemove.count to avoid race conditions
                let countToRemove = min(segmentsToRemove.count, segments.count)
                guard countToRemove > 0 else { return }
                segments.removeLast(countToRemove)

                layoutSegments(in: container)
            }
        }
        // 3. Same count - just update widths
        else if currentCount == totalCount {
            let targetWidth = calculateSegmentWidth(for: totalCount, containerWidth: containerWidth)
            widthConstraints.forEach { $0.constant = targetWidth }
        }

        // 4. Update fill state of segments with staggered animation (wave effect)
        for (index, segment) in segments.enumerated() {
            let shouldBeFilled = index < filledCount
            let delay = animated ? Double(index) * 0.05 : 0  // 50ms stagger between segments

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                segment.setFilled(shouldBeFilled, animated: animated)
            }
        }
    }

    // MARK: - Layout Update

    /// Handles layout updates when container resizes (e.g., rotation, dynamic layout)
    /// - Parameter containerWidth: The new container width to calculate segment widths from
    func handleLayoutUpdate(containerWidth: CGFloat) {
        guard !segments.isEmpty else { return }
        let targetWidth = calculateSegmentWidth(for: segments.count, containerWidth: containerWidth)
        widthConstraints.forEach { $0.constant = targetWidth }
    }
}
