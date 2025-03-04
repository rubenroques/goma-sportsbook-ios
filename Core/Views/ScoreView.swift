//
//  ScoreView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/04/2024.
//

import UIKit
import Combine

class ScoreView: UIView {
    
    var cellsBaseStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fill
        return stackView
    }()
    
    var sportCode: String = "" {
        didSet {
            self.configureScores()
        }
    }
    
    var score: [String: Score] = [:] {
        didSet {
            self.configureScores()
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(sportCode: String, score: [String: Score]) {
        self.score = score
        self.sportCode = sportCode
        
        super.init(frame: .zero)
        
        self.setupSubscriptions()
        self.setupView()
        self.configureScores()
    }
    
    @available(iOS, unavailable)
    override init(frame: CGRect) {
        fatalError()
    }
    
    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubscriptions()
        self.setupView()
        self.configureScores()
    }
    
    private func setupSubscriptions() {
        Env.userSessionStore.userProfilePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureScores()
            }
            .store(in: &self.cancellables)
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .vertical)
        
        self.cellsBaseStackView.setContentHuggingPriority(.required, for: .horizontal)
        self.cellsBaseStackView.setContentHuggingPriority(.required, for: .vertical)
        
        self.addSubview(self.cellsBaseStackView)
        
        NSLayoutConstraint.activate([
            self.cellsBaseStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.cellsBaseStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.cellsBaseStackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.cellsBaseStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
    }
    
    func setupWithTheme() {
        self.cellsBaseStackView.arrangedSubviews.forEach({ view in
            if let cell = view as? ScoreCellView {
                cell.setupWithTheme()
            }
        })
    }
    
    func updateScores(_ scores: [String: Score]) {
        if self.score == scores {
            return
        }
        self.score = scores
    }
    
    private func configureScores() {
        if self.sportCode.lowercased().hasPrefix("tns") || self.sportCode.lowercased().contains("tns") {
            self.configureSetsDetailedScores()
        }
        else if self.sportCode.lowercased().hasPrefix("bkb") || self.sportCode.lowercased().contains("bkb") ||
                    self.sportCode.lowercased().hasPrefix("vbl") || self.sportCode.lowercased().contains("vbl") ||
                    self.sportCode.lowercased().hasPrefix("bad") || self.sportCode.lowercased().contains("bad") || // badminton
                    self.sportCode.lowercased().hasPrefix("bvb") || self.sportCode.lowercased().contains("bvb") || // beach volley
                    self.sportCode.lowercased().hasPrefix("tbt") || self.sportCode.lowercased().contains("tbt") ||
                    self.sportCode.lowercased().hasPrefix("snk") || self.sportCode.lowercased().contains("snk") ||
                    self.sportCode.lowercased().hasPrefix("hky") || self.sportCode.lowercased().contains("hky") {
            self.configureDetailedScores()
        }
        else {
            self.configureGenericScores()
        }

    }
    
    private func configureGenericScores() {
        let scores = Array(self.score.values).sorted { scoreLeft, scoreRight in
            return scoreLeft.sortValue < scoreRight.sortValue
        }
        
        self.cellsBaseStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        let scoresCells = scores.map({ score -> ScoreCellView? in
            switch score {
            case .gamePart, .set:
                return nil
            case .matchFull(home: let home, away: let away):
                return ScoreCellView(homeScore: "\(home ?? 0)",
                                     awayScore: "\(away ?? 0)",
                                     style: .background)
            }
        })
        .compactMap({ $0 })
        
        scoresCells.forEach { self.cellsBaseStackView.addArrangedSubview($0) }
    }
    
    private func configureDetailedScores() {
        self.cellsBaseStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        let orderedScores = Array(self.score.values).sorted { scoreLeft, scoreRight in
            return scoreLeft.sortValue < scoreRight.sortValue
        }
        
        var setsScores = orderedScores.filter({ score in
            switch score {
            case .set: return true
            case .gamePart: return false
            case .matchFull: return false
            }
        }).suffix(6)

        let matchFullScores = orderedScores.filter({ score in
            switch score {
            case .set: return false
            case .gamePart: return false
            case .matchFull: return true
            }
        })
        
        guard
            let lastSet = setsScores.last,
            let matchFull = matchFullScores.first
        else {
            return
        }
        
        setsScores.removeLast()
        
        // Add previous sets
        for setsScore in setsScores {
            switch setsScore {
            case .set(_, let home, let away):
                let scoreCellView = ScoreCellView(homeScore: "\(home ?? 0)",
                                              awayScore: "\(away ?? 0)",
                                              style: .simple)
                self.cellsBaseStackView.addArrangedSubview(scoreCellView)
            default:
                break
            }
        }
        
        // Add the current set
        switch lastSet {
        case .set(_, let home, let away):
            let scoreCellView = ScoreCellView(homeScore: "\(home ?? 0)",
                                          awayScore: "\(away ?? 0)",
                                          style: .border)
            self.cellsBaseStackView.addArrangedSubview(scoreCellView)
        default:
            break
        }
        
        // Add the game total value
        switch matchFull {
        case .matchFull(let home, let away):
            let scoreCellView = ScoreCellView(homeScore: "\(home ?? 0)",
                                          awayScore: "\(away ?? 0)",
                                          style: .background)
            self.cellsBaseStackView.addArrangedSubview(scoreCellView)
        default:
            break
        }
        
    }
    
    private func configureSetsDetailedScores() {
        
        self.cellsBaseStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        let orderedScores = Array(self.score.values).sorted { scoreLeft, scoreRight in
            return scoreLeft.sortValue < scoreRight.sortValue
        }
        
        var setsScores = orderedScores.filter({ score in
            switch score {
            case .set: return true
            case .gamePart: return false
            case .matchFull: return false
            }
        }).suffix(6)
        
        let gamePartsScores = orderedScores.filter({ score in
            switch score {
            case .set: return false
            case .gamePart: return true
            case .matchFull: return false
            }
        })
        
        guard
            let lastSet = setsScores.last,
            let gamePartsFirst = gamePartsScores.first
        else {
            return
        }
        
        setsScores.removeLast()
        
        // Add previous sets
        for setsScore in setsScores {
            switch setsScore {
            case .set(_, let home, let away):
                let homeString: String = "\(home ?? 0)"
                let awayString: String = "\(away ?? 0)"
                let scoreCellView = ScoreCellView(homeScore: homeString,
                                              awayScore: awayString,
                                              style: .simple)
                self.cellsBaseStackView.addArrangedSubview(scoreCellView)
            default:
                break
            }
        }
        
        // Add the current set
        switch lastSet {
        case .set(_, let home, let away):
            let homeString: String = "\(home ?? 0)"
            let awayString: String = "\(away ?? 0)"
            let scoreCellView = ScoreCellView(homeScore: homeString,
                                          awayScore: awayString,
                                          style: .border)
            self.cellsBaseStackView.addArrangedSubview(scoreCellView)
        default:
            break
        }
        
        // Add the game part (15, 30, 40)
        switch gamePartsFirst {
        case .gamePart(let home, let away):
//            var homeString: String = (home ?? 0) == 50 ? "A" : "\(home ?? 0)"
//            var awayString: String = (away ?? 0) == 50 ? "A" : "\(away ?? 0)"
//
            let homeValue = home ?? 0
            let awayValue = away ?? 0

            var homeString: String
            var awayString: String

            if self.sportCode.lowercased() == "tns" {
                homeString = homeValue == 50 ? "A" : "\(homeValue)"
                awayString = awayValue == 50 ? "A" : "\(awayValue)"
            }
            else {
                homeString = "\(homeValue)"
                awayString = "\(awayValue)"
            }
            
            if !Env.userSessionStore.isUserLogged() {
                homeString = "-"
                awayString = "-"
            }
            
            let scoreCellView = ScoreCellView(homeScore: homeString,
                                          awayScore: awayString,
                                          style: .background)
            self.cellsBaseStackView.addArrangedSubview(scoreCellView)
        default:
            break
        }
        
    }
    
}

class ScoreCellView: UIView {
    
    private var backgroundColorView: UIView = {
        var view = UIView()
        view.backgroundColor = .blue
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        return view
    }()
    
    private var homeScoreLabel: UILabel = {
        var label = UILabel()
        label.font = AppFont.with(type: .bold, size: 15)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private var awayScoreLabel: UILabel = {
        var label = UILabel()
        label.font = AppFont.with(type: .bold, size: 15)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private var widthContraint: NSLayoutConstraint!
    
    enum Style {
        case simple
        case border
        case background
    }
    
    var style: Style = .simple {
        didSet {
            self.redrawStyle()
        }
    }
    
    var homeScore: String = "" {
        didSet {
            self.homeScoreLabel.text = homeScore
            self.redrawScoreAlpha()
        }
    }
    var awayScore: String = "" {
        didSet {
            self.awayScoreLabel.text = awayScore
            self.redrawScoreAlpha()
        }
    }
    
    //
    init(homeScore: String, awayScore: String, style: Style = .simple) {
        super.init(frame: .zero)
        self.setupView()
        
        self.homeScore = homeScore
        self.awayScore = awayScore
        
        self.homeScoreLabel.text = homeScore
        self.awayScoreLabel.text = awayScore

        self.style = style
        
        self.redrawStyle()
        self.redrawScoreAlpha()
    }
    
    @available(iOS, unavailable)
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.widthContraint = self.backgroundColorView.widthAnchor.constraint(greaterThanOrEqualToConstant: 28)
        self.addSubview(self.backgroundColorView)
        
        self.addSubview(self.homeScoreLabel)
        self.addSubview(self.awayScoreLabel)
        
        NSLayoutConstraint.activate([
            self.backgroundColorView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundColorView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.backgroundColorView.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundColorView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.backgroundColorView.heightAnchor.constraint(equalToConstant: 42),
            self.widthContraint!,
            
            self.homeScoreLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1),
            self.homeScoreLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1),
            self.homeScoreLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            self.homeScoreLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),

            self.awayScoreLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1),
            self.awayScoreLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1),
            self.awayScoreLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1),
            self.awayScoreLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        return self.backgroundColorView.intrinsicContentSize
    }
    
    func setupWithTheme() {
        self.redrawStyle()
    }
    
    func redrawStyle() {
        switch self.style {
        case .simple:
            self.widthContraint.constant = 26
            
            self.homeScoreLabel.textColor = UIColor.App.textSecondary
            self.awayScoreLabel.textColor = UIColor.App.textSecondary
            
            self.backgroundColorView.backgroundColor = .clear
            self.backgroundColorView.layer.borderWidth = 0
            self.backgroundColorView.layer.borderColor = UIColor.App.backgroundOdds.cgColor
        case .border:
            self.widthContraint.constant = 26
            
            self.homeScoreLabel.textColor = UIColor.App.textPrimary
            self.awayScoreLabel.textColor = UIColor.App.textPrimary
            
            self.backgroundColorView.backgroundColor = .clear
            self.backgroundColorView.layer.borderWidth = 1
            self.backgroundColorView.layer.borderColor = UIColor.App.backgroundOdds.cgColor
        case .background:
            self.homeScoreLabel.textColor = UIColor.App.highlightPrimary
            self.awayScoreLabel.textColor = UIColor.App.highlightPrimary
            
            self.widthContraint.constant = 29
            
            self.backgroundColorView.backgroundColor = UIColor.App.backgroundTertiary
            self.backgroundColorView.layer.borderWidth = 0
            self.backgroundColorView.layer.borderColor = nil
        }
    }
        
    func redrawScoreAlpha() {
        if self.style == .background || self.style == .border {
            self.homeScoreLabel.alpha = 1.0
            self.awayScoreLabel.alpha = 1.0
            return
        }
        
        if self.homeScore > self.awayScore {
            self.homeScoreLabel.alpha = 1.0
            self.awayScoreLabel.alpha = 0.5
        }
        else if self.homeScore < self.awayScore {
            self.homeScoreLabel.alpha = 0.5
            self.awayScoreLabel.alpha = 1.0
        }
        else {
            self.homeScoreLabel.alpha = 1.0
            self.awayScoreLabel.alpha = 1.0
        }
    }
    
}
