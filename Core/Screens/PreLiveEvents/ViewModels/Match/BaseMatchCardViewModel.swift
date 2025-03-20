//
//  BaseMatchCardViewModel.swift
//  Sportsbook
//
//  Created for refactoring in 2024.
//

import Foundation
import UIKit
import Combine
import ServicesProvider

/// Base view model class containing common publishers for all match card types
class BaseMatchCardViewModel {
    // MARK: - Published Properties
    
    /// The current match data
    @Published private(set) var match: Match
    
    /// Match widget type (normal, boosted, etc.)
    @Published private(set) var matchWidgetType: MatchWidgetType
    
    /// Match status (live, preLive)
    @Published private(set) var matchWidgetStatus: MatchWidgetStatus
    
    // MARK: - Common Publishers (shared by all card types)
    
    /// Publisher for event name
    var eventNamePublisher: AnyPublisher<String?, Never> {
        return self.$match
            .map { match in
                return match.venue?.name ?? match.competitionName
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// Publisher for sport icon image
    var sportIconImagePublisher: AnyPublisher<UIImage, Never> {
        return self.$match
            .map { match in
                if let sportIconImage = UIImage(named: "sport_type_icon_\(match.sport.id)") {
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
    
    /// Publisher for country flag image
    var countryFlagImagePublisher: AnyPublisher<UIImage, Never> {
        return self.$match
            .map { match in
                let isoCode = match.venue?.isoCode ?? ""
                let countryId = match.venue?.id ?? ""
                let assetName = isoCode.isEmpty ? countryId : isoCode
                return UIImage(named: "flag_\(assetName.lowercased())") ?? UIImage()
            }
            .eraseToAnyPublisher()
    }
    
    /// Publisher for start date string
    var startDateStringPublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { match in
                guard let date = match.date else { return "" }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "E d MMM"
                return formatter.string(from: date)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// Publisher for start time string
    var startTimeStringPublisher: AnyPublisher<String, Never> {
        return self.$match
            .map { match in
                guard let date = match.date else { return "" }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                return formatter.string(from: date)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// Publisher for whether the match is a favorite
    var isFavoriteMatchPublisher: AnyPublisher<Bool, Never> {
        return self.$match
            .map { match in
                return Env.favoritesManager.isEventFavorite(eventId: match.id)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// Publisher for whether the card should be drawn as live
    var isLiveCardPublisher: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest(self.$matchWidgetStatus, self.$match)
            .map { matchWidgetStatus, match in
                if matchWidgetStatus == .live {
                    return true
                }
                
                switch match.status {
                case .notStarted, .unknown:
                    return false
                case .inProgress, .ended:
                    return true
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// Publisher for widget appearance settings
    var widgetAppearancePublisher: AnyPublisher<WidgetAppearance, Never> {
        return Publishers.CombineLatest3(
            self.$matchWidgetStatus,
            self.$matchWidgetType,
            self.isLiveCardPublisher
        )
        .map { status, type, isLiveCard -> WidgetAppearance in
            let isLive = status == .live
            
            // Determine gradient visibility based on widget type and status
            let shouldHideNormalGradient: Bool
            let shouldHideLiveGradient: Bool
            
            switch type {
            case .normal, .boosted, .topImage, .topImageWithMixMatch:
                shouldHideNormalGradient = isLive
                shouldHideLiveGradient = !isLive
            case .backgroundImage, .topImageOutright:
                shouldHideNormalGradient = true
                shouldHideLiveGradient = true
            }
            
            return WidgetAppearance(
                widgetType: type,
                isLive: isLive,
                isLiveCard: isLiveCard,
                shouldHideNormalGradient: shouldHideNormalGradient,
                shouldHideLiveGradient: shouldHideLiveGradient
            )
        }
        .removeDuplicates { lhs, rhs in
            return lhs.widgetType == rhs.widgetType &&
                   lhs.isLive == rhs.isLive &&
                   lhs.isLiveCard == rhs.isLiveCard &&
                   lhs.shouldHideNormalGradient == rhs.shouldHideNormalGradient &&
                   lhs.shouldHideLiveGradient == rhs.shouldHideLiveGradient
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    /// Initializes a new base view model with the provided match and widget type/status
    init(match: Match, matchWidgetType: MatchWidgetType = .normal, matchWidgetStatus: MatchWidgetStatus = .unknown) {
        self.match = match
        self.matchWidgetType = matchWidgetType
        
        // Determine status if not explicitly provided
        if matchWidgetStatus != .unknown {
            self.matchWidgetStatus = matchWidgetStatus
        }
        else if match.status.isLive || match.status.isPostLive {
            self.matchWidgetStatus = .live
        }
        else {
            self.matchWidgetStatus = .preLive
        }
    }
    
    // MARK: - Public Methods
    
    /// Updates the match data
    func updateWithMatch(_ match: Match) {
        self.match = match
    }
} 