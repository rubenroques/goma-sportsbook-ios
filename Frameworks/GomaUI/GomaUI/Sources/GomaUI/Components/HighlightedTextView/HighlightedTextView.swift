import Foundation
import UIKit
import Combine
import SwiftUI

public final class HighlightedTextView: UIView {
    
    // MARK: - UI Components
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    private let viewModel: HighlightedTextViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(viewModel: HighlightedTextViewModelProtocol = MockHighlightedTextViewModel.defaultMock()) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MockHighlightedTextViewModel.defaultMock()
        super.init(coder: coder)
        setupViews()
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        backgroundColor = .clear
        
        addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.configure(with: data)
            }
            .store(in: &cancellables)
    }
    
    private func configure(with data: HighlightedTextData) {
        // Set text alignment
        textLabel.textAlignment = data.textAlignment
        
        // Create paragraph style for line height
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        
        // Create attributed string
        let attributedString = NSMutableAttributedString(
            string: data.fullText,
            attributes: [
                .font: StyleProvider.fontWith(type: data.baseFontType, size: data.baseFontSize),
                .foregroundColor: StyleProvider.Color.textPrimary,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        // Apply highlights
        for highlight in data.highlights {
            for range in highlight.ranges {
                // Validate range
                if range.location + range.length <= data.fullText.count {
                    var attributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: highlight.color,
                        .font: StyleProvider.fontWith(type: highlight.type.fontType, size: highlight.type.fontSize)
                    ]
                    
                    // Add underline for link type
                    if highlight.type.isUnderlined {
                        attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                        attributes[.underlineColor] = highlight.color
                    }
                    
                    attributedString.addAttributes(attributes, range: range)
                }
            }
        }
        
        textLabel.attributedText = attributedString
    }
}

// MARK: - Helper Extensions
public extension HighlightedTextView {
    static func findRanges(of substring: String, in text: String) -> [NSRange] {
        var ranges: [NSRange] = []
        var searchRange = NSRange(location: 0, length: text.count)
        
        while searchRange.location < text.count {
            let foundRange = (text as NSString).range(of: substring, options: [], range: searchRange)
            if foundRange.location != NSNotFound {
                ranges.append(foundRange)
                searchRange = NSRange(
                    location: foundRange.location + foundRange.length,
                    length: text.count - (foundRange.location + foundRange.length)
                )
            } else {
                break
            }
        }
        
        return ranges
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
#Preview("HighlightedTextView") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "HighlightedTextView"
        titleLabel.font = StyleProvider.fontWith(type: .bold, size: 18)
        titleLabel.textColor = StyleProvider.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Default (left-aligned)
        let defaultView = HighlightedTextView(viewModel: MockHighlightedTextViewModel.defaultMock())
        defaultView.translatesAutoresizingMaskIntoConstraints = false

        // Center aligned
        let centeredView = HighlightedTextView(viewModel: MockHighlightedTextViewModel.centeredMock())
        centeredView.translatesAutoresizingMaskIntoConstraints = false

        // Right aligned
        let rightAlignedView = HighlightedTextView(viewModel: MockHighlightedTextViewModel.rightAlignedMock())
        rightAlignedView.translatesAutoresizingMaskIntoConstraints = false

        // Multiple highlights
        let multipleHighlightsView = HighlightedTextView(viewModel: MockHighlightedTextViewModel.multipleHighlightsMock())
        multipleHighlightsView.translatesAutoresizingMaskIntoConstraints = false

        // Link highlights (underlined)
        let linkView = HighlightedTextView(viewModel: MockHighlightedTextViewModel.linkMock())
        linkView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(defaultView)
        stackView.addArrangedSubview(centeredView)
        stackView.addArrangedSubview(rightAlignedView)
        stackView.addArrangedSubview(multipleHighlightsView)
        stackView.addArrangedSubview(linkView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}
#endif
