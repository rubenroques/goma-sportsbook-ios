//
//  PreviewUIViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 06/03/2025.
//
import UIKit
import SwiftUI

@available(iOS 17.0, *)
struct PreviewUIViewController<ViewController: UIViewController>: UIViewControllerRepresentable {
    private let builder: (() -> ViewController)?
    private let viewController: ViewController?

    init(_ builder: @escaping () -> ViewController) {
        self.builder = builder
        self.viewController = nil
    }

    init(viewController: ViewController) {
        self.viewController = viewController
        self.builder = nil
    }

    func makeUIViewController(context: Context) -> ViewController {
        return builder?() ?? viewController!
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}

/// Represents a movie in the preview
struct Movie {
    let title: String
    let posterName: String
    let rating: Double
    let synopsis: String
}

class MovieDetailViewController: UIViewController {
    private let movie: Movie

    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let ratingLabel = UILabel()
    private let synopsisLabel = UILabel()

    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Setup Poster
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.clipsToBounds = true
        posterImageView.image = UIImage(systemName: movie.posterName) // Placeholder using SF Symbols
        view.addSubview(posterImageView)
        posterImageView.translatesAutoresizingMaskIntoConstraints = false

        // Setup Title Label
        titleLabel.text = movie.title
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Setup Rating Label
        ratingLabel.text = "⭐ \(movie.rating)/10"
        ratingLabel.font = .systemFont(ofSize: 16)
        ratingLabel.textAlignment = .center
        ratingLabel.textColor = .systemYellow
        view.addSubview(ratingLabel)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        // Setup Synopsis Label
        synopsisLabel.text = movie.synopsis
        synopsisLabel.font = .systemFont(ofSize: 14)
        synopsisLabel.textColor = .gray
        synopsisLabel.numberOfLines = 0
        synopsisLabel.textAlignment = .center
        view.addSubview(synopsisLabel)
        synopsisLabel.translatesAutoresizingMaskIntoConstraints = false

        // Layout
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            posterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 120),
            posterImageView.heightAnchor.constraint(equalToConstant: 180),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            ratingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            synopsisLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 12),
            synopsisLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            synopsisLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

@available(iOS 17.0, *)
#Preview("Movie Night Usage Example") {
    PreviewUIViewController {
        MovieDetailViewController(
            movie: Movie(
                title: "Inception",
                posterName: "film.fill",  // Placeholder image
                rating: 9.8,
                synopsis: "A skilled thief is given a chance at redemption if he can successfully perform inceptinceptinception."
            )
        )
    }
}
