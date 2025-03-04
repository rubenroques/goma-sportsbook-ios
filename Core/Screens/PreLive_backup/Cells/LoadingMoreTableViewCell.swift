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

// MARK: - Preview Helper Classes
private class PreviewTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(LoadingMoreTableViewCell.self, forCellReuseIdentifier: "LoadingMoreTableViewCell")
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = .clear
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 // Show multiple cells for testing
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingMoreTableViewCell") as? LoadingMoreTableViewCell else {
            fatalError("Could not dequeue LoadingMoreTableViewCell")
        }

        // Animate cells alternately for testing
        if indexPath.row % 2 == 0 {
            cell.startAnimating()
        } else {
            cell.stopAnimating()
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69 // Same height as in original XIB
    }
}

// MARK: - UIKit to SwiftUI Bridge
private struct UIKitPreview: UIViewControllerRepresentable {
    let viewController: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// MARK: - Previews
#Preview("Light Mode") {
    UIKitPreview(viewController: PreviewTableViewController())
}

#Preview("Dark Mode") {
    UIKitPreview(viewController: PreviewTableViewController())
        .preferredColorScheme(.dark)
}

#endif
