//
//  Match.swift
//  Sportsbook
//
//  Created by Ruben Roques on 22/03/2023.
//

import Foundation

struct Match {

    var id: String
    var competitionId: String
    var competitionName: String
    var homeParticipant: Participant
    var awayParticipant: Participant
    var date: Date?

    var sport: Sport

    var venue: Location?
    var numberTotalOfMarkets: Int
    var markets: [Market]
    var rootPartId: String
    var sportName: String?

    var status: Status

    var homeParticipantScore: Int?
    var awayParticipantScore: Int?

    var matchTime: String?

    var detailedStatus: String {
        switch self.status {
        case .unknown:
            return ""
        case .notStarted:
            return "Not started"
        case .inProgress(let details):
            if let sportAlphaId = self.sport.alphaId {
                return self.convertStatus(sportAlphaId, details)
            }
            return "\(details)"
        case .ended:
            return "Ended"
        }

    }

    enum Status {
        case unknown
        case notStarted
        case inProgress(String)
        case ended
    }

    init(id: String,
         competitionId: String,
         competitionName: String,
         homeParticipant: Participant,
         awayParticipant: Participant,
         homeParticipantScore: Int? = nil,
         awayParticipantScore: Int? = nil,
         date: Date? = nil,
         sport: Sport,
         venue: Location? = nil,
         numberTotalOfMarkets: Int,
         markets: [Market],
         rootPartId: String,
         status: Status,
         matchTime: String? = nil) {

        self.id = id
        self.competitionId = competitionId
        self.competitionName = competitionName
        self.homeParticipant = homeParticipant
        self.awayParticipant = awayParticipant
        self.homeParticipantScore = homeParticipantScore
        self.awayParticipantScore = awayParticipantScore
        self.date = date

        self.sport = sport

        self.venue = venue
        self.numberTotalOfMarkets = numberTotalOfMarkets
        self.markets = markets
        self.rootPartId = rootPartId
        self.status = status
        self.matchTime = matchTime
    }


}

extension Match {


    private func convertStatus(_ sport: String, _ statusCode: String) -> String {
        switch (sport, statusCode) {
        case ("FBL", "not_started"):
            return "Not Started"
        case ("FBL", "1p"):
            return "1st Half"
        case ("FBL", "2p"):
            return "2nd Half"
        case ("FBL", "paused"):
            return "Halftime"
        case ("FBL", "ended"):
            return "Ended"

        case ("BKB", "not_started"):
            return "Not Started"
        case ("BKB", "1q"):
            return "1st Quarter"
        case ("BKB", "2q"):
            return "2nd Quarter"
        case ("BKB", "3q"):
            return "3nd Quarter"
        case ("BKB", "4q"):
            return "4nd Quarter"
        case ("BKB", "pause1"):
            return "1st Pause"
        case ("BKB", "pause2"):
            return "2nd Pause"
        case ("BKB", "pause3"):
            return "3th Pause"
        case ("BKB", "pause4"):
            return "4th Pause"
        case ("BKB", "pause5"):
            return "5th Pause"
        case ("BKB", "awaiting_ot"):
            return "Awaiting Overtime"
        case ("BKB", "ot"):
            return "Overtime"
        case ("BKB", "ended"):
            return "Ended"

        case ("TNS", "not_started"):
            return "Not Started"
        case ("TNS", "1set"):
            return "1st Set"
        case ("TNS", "2set"):
            return "2nd Set"
        case ("TNS", "3set"):
            return "3th Set"
        case ("TNS", "4set"):
            return "4th Set"
        case ("TNS", "5set"):
            return "5th Set"
        case ("TNS", "pause1"):
            return "1st Pause"
        case ("TNS", "pause2"):
            return "2nd Pause"
        case ("TNS", "pause3"):
            return "3th Pause"
        case ("TNS", "pause4"):
            return "4st Pause"
        case ("TNS", "pause5"):
            return "5th Pause"
        case ("TNS", "ended"):
            return "Ended"

        case ("VBL", "not_started"):
            return "Not Started"
        case ("VBL", "1set"):
            return "1st Set"
        case ("VBL", "2set"):
            return "2nd Set"
        case ("VBL", "3set"):
            return "3th Set"
        case ("VBL", "4set"):
            return "4th Set"
        case ("VBL", "5set"):
            return "5th Set"
        case ("VBL", "pause1"):
            return "1st Pause"
        case ("VBL", "pause2"):
            return "2nd Pause"
        case ("VBL", "pause3"):
            return "3th Pause"
        case ("VBL", "pause4"):
            return "4st Pause"
        case ("VBL", "pause5"):
            return "5th Pause"
        case ("VBL", "ended"):
            return "Ended"

        case ("BAD", "not_started"):
            return "Not Started"
        case ("BAD", "1set"):
            return "1st Set"
        case ("BAD", "2set"):
            return "2nd Set"
        case ("BAD", "3set"):
            return "3th Set"
        case ("BAD", "4set"):
            return "4th Set"
        case ("BAD", "5set"):
            return "5th Set"
        case ("BAD", "pause1"):
            return "1st Pause"
        case ("BAD", "pause2"):
            return "2nd Pause"
        case ("BAD", "pause3"):
            return "3th Pause"
        case ("BAD", "pause4"):
            return "4st Pause"
        case ("BAD", "pause5"):
            return "5th Pause"
        case ("BAD", "ended"):
            return "Ended"

        case ("HBL", "not_started"):
            return "Not Started"
        case ("HBL", "1p"):
            return "1st Period"
        case ("HBL", "2p"):
            return "2nd Period"
        case ("HBL", "3p"):
            return "3nd Period"
        case ("HBL", "pause1"):
            return "1st Pause"
        case ("HBL", "pause2"):
            return "2nd Pause"
        case ("HBL", "pause3"):
            return "3th Pause"
        case ("HBL", "pause4"):
            return "4st Pause"
        case ("HBL", "ended"):
            return "Ended"

        case ("HKY", "not_started"):
            return "Not Started"
        case ("HKY", "1p"):
            return "1st Period"
        case ("HKY", "2p"):
            return "2nd Period"
        case ("HKY", "3p"):
            return "3nd Period"
        case ("HKY", "pause1"):
            return "1st Pause"
        case ("HKY", "pause2"):
            return "2nd Pause"
        case ("HKY", "pause3"):
            return "3th Pause"
        case ("HKY", "pause4"):
            return "4st Pause"
        case ("HKY", "ended"):
            return "Ended"

        case ("CRK", "not_started"):
            return "Not Started"
        case ("CRK", "1i_at"):
            return "Started"
        case ("CRK", "1i_ht"):
            return "Started"
        case ("CRK", "1set"):
            return "1st Set"
        case ("CRK", "2set"):
            return "2nd Set"
        case ("CRK", "3set"):
            return "3th Set"
        case ("CRK", "4set"):
            return "4th Set"
        case ("CRK", "5set"):
            return "3th Set"
        case ("CRK", "1p"):
            return "1st Period"
        case ("CRK", "2p"):
            return "2nd Period"
        case ("CRK", "3p"):
            return "3nd Period"
        case ("CRK", "pause1"):
            return "1st Pause"
        case ("CRK", "pause2"):
            return "2nd Pause"
        case ("CRK", "pause3"):
            return "3th Pause"
        case ("CRK", "ended"):
            return "Ended"
        case ("CRK", "unknown"):
            return ""

        case ("RBL", "not_started"):
            return "Not Started"
        case ("RBL", "1p"):
            return "1st Period"
        case ("RBL", "2p"):
            return "2nd Period"
        case ("RBL", "paused"):
            return "Pause"
        case ("RBL", "ended"):
            return "Ended"

        case ("RBU", "not_started"):
            return "Not Started"
        case ("RBU", "1p"):
            return "1st Period"
        case ("RBU", "2p"):
            return "2nd Period"
        case ("RBU", "paused"):
            return "Pause"
        case ("RBU", "ended"):
            return "Ended"

        case ("DAR", "not_started"):
            return "Not Started"
        case ("DAR", "in_progress"):
            return "In progress"

        default:
            return statusCode
        }
    }
}
