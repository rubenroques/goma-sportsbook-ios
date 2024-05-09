//
//  MatchWidgetCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/10/2021.
//

import Foundation
import Combine
import UIKit

enum MatchWidgetType: String, CaseIterable {
    case normal
    case topImage
    case topImageOutright
    case boosted
    case backgroundImage
}

enum MatchWidgetStatus: String, CaseIterable {
    case unknown
    case live
    case preLive
}

class MatchWidgetCellViewModel {
    
    var homeTeamName: String
    var awayTeamName: String
    var countryISOCode: String
    var startDateString: String
    var startTimeString: String
    var competitionName: String
    var isToday: Bool
    var countryId: String
    
    var match: Match {
        return self.matchSubject.value
    }
    
    var matchPublisher: AnyPublisher<Match, Never> {
        return self.matchSubject.eraseToAnyPublisher()
    }
    
    private var matchSubject: CurrentValueSubject<Match, Never>
    
    var promoImageURL: URL? {
        return URL(string: self.match.promoImageURL ?? "")
    }
    
    var isLiveCard: Bool {
        
        if self.matchWidgetStatus == .live {
            return true
        }
        
        switch match.status {
        case .notStarted, .unknown:
            return false
        case .inProgress, .ended:
            return true
        }
    }
    
    var isLiveMatch: Bool {
        switch match.status {
        case .notStarted, .ended, .unknown:
            return false
        case .inProgress:
            return true
        }
    }
    
    var inProgressStatusString: String? {
        
        switch match.status {
        case .ended, .notStarted, .unknown:
            return nil
        case .inProgress(let progress):
            return progress
        }
        
    }
    
    var canHaveCashback: Bool {
        return (self.matchWidgetType == .normal || self.matchWidgetType == .topImage) && RePlayFeatureHelper.shouldShowRePlay(forMatch: self.match)
    }
    
    var matchScore: String {
        var homeScore = "0"
        var awayScore = "0"
        if let homeScoreInt = match.homeParticipantScore {
            homeScore = "\(homeScoreInt)"
        }
        if let awayScoreInt = match.awayParticipantScore {
            awayScore = "\(awayScoreInt)"
        }
        return "\(homeScore) - \(awayScore)"
    }
    
    var matchTimeDetails: String? {
        let details = [self.match.matchTime, self.match.detailedStatus]
        return details.compactMap({ $0 }).joined(separator: " - ")
    }
    
    @Published private(set) var homeOldBoostedOddAttributedString: NSAttributedString = NSAttributedString(string: "-")
    @Published private(set) var drawOldBoostedOddAttributedString: NSAttributedString = NSAttributedString(string: "-")
    @Published private(set) var awayOldBoostedOddAttributedString: NSAttributedString = NSAttributedString(string: "-")
    
    var matchWidgetStatus: MatchWidgetStatus = .unknown
    var matchWidgetType: MatchWidgetType = .normal
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(match: Match, matchWidgetType: MatchWidgetType = .normal, matchWidgetStatus: MatchWidgetStatus = .unknown) {
        
        self.matchWidgetStatus = matchWidgetStatus
        
        self.matchWidgetType = matchWidgetType
        
        self.matchSubject = .init(match)
        
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
        
        self.loadBoostedOddOldValue()
    }
    
}

// Load Boosted Odds old value
extension MatchWidgetCellViewModel {
    
    func loadBoostedOddOldValue() {
        
        guard
            self.matchWidgetType == .boosted,
                let originalMarketId = self.match.oldMainMarketId
        else {
            return
        }
        
        Env.servicesProvider.getMarketInfo(marketId: originalMarketId)
            .map(ServiceProviderModelMapper.market(fromServiceProviderMarket:))
            .sink { _ in
                print("Env.servicesProvider.getMarketInfo(marketId: old boosted market completed")
            } receiveValue: { [weak self] market in
                
                if let firstCurrentOutcomeName = self?.match.markets.first?.outcomes[safe:0]?.typeName.lowercased(),
                   let outcome = market.outcomes.first(where: { outcome in outcome.typeName.lowercased() == firstCurrentOutcomeName }) {
                    let oddValue = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
                    let attributes = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                    let attributedString = NSAttributedString(string: oddValue, attributes: attributes)
                    self?.homeOldBoostedOddAttributedString = attributedString
                }
                else {
                    self?.homeOldBoostedOddAttributedString = NSAttributedString(string: "-")
                }
                
                if let secondCurrentOutcomeName = self?.match.markets.first?.outcomes[safe: 1]?.typeName.lowercased(),
                   let outcome = market.outcomes.first(where: { outcome in outcome.typeName.lowercased() == secondCurrentOutcomeName }) {
                    let oddValue = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
                    let attributes = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                    let attributedString = NSAttributedString(string: oddValue, attributes: attributes)
                    self?.drawOldBoostedOddAttributedString = attributedString
                }
                else {
                    self?.drawOldBoostedOddAttributedString = NSAttributedString(string: "-")
                }
                
                if let thirdCurrentOutcomeName = self?.match.markets.first?.outcomes[safe: 2]?.typeName.lowercased(),
                   let outcome = market.outcomes.first(where: { outcome in outcome.typeName.lowercased() == thirdCurrentOutcomeName }) {
                    let oddValue = OddFormatter.formatOdd(withValue: outcome.bettingOffer.decimalOdd)
                    let attributes = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                    let attributedString = NSAttributedString(string: oddValue, attributes: attributes)
                    self?.awayOldBoostedOddAttributedString = attributedString
                }
                else {
                    self?.awayOldBoostedOddAttributedString = NSAttributedString(string: "-")
                }
            }
            .store(in: &self.cancellables)
    }
}


extension MatchWidgetCellViewModel {
    
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
