//
//  MarketWidgetCellViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 21/10/2024.
//

import Foundation
import Combine
import UIKit

class MarketWidgetCellViewModel {

//    private var highlightedMarket: HighlightedContent<Market>
    var match: Match?
    
    @Published private(set) var highlightedMarket: HighlightedContent<Market>

    var availableOutcomes: [Outcome] {
        let highlightedMarket = self.highlightedMarket.content
        let validOutcomesCount = self.highlightedMarket.promotedDetailsCount
        let processedOutcomes = highlightedMarket.outcomes.filter { outcome in
            if !outcome.bettingOffer.isAvailable || outcome.bettingOffer.decimalOdd.isNaN {
                return false
            }
            return true
        }
        .sorted(by: \.bettingOffer.decimalOdd)
        .prefix(validOutcomesCount)

        return Array(processedOutcomes)
    }

    var eventImagePublisher: AnyPublisher<String, Never> {
        return self.$highlightedMarket
            .map { highlightedMarket in
                return highlightedMarket.promotionalImageURL ?? ""
            }
            .eraseToAnyPublisher()
    }
    
    var sportIconImagePublisher: AnyPublisher<UIImage, Never> {
        return self.$highlightedMarket
            .map { highlightedMarket in
                
                let sportId = highlightedMarket.content.sport?.id

                if let sportIconImage = UIImage(named: "sport_type_icon_\(sportId ?? "")") {
                    return sportIconImage
                }
                else if let defaultImage = UIImage(named: "sport_type_icon_default") {
                    return defaultImage
                }
                else {
                    return UIImage()
                }
            }
            .eraseToAnyPublisher()
    }
    
    var countryIdPublisher: AnyPublisher<String, Never> {
        return self.$highlightedMarket
            .map { $0.content.venueCountry?.name ?? ""}
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var countryISOCodePublisher: AnyPublisher<String, Never> {
        return self.$highlightedMarket
            .map { $0.content.venueCountry?.iso2Code ?? ""}
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var countryFlagImagePublisher: AnyPublisher<UIImage, Never> {
        return Publishers.CombineLatest(self.countryISOCodePublisher, self.countryIdPublisher)
            .map({ countryISOCode, countryId in
                let assetName = Assets.flagName(withCountryCode: countryISOCode != "" ? countryISOCode : countryId)
                return UIImage(named: assetName) ?? UIImage()
            })
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var eventName: AnyPublisher<String, Never> {
        return self.$highlightedMarket
            .map { highlightedMarket in
                return "\(highlightedMarket.content.homeParticipant ?? "") - \(highlightedMarket.content.awayParticipant ?? "")"
            }
            .eraseToAnyPublisher()
    }
    
    var marketName: AnyPublisher<String, Never> {
        return self.$highlightedMarket
            .map { highlightedMarket in
                return highlightedMarket.content.name
            }
            .eraseToAnyPublisher()
    }
    
    var competitionName: AnyPublisher<String, Never> {
        return self.$highlightedMarket
            .map { highlightedMarket in
                return highlightedMarket.content.competitionName ?? ""
            }
            .eraseToAnyPublisher()
    }
    
    var startDateStringPublisher: AnyPublisher<String, Never> {
        return self.$highlightedMarket
            .map { highlightedMarket in
                if let date = highlightedMarket.content.startDate {
                    return MatchWidgetCellViewModel.startDateString(fromDate: date)
                }
                else {
                    return ""
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var startTimeStringPublisher: AnyPublisher<String, Never> {
        return self.$highlightedMarket
            .map { highlightedMarket in
                if let date = highlightedMarket.content.startDate {
                    return MatchWidgetCellViewModel.hourDateFormatter.string(from: date)
                }
                else {
                    return ""
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var isFavoriteMatchPublisher: AnyPublisher<Bool, Never> {
        return self.$highlightedMarket
            .map { highlightedMarket in
                return Env.favoritesManager.isEventFavorite(eventId: highlightedMarket.content.eventId ?? "")
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    init(highlightedMarket: HighlightedContent<Market>) {
        self.highlightedMarket = highlightedMarket
    }
}
