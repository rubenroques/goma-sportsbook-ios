//
//  MatchWidgetCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/10/2021.
//

import Foundation

struct MatchWidgetCellViewModel {

    var homeTeamName: String
    var awayTeamName: String
    var countryISOCode: String
    var startDateString: String
    var startTimeString: String
    var competitionName: String
    var isToday: Bool
    var countryId: String

    init(match: Match) {

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
        if let venueId = match.venueId,
           let location = Env.everyMatrixStorage.location(forId: venueId),
           let code = location.code {
            self.countryISOCode = code
            self.countryId = location.id
        }

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
