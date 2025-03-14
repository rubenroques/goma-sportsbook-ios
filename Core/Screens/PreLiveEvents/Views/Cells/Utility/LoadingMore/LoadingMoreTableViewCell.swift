//
//  LoadingMoreTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/10/2021.
//

import UIKit

class LoadingMoreTableViewCell: UITableViewCell {

    // MARK: - Private Properties
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    // MARK: - Lifetime
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.stopAnimating()
    }

    // MARK: - Public Methods
    func startAnimating() {
        self.activityIndicatorView.startAnimating()
    }

    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
    }
}

// MARK: - UI Setup
private extension LoadingMoreTableViewCell {

    private static func createActivityIndicatorView() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = UIColor(white: 0.67, alpha: 1.0)
        view.hidesWhenStopped = true
        view.stopAnimating()
        return view
    }

    private func setupSubviews() {
        self.contentView.addSubview(self.activityIndicatorView)

        NSLayoutConstraint.activate([
            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -8)
        ])
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
}

#if DEBUG
import SwiftUI

// MARK: - Preview State
private enum LoadingMorePreviewState: PreviewStateRepresentable {
    case loading
    case idle

    var title: String {
        switch self {
        case .loading: return "Loading State"
        case .idle: return "Idle State"
        }
    }

    var subtitle: String? {
        switch self {
        case .loading: return "Activity indicator is animating"
        case .idle: return "Activity indicator is hidden"
        }
    }

    var cellHeight: CGFloat? {
        return 69 // Same height as in original XIB
    }
}

// MARK: - Previews
@available(iOS 17.0, *)
#Preview("Light Mode") {
    PreviewUIViewController {
        let states: [LoadingMorePreviewState] = [.loading, .idle]

        return PreviewTableViewController<LoadingMoreTableViewCell, LoadingMorePreviewState>(
            states: states,
            cellClass: LoadingMoreTableViewCell.self,
            defaultCellHeight: 69,
            configurator: { cell, state, _ in
                switch state {
                case .loading:
                    cell.startAnimating()
                case .idle:
                    cell.stopAnimating()
                }
            }
        )
    }
}

@available(iOS 17.0, *)
#Preview("Dark Mode") {
    PreviewUIViewController {
        let states: [LoadingMorePreviewState] = [.loading, .idle]

        return PreviewTableViewController<LoadingMoreTableViewCell, LoadingMorePreviewState>(
            states: states,
            cellClass: LoadingMoreTableViewCell.self,
            defaultCellHeight: 69,
            configurator: { cell, state, _ in
                switch state {
                case .loading:
                    cell.startAnimating()
                case .idle:
                    cell.stopAnimating()
                }
            }
        )
    }
    .preferredColorScheme(.dark)
}

#endif
