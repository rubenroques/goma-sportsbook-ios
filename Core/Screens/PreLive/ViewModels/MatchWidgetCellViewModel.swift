//
//  MatchWidgetCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/10/2021.
//

import Foundation

class MatchWidgetCellViewModel {

    var homeTeamName: String
    var awayTeamName: String
    var countryISOCode: String
    var startDateString: String
    var startTimeString: String
    var competitionName: String
    var isToday: Bool
    var countryId: String

    var match: Match?

    var isLiveCard: Bool {
        if let match = self.match {
            switch match.status {
            case .notStarted, .unknown:
                return false
            case .inProgress(_), .ended:
                return true
            }
        }
        return false
    }

    var isLiveMatch: Bool {
        if let match = self.match {
            switch match.status {
            case .notStarted, .ended, .unknown:
                return false
            case .inProgress(_):
                return true
            }
        }
        return false
    }

    var inProgressStatusString: String? {
        if let match = self.match {
            switch match.status {
            case .ended, .notStarted, .unknown:
                return nil
            case .inProgress(let progress):
                return progress
            }
        }
        return nil
    }

    var matchScore: String {
        var homeScore = "0"
        var awayScore = "0"
        if let match = self.match, let homeScoreInt = match.homeParticipantScore {
            homeScore = "\(homeScoreInt)"
        }
        if let match = self.match, let awayScoreInt = match.awayParticipantScore {
            awayScore = "\(awayScoreInt)"
        }
        return "\(homeScore) - \(awayScore)"
    }

    var matchTimeDetails: String? {
        let details = [self.match?.matchTime, self.match?.detailedStatus]
        return details.compactMap({ $0 }).joined(separator: " - ")
    }

    init(match: Match) {

        self.match = match

        self.homeTeamName = match.homeParticipant.name
        self.awayTeamName = match.awayParticipant.name

        self.countryISOCode = match.venue?.isoCode ?? ""
        self.countryId = match.venue?.id ?? ""

        self.isToday = false
        self.startDateString = ""
        self.startTimeString = ""

        if let startDate = match.date {

            let relativeFormatter = MatchWidgetCellViewModel.relativeDateFormatter
            let relativeDateString = relativeFormatter.string(from: startDate)
            // "Jan 18, 2018"

            let nonRelativeFormatter = MatchWidgetCellViewModel.normalDateFormatter
            let normalDateString = nonRelativeFormatter.string(from: startDate)
            // "Jan 18, 2018"

            if relativeDateString == normalDateString {
                let customFormatter = Date.buildFormatter(locale: Env.locale, dateFormat: "dd MMM")
                self.startDateString = customFormatter.string(from: startDate)
            }
            else {
                self.startDateString = relativeDateString // Today, Yesterday
            }

            self.isToday = Env.calendar.isDateInToday(startDate)
            self.startTimeString = MatchWidgetCellViewModel.hourDateFormatter.string(from: startDate)
        }

        self.competitionName = match.competitionName
    }

    init(match: EveryMatrix.Match) {

        self.homeTeamName = match.homeParticipantName ?? ""
        self.awayTeamName = match.awayParticipantName ?? ""

        self.countryISOCode = ""
        self.countryId = ""

        self.isToday = false
        self.startDateString = ""
        self.startTimeString = ""

        if let startDate = match.startDate {

            let relativeFormatter = MatchWidgetCellViewModel.relativeDateFormatter
            let relativeDateString = relativeFormatter.string(from: startDate)
            // "Jan 18, 2018"

            let nonRelativeFormatter = MatchWidgetCellViewModel.normalDateFormatter
            let normalDateString = nonRelativeFormatter.string(from: startDate)
            // "Jan 18, 2018"

            if relativeDateString == normalDateString {
                let customFormatter = Date.buildFormatter(locale: Env.locale, dateFormat: "dd MMM")
                self.startDateString = customFormatter.string(from: startDate)
            }
            else {
                self.startDateString = relativeDateString // Today, Yesterday
            }

            self.isToday = Env.calendar.isDateInToday(startDate)
            self.startTimeString = MatchWidgetCellViewModel.hourDateFormatter.string(from: startDate)
        }

        self.competitionName = match.parentName ?? ""
    }

    static var hourDateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter
    }()

    static var dayDateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()

    static var normalDateFormatter: DateFormatter = {
        var dateFormatter = Date.buildFormatter(locale: Env.locale)
        return dateFormatter
    }()

    static var relativeDateFormatter: DateFormatter = {
        var dateFormatter = Date.buildFormatter(locale: Env.locale, hasRelativeDate: true)
        return dateFormatter
    }()

}
