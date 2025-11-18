import UIKit

class ScoreCellView: UIView {
    
    // MARK: - Private Properties
    private lazy var backgroundView: UIView = Self.createBackgroundView()
    private lazy var homeScoreLabel: UILabel = Self.createScoreLabel()
    private lazy var awayScoreLabel: UILabel = Self.createScoreLabel()

    private var widthConstraint: NSLayoutConstraint!
    private let data: ScoreDisplayData
    
    // MARK: - Initialization
    init(data: ScoreDisplayData) {
        self.data = data
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        configure(with: data)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(backgroundView)
        addSubview(homeScoreLabel)
        addSubview(awayScoreLabel)

        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func setupConstraints() {
        widthConstraint = backgroundView.widthAnchor.constraint(greaterThanOrEqualToConstant: 28)

        NSLayoutConstraint.activate([
            // Background view
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 42),
            widthConstraint,

            // Home score (top)
            homeScoreLabel.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            homeScoreLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            homeScoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            homeScoreLabel.heightAnchor.constraint(equalToConstant: 20),

            // Away score (bottom)
            awayScoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            awayScoreLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            awayScoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            awayScoreLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func configure(with data: ScoreDisplayData) {
        homeScoreLabel.text = data.homeScore
        awayScoreLabel.text = data.awayScore
        applyStyle(data.style)
        updateScoreHighlighting()
    }
    
    private func applyStyle(_ style: ScoreCellStyle) {
        switch style {
        case .simple:
            widthConstraint.constant = 26
            homeScoreLabel.textColor = StyleProvider.Color.highlightPrimary
            awayScoreLabel.textColor = StyleProvider.Color.highlightPrimary
            backgroundView.backgroundColor = .clear
            backgroundView.layer.borderWidth = 0
            backgroundView.layer.borderColor = nil
            
        case .border:
            widthConstraint.constant = 26
            homeScoreLabel.textColor = StyleProvider.Color.textPrimary
            awayScoreLabel.textColor = StyleProvider.Color.textPrimary
            backgroundView.backgroundColor = .clear
            backgroundView.layer.borderWidth = 1
            backgroundView.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
            
        case .background:
            widthConstraint.constant = 29
            homeScoreLabel.textColor = StyleProvider.Color.highlightPrimary
            awayScoreLabel.textColor = StyleProvider.Color.highlightPrimary
            backgroundView.backgroundColor = StyleProvider.Color.backgroundPrimary
            backgroundView.layer.borderWidth = 0
            backgroundView.layer.borderColor = nil
        }
    }
    
    private func updateScoreHighlighting() {
        switch data.highlightingMode {
        case .winnerLoser:
            // Winner/loser highlighting for completed sets
            // Always full opacity
            homeScoreLabel.alpha = 1.0
            awayScoreLabel.alpha = 1.0

            // Compare scores as strings
            if data.homeScore > data.awayScore {
                homeScoreLabel.textColor = StyleProvider.Color.textPrimary    // Black - winner
                awayScoreLabel.textColor = StyleProvider.Color.textSecondary  // Gray - loser
            } else if data.awayScore > data.homeScore {
                homeScoreLabel.textColor = StyleProvider.Color.textSecondary  // Gray - loser
                awayScoreLabel.textColor = StyleProvider.Color.textPrimary    // Black - winner
            } else {
                // Tied - both black
                homeScoreLabel.textColor = StyleProvider.Color.textPrimary
                awayScoreLabel.textColor = StyleProvider.Color.textPrimary
            }

        case .bothHighlight:
            // Both scores highlighted (current game/set, match total)
            homeScoreLabel.textColor = StyleProvider.Color.highlightPrimary
            awayScoreLabel.textColor = StyleProvider.Color.highlightPrimary
            homeScoreLabel.alpha = 1.0
            awayScoreLabel.alpha = 1.0

        case .noHighlight:
            // Default styling - both same color
            homeScoreLabel.textColor = StyleProvider.Color.textPrimary
            awayScoreLabel.textColor = StyleProvider.Color.textPrimary
            homeScoreLabel.alpha = 1.0
            awayScoreLabel.alpha = 1.0
        }
    }
    
    // MARK: - Factory Methods
    private static func createBackgroundView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        return view
    }

    private static func createScoreLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 15)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }
}

// MARK: - SwiftUI Previews
#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("ScoreCellView States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemGray6

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Section headers helper
        func createSectionLabel(_ text: String) -> UILabel {
            let label = UILabel()
            label.text = text
            label.font = StyleProvider.fontWith(type: .bold, size: 18)
            label.textColor = StyleProvider.Color.textPrimary
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }

        // Row container helper
        func createRowContainer(with views: [UIView], spacing: CGFloat = 12) -> UIStackView {
            let rowStack = UIStackView(arrangedSubviews: views)
            rowStack.axis = .horizontal
            rowStack.spacing = spacing
            rowStack.alignment = .center
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            return rowStack
        }

        // SIMPLE STYLE VARIATIONS
        stackView.addArrangedSubview(createSectionLabel("Simple Style (with winner highlighting)"))

        // Home team winning scenarios
        let simpleHomeWin1 = ScoreCellView(data: ScoreDisplayData(id: "1", homeScore: "3", awayScore: "1", style: .simple))
        let simpleHomeWin2 = ScoreCellView(data: ScoreDisplayData(id: "2", homeScore: "15", awayScore: "0", style: .simple))
        let simpleHomeWin3 = ScoreCellView(data: ScoreDisplayData(id: "3", homeScore: "105", awayScore: "98", style: .simple))
        let simpleHomeWin4 = ScoreCellView(data: ScoreDisplayData(id: "4", homeScore: "A", awayScore: "40", style: .simple))
        stackView.addArrangedSubview(createRowContainer(with: [simpleHomeWin1, simpleHomeWin2, simpleHomeWin3, simpleHomeWin4]))

        // Away team winning scenarios
        let simpleAwayWin1 = ScoreCellView(data: ScoreDisplayData(id: "5", homeScore: "1", awayScore: "4", style: .simple))
        let simpleAwayWin2 = ScoreCellView(data: ScoreDisplayData(id: "6", homeScore: "12", awayScore: "18", style: .simple))
        let simpleAwayWin3 = ScoreCellView(data: ScoreDisplayData(id: "7", homeScore: "89", awayScore: "112", style: .simple))
        let simpleAwayWin4 = ScoreCellView(data: ScoreDisplayData(id: "8", homeScore: "30", awayScore: "40", style: .simple))
        stackView.addArrangedSubview(createRowContainer(with: [simpleAwayWin1, simpleAwayWin2, simpleAwayWin3, simpleAwayWin4]))

        // Tied scenarios
        let simpleTied1 = ScoreCellView(data: ScoreDisplayData(id: "9", homeScore: "2", awayScore: "2", style: .simple))
        let simpleTied2 = ScoreCellView(data: ScoreDisplayData(id: "10", homeScore: "15", awayScore: "15", style: .simple))
        let simpleTied3 = ScoreCellView(data: ScoreDisplayData(id: "11", homeScore: "0", awayScore: "0", style: .simple))
        let simpleTied4 = ScoreCellView(data: ScoreDisplayData(id: "12", homeScore: "40", awayScore: "40", style: .simple))
        stackView.addArrangedSubview(createRowContainer(with: [simpleTied1, simpleTied2, simpleTied3, simpleTied4]))

        // BORDER STYLE VARIATIONS
        stackView.addArrangedSubview(createSectionLabel("Border Style (no highlighting)"))

        let borderVar1 = ScoreCellView(data: ScoreDisplayData(id: "13", homeScore: "3", awayScore: "1", style: .border))
        let borderVar2 = ScoreCellView(data: ScoreDisplayData(id: "14", homeScore: "1", awayScore: "4", style: .border))
        let borderVar3 = ScoreCellView(data: ScoreDisplayData(id: "15", homeScore: "78", awayScore: "82", style: .border))
        let borderVar4 = ScoreCellView(data: ScoreDisplayData(id: "16", homeScore: "2", awayScore: "2", style: .border))
        stackView.addArrangedSubview(createRowContainer(with: [borderVar1, borderVar2, borderVar3, borderVar4]))

        // BACKGROUND STYLE VARIATIONS
        stackView.addArrangedSubview(createSectionLabel("Background Style (no highlighting)"))

        let backgroundVar1 = ScoreCellView(data: ScoreDisplayData(id: "17", homeScore: "5", awayScore: "2", style: .background))
        let backgroundVar2 = ScoreCellView(data: ScoreDisplayData(id: "18", homeScore: "0", awayScore: "3", style: .background))
        let backgroundVar3 = ScoreCellView(data: ScoreDisplayData(id: "19", homeScore: "95", awayScore: "108", style: .background))
        let backgroundVar4 = ScoreCellView(data: ScoreDisplayData(id: "20", homeScore: "1", awayScore: "1", style: .background))
        stackView.addArrangedSubview(createRowContainer(with: [backgroundVar1, backgroundVar2, backgroundVar3, backgroundVar4]))

        // SPORT-SPECIFIC EXAMPLES
        stackView.addArrangedSubview(createSectionLabel("Sport-Specific Score Examples"))

        // Tennis scores (Simple style)
        let tennis1 = ScoreCellView(data: ScoreDisplayData(id: "21", homeScore: "6", awayScore: "4", style: .simple))
        let tennis2 = ScoreCellView(data: ScoreDisplayData(id: "22", homeScore: "40", awayScore: "15", style: .simple))
        let tennis3 = ScoreCellView(data: ScoreDisplayData(id: "23", homeScore: "A", awayScore: "40", style: .simple))
        stackView.addArrangedSubview(createRowContainer(with: [tennis1, tennis2, tennis3]))

        // Basketball scores (Background style)
        let basketball1 = ScoreCellView(data: ScoreDisplayData(id: "24", homeScore: "28", awayScore: "22", style: .background))
        let basketball2 = ScoreCellView(data: ScoreDisplayData(id: "25", homeScore: "105", awayScore: "112", style: .background))
        let basketball3 = ScoreCellView(data: ScoreDisplayData(id: "26", homeScore: "89", awayScore: "89", style: .background))
        stackView.addArrangedSubview(createRowContainer(with: [basketball1, basketball2, basketball3]))

        // Football scores (Border style)
        let football1 = ScoreCellView(data: ScoreDisplayData(id: "27", homeScore: "2", awayScore: "1", style: .border))
        let football2 = ScoreCellView(data: ScoreDisplayData(id: "28", homeScore: "0", awayScore: "3", style: .border))
        let football3 = ScoreCellView(data: ScoreDisplayData(id: "29", homeScore: "1", awayScore: "1", style: .border))
        stackView.addArrangedSubview(createRowContainer(with: [football1, football2, football3]))

        // HIGHLIGHTING MODE EXAMPLES
        stackView.addArrangedSubview(createSectionLabel("Highlighting Modes"))

        // Winner/Loser highlighting (completed sets)
        let winnerLoser1 = ScoreCellView(data: ScoreDisplayData(id: "wl1", homeScore: "6", awayScore: "4", style: .simple, highlightingMode: .winnerLoser))
        let winnerLoser2 = ScoreCellView(data: ScoreDisplayData(id: "wl2", homeScore: "4", awayScore: "6", style: .simple, highlightingMode: .winnerLoser))
        let winnerLoser3 = ScoreCellView(data: ScoreDisplayData(id: "wl3", homeScore: "25", awayScore: "22", style: .simple, highlightingMode: .winnerLoser))
        stackView.addArrangedSubview(createRowContainer(with: [winnerLoser1, winnerLoser2, winnerLoser3]))

        // Both highlight (current game/set, match total)
        let bothHigh1 = ScoreCellView(data: ScoreDisplayData(id: "bh1", homeScore: "15", awayScore: "30", style: .background, highlightingMode: .bothHighlight))
        let bothHigh2 = ScoreCellView(data: ScoreDisplayData(id: "bh2", homeScore: "7", awayScore: "6", style: .simple, highlightingMode: .bothHighlight))
        let bothHigh3 = ScoreCellView(data: ScoreDisplayData(id: "bh3", homeScore: "105", awayScore: "112", style: .background, highlightingMode: .bothHighlight))
        stackView.addArrangedSubview(createRowContainer(with: [bothHigh1, bothHigh2, bothHigh3]))

        // No highlight
        let noHigh1 = ScoreCellView(data: ScoreDisplayData(id: "nh1", homeScore: "2", awayScore: "1", style: .border, highlightingMode: .noHighlight))
        let noHigh2 = ScoreCellView(data: ScoreDisplayData(id: "nh2", homeScore: "0", awayScore: "0", style: .simple, highlightingMode: .noHighlight))
        let noHigh3 = ScoreCellView(data: ScoreDisplayData(id: "nh3", homeScore: "3", awayScore: "3", style: .background, highlightingMode: .noHighlight))
        stackView.addArrangedSubview(createRowContainer(with: [noHigh1, noHigh2, noHigh3]))

        // EDGE CASES
        stackView.addArrangedSubview(createSectionLabel("Edge Cases & Special Values"))

        // Large numbers
        let large1 = ScoreCellView(data: ScoreDisplayData(id: "30", homeScore: "999", awayScore: "0", style: .simple))
        let large2 = ScoreCellView(data: ScoreDisplayData(id: "31", homeScore: "12", awayScore: "123", style: .border))
        let large3 = ScoreCellView(data: ScoreDisplayData(id: "32", homeScore: "88", awayScore: "99", style: .background))
        stackView.addArrangedSubview(createRowContainer(with: [large1, large2, large3]))

        // Special tennis notation
        let special1 = ScoreCellView(data: ScoreDisplayData(id: "33", homeScore: "AD", awayScore: "40", style: .simple))
        let special2 = ScoreCellView(data: ScoreDisplayData(id: "34", homeScore: "40", awayScore: "AD", style: .simple))
        let special3 = ScoreCellView(data: ScoreDisplayData(id: "35", homeScore: "DEU", awayScore: "40", style: .border))
        stackView.addArrangedSubview(createRowContainer(with: [special1, special2, special3]))

        scrollView.addSubview(stackView)
        vc.view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        return vc
    }
}
#endif
