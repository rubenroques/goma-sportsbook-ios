import SwiftUI
import UIKit

@available(iOS 17.0, *)
struct PreviewUIView<View: UIView>: UIViewRepresentable {
    private let builder: (() -> View)?

    private let view: View?

    init(_ builder: @escaping () -> View) {
        self.builder = builder
        self.view = nil
    }

    init(view: View) {
        self.view = view
        self.builder = nil
    }

    func makeUIView(context: Context) -> View {
        return builder?() ?? view!
    }

    func updateUIView(_ uiView: View, context: Context) {}
}

///
/// Represents a game score in the preview
struct GameScore {
    let gameTitle: String
    let score: Int
    let highScore: Int
}

class RetroScoreboardView: UIView {
    private let gameTitleLabel = UILabel()
    private let scoreLabel = UILabel()
    private let highScoreLabel = UILabel()
    private let startButton = UIButton()

    private let gameScore: GameScore

    init(gameScore: GameScore) {
        self.gameScore = gameScore
        super.init(frame: .zero)
        setupUI()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .black
        layer.cornerRadius = 10
        layer.borderWidth = 3
        layer.borderColor = UIColor.green.cgColor

        // Setup Game Title Label
        gameTitleLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        gameTitleLabel.textColor = .green
        gameTitleLabel.textAlignment = .center
        addSubview(gameTitleLabel)

        // Setup Score Label
        scoreLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .bold)
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .center
        addSubview(scoreLabel)

        // Setup High Score Label
        highScoreLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        highScoreLabel.textColor = .yellow
        highScoreLabel.textAlignment = .center
        addSubview(highScoreLabel)

        // Setup Start Button
        startButton.setTitle("▶ PRESS START", for: .normal)
        startButton.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        startButton.setTitleColor(.green, for: .normal)
        startButton.layer.borderWidth = 2
        startButton.layer.borderColor = UIColor.green.cgColor
        startButton.layer.cornerRadius = 5
        addSubview(startButton)

        // Layout Constraints
        gameTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        highScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            gameTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            gameTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            gameTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            scoreLabel.topAnchor.constraint(equalTo: gameTitleLabel.bottomAnchor, constant: 12),
            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            highScoreLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8),
            highScoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            startButton.topAnchor.constraint(equalTo: highScoreLabel.bottomAnchor, constant: 12),
            startButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 150),
            startButton.heightAnchor.constraint(equalToConstant: 40),
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    private func configure() {
        gameTitleLabel.text = gameScore.gameTitle
        scoreLabel.text = "SCORE: \(gameScore.score)"
        highScoreLabel.text = "HIGH SCORE: \(gameScore.highScore)"
    }
}

@available(iOS 17.0, *)
#Preview("Retro Game Usage Example") {
    PreviewUIView {
        RetroScoreboardView(
            gameScore: GameScore(gameTitle: "SPACE INVADERS", score: 1450, highScore: 6780)
        )
    }
}

@available(iOS 17.0, *)
#Preview("All Game Usage Example ") {
    VStack {
        PreviewUIView {
            RetroScoreboardView(
                gameScore: GameScore(gameTitle: "PAC-MAN", score: 2200, highScore: 9840)
            )
        }
        PreviewUIView {
            RetroScoreboardView(
                gameScore: GameScore(gameTitle: "TETRIS", score: 410, highScore: 7800)
            )
        }
        PreviewUIView {
            RetroScoreboardView(
                gameScore: GameScore(gameTitle: "DONKEY KONG", score: 800, highScore: 5500)
            )
        }
    }
}
