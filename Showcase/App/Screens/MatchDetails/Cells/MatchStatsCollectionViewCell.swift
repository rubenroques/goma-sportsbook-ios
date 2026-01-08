//
//  MatchStatsCollectionViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/04/2022.
//

import UIKit

class MatchStatsCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var cardView: UIView!

    @IBOutlet private weak var captionSeparatorView: UIView!

    @IBOutlet private weak var marketLabel: UILabel!
    @IBOutlet private weak var statsBaseView: UIView!

    @IBOutlet private weak var captionBaseView: UIView!
    @IBOutlet private weak var iconStatsImageView: UIImageView!
    @IBOutlet private weak var homeCircleCaptionView: UIView!
    @IBOutlet private weak var homeNameCaptionLabel: UILabel!
    @IBOutlet private weak var awayCircleCaptionView: UIView!
    @IBOutlet private weak var awayNameCaptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.homeNameCaptionLabel.font = AppFont.with(type: .medium, size: 9)
        self.awayNameCaptionLabel.font = AppFont.with(type: .medium, size: 9)
        self.marketLabel.font = AppFont.with(type: .heavy, size: 12)
        
        self.homeNameCaptionLabel.text = ""
        self.awayNameCaptionLabel.text = ""

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.cardView.layer.cornerRadius = 9

        self.homeCircleCaptionView.layer.cornerRadius = self.homeCircleCaptionView.frame.size.width / 2
        self.awayCircleCaptionView.layer.cornerRadius = self.awayCircleCaptionView.frame.size.width / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.homeNameCaptionLabel.text = ""
        self.awayNameCaptionLabel.text = ""

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.baseView.backgroundColor = .clear
        self.cardView.backgroundColor = UIColor.App.backgroundCards

        self.statsBaseView.backgroundColor = .clear
        self.marketLabel.textColor = UIColor.App.textPrimary

        self.captionSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.captionBaseView.backgroundColor = UIColor.App.backgroundCards

        self.homeNameCaptionLabel.textColor = UIColor.App.textPrimary
        self.awayNameCaptionLabel.textColor = UIColor.App.textPrimary

        self.homeCircleCaptionView.backgroundColor = UIColor.App.statsHome
        self.awayCircleCaptionView.backgroundColor = UIColor.App.statsAway

    }

    func setupWithTeams(homeTeamName: String, awayTeamName: String) {
        self.homeNameCaptionLabel.text = homeTeamName
        self.awayNameCaptionLabel.text = awayTeamName
    }

    func setupWithMarketTitle(title: String) {
        var replacedTitle = title.replacingOccurrences(of: "Over/Under", with: "Over/Under 2.5")
        self.marketLabel.text = replacedTitle
    }

    func setupStatsLine(withjson json: JSON) {

        guard
            let bettingTypeStats = json["stats"]["data"].dictionary
        else {
            return
        }

        var infoLabelText = "Last Results"
        if let title = json["stats"]["name"].string {
            infoLabelText = title
        }

        if let homeWinsValue = bettingTypeStats["home_participant"]?["Wins"].int,
           let homeDrawValue = bettingTypeStats["home_participant"]?["Draws"].int,
           let homeLossesValue = bettingTypeStats["home_participant"]?["Losses"].int,
           let awayWinsValue = bettingTypeStats["away_participant"]?["Wins"].int,
           let awayDrawValue = bettingTypeStats["away_participant"]?["Draws"].int,
           let awayLossesValue = bettingTypeStats["away_participant"]?["Losses"].int {

            var homeWin: Int = 0
            var homeDraw: Int = 0
            var homeLoss: Int = 0
            var homeTotal: Int = bettingTypeStats["home_participant"]?["Total"].int ?? 10

            var awayWin: Int = 0
            var awayDraw: Int = 0
            var awayLoss: Int = 0
            var awayTotal: Int = bettingTypeStats["away_participant"]?["Total"].int ?? 10

            homeWin = homeWinsValue
            homeDraw = homeDrawValue
            homeLoss = homeLossesValue
            homeTotal = homeWin + homeDraw + homeLoss

            awayWin = awayWinsValue
            awayDraw = awayDrawValue
            awayLoss = awayLossesValue
            awayTotal = awayWin + awayDraw + awayLoss

            self.statsBaseView.subviews.forEach { subview in
                subview.removeFromSuperview()
            }

            let headToHeadCardStatsView = HeadToHeadCardStatsView()
            self.statsBaseView.addSubview(headToHeadCardStatsView)

            NSLayoutConstraint.activate([
                self.statsBaseView.centerXAnchor.constraint(equalTo: headToHeadCardStatsView.centerXAnchor),
                self.statsBaseView.centerYAnchor.constraint(equalTo: headToHeadCardStatsView.centerYAnchor),
            ])

            headToHeadCardStatsView.setupHomeValues(win: homeWin, draw: homeDraw, loss: homeLoss, total: homeTotal)
            headToHeadCardStatsView.setupAwayValues(win: awayWin, draw: awayDraw, loss: awayLoss, total: awayTotal)
            headToHeadCardStatsView.setupCaptionText(infoLabelText)
            self.statsBaseView.isHidden = false
        }
        else {
            var homeWin: Int?
            var homeWinTotal: Int = 10
            var awayWin: Int?
            var awayWinTotal: Int = 10

            if let homeWinValue = bettingTypeStats["home_participant"]?.int,
               let awayWinValue = bettingTypeStats["away_participant"]?.int {
                homeWin = homeWinValue
                awayWin = awayWinValue

                homeWinTotal = bettingTypeStats["home_total"]?.int ?? 10
                awayWinTotal = bettingTypeStats["away_total"]?.int ?? 10
            }
            if let homeWinValue = bettingTypeStats["home_participant"]?["Even"].int,
               let homeWinTotalValue = bettingTypeStats["home_participant"]?["Total"].int,
               let awayWinValue = bettingTypeStats["away_participant"]?["Even"].int,
               let awayWinTotalValue = bettingTypeStats["away_participant"]?["Total"].int {

                homeWin = homeWinValue
                homeWinTotal = homeWinTotalValue
                awayWin = awayWinValue
                awayWinTotal = awayWinTotalValue
            }
            else if
                let homeUnder = bettingTypeStats["home_participant"]?["Under"].dictionary,
                let homeOver = bettingTypeStats["home_participant"]?["Over"].dictionary,
                let awayUnder = bettingTypeStats["away_participant"]?["Under"].dictionary,
                let awayOver = bettingTypeStats["away_participant"]?["Over"].dictionary {

                let marketParamFloatCast = Int(2)

                switch marketParamFloatCast {
                case 0:
                    homeWin = homeOver["+0.5"]?.int ?? 0
                    homeWinTotal = (homeOver["+0.5"]?.int ?? 0) + (homeUnder["-0.5"]?.int ?? 0)
                    awayWin = awayOver["+0.5"]?.int ?? 0
                    awayWinTotal = (awayOver["+0.5"]?.int ?? 0) + (awayUnder["-0.5"]?.int ?? 0)
                case 1:
                    homeWin = homeOver["+1.5"]?.int ?? 0
                    homeWinTotal = (homeOver["+1.5"]?.int ?? 0) + (homeUnder["-1.5"]?.int ?? 0)
                    awayWin = awayOver["+1.5"]?.int ?? 0
                    awayWinTotal = (awayOver["+1.5"]?.int ?? 0) + (awayUnder["-1.5"]?.int ?? 0)
                case 2:
                    homeWin = homeOver["+2.5"]?.int ?? 0
                    homeWinTotal = (homeOver["+2.5"]?.int ?? 0) + (homeUnder["-2.5"]?.int ?? 0)
                    awayWin = awayOver["+2.5"]?.int ?? 0
                    awayWinTotal = (awayOver["+2.5"]?.int ?? 0) + (awayUnder["-2.5"]?.int ?? 0)
                case 3:
                    homeWin = homeOver["+3.5"]?.int ?? 0
                    homeWinTotal = (homeOver["+3.5"]?.int ?? 0) + (homeUnder["-3.5"]?.int ?? 0)
                    awayWin = awayOver["+3.5"]?.int ?? 0
                    awayWinTotal = (awayOver["+3.5"]?.int ?? 0) + (awayUnder["-3.5"]?.int ?? 0)
                default: ()
                }
            }

            if let homeWinValue = homeWin, let awayWinValue = awayWin {

                self.statsBaseView.subviews.forEach { subview in
                    subview.removeFromSuperview()
                }

                let homeAwayCardStatsView = HomeAwayCardStatsView()

                homeAwayCardStatsView.setupHomeValues(win: homeWinValue, total: homeWinTotal)
                homeAwayCardStatsView.setupAwayValues(win: awayWinValue, total: awayWinTotal)
                homeAwayCardStatsView.setupCaptionText(infoLabelText)
                
                self.statsBaseView.addSubview(homeAwayCardStatsView)
                NSLayoutConstraint.activate([
                    self.statsBaseView.centerXAnchor.constraint(equalTo: homeAwayCardStatsView.centerXAnchor),
                    self.statsBaseView.centerYAnchor.constraint(equalTo: homeAwayCardStatsView.centerYAnchor),
                ])

                self.statsBaseView.isHidden = false
            }

        }

    }

}
