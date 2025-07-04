//
//  HighlightedTextView.swift
//  GomaUI
//
//  Created by André Lascas on 11/06/2025.
//

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
        
        // Create attributed string
        let attributedString = NSMutableAttributedString(
            string: data.fullText,
            attributes: [
                .font: StyleProvider.fontWith(type: data.baseFontType, size: data.baseFontSize),
                .foregroundColor: StyleProvider.Color.textPrimary
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
struct HighlightedTextView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PreviewUIView {
                HighlightedTextView(viewModel: MockHighlightedTextViewModel.defaultMock())
            }
            .frame(height: 60)
            .previewDisplayName("Default")
            
            PreviewUIView {
                HighlightedTextView(viewModel: MockHighlightedTextViewModel.centeredMock())
            }
            .frame(height: 60)
            .previewDisplayName("Center Aligned")
            
            PreviewUIView {
                HighlightedTextView(viewModel: MockHighlightedTextViewModel.rightAlignedMock())
            }
            .frame(height: 60)
            .previewDisplayName("Right Aligned")
            
            PreviewUIView {
                HighlightedTextView(viewModel: MockHighlightedTextViewModel.multipleHighlightsMock())
            }
            .frame(height: 60)
            .previewDisplayName("Multiple Highlights")
            
            PreviewUIView {
                HighlightedTextView(viewModel: MockHighlightedTextViewModel.linkMock())
            }
            .frame(height: 60)
            .previewDisplayName("Link Highlights")
        }
        .padding()
    }
}
#endif
