//
//  File.swift
//
//
//  Created by Ruben Roques on 15/01/2024.
//

import Foundation

extension GomaModelMapper {
    
    static func internalUserNotificationsSettings(fromUserNotificationsSettings settings: UserNotificationsSettings) -> GomaModels.UserNotificationsSettings {
        return GomaModels.UserNotificationsSettings(notifications: settings.notifications,
                                                    notificationsGamesWatchlist: settings.notificationsGamesWatchlist,
                                                    notificationsCompetitionsWatchlist: settings.notificationsCompetitionsWatchlist,
                                                    notificationsGoal: settings.notificationsGoal,
                                                    notificationsStartGame: settings.notificationsStartGame,
                                                    notificationsHalftime: settings.notificationsHalftime,
                                                    notificationsFulltime: settings.notificationsFulltime,
                                                    notificationsSecondHalf: settings.notificationsSecondHalf,
                                                    notificationsRedcard: settings.notificationsRedcard,
                                                    notificationsBets: settings.notificationsBets,
                                                    notificationsBetSelections: settings.notificationsBetSelections,
                                                    notificationsEmail: settings.notificationsEmail,
                                                    notificationsSms: settings.notificationsSms,
                                                    notificationsChats: settings.notificationsChats,
                                                    notificationsNews: settings.notificationsNews)
    }
    
    static func userNotificationsSettings(fromInternalUserNotificationsSettings settings: GomaModels.UserNotificationsSettings) -> UserNotificationsSettings {
        return UserNotificationsSettings(notifications: settings.notifications == 1,
                                         notificationsGamesWatchlist: settings.notificationsGamesWatchlist == 1,
                                         notificationsCompetitionsWatchlist: settings.notificationsCompetitionsWatchlist == 1,
                                         notificationsGoal: settings.notificationsGoal == 1,
                                         notificationsStartGame: settings.notificationsStartGame == 1,
                                         notificationsHalftime: settings.notificationsHalftime == 1,
                                         notificationsFulltime: settings.notificationsFulltime == 1,
                                         notificationsSecondHalf: settings.notificationsSecondHalf == 1,
                                         notificationsRedcard: settings.notificationsRedcard == 1,
                                         notificationsBets: settings.notificationsBets == 1,
                                         notificationsBetSelections: settings.notificationsBetSelections == 1,
                                         notificationsEmail: settings.notificationsEmail == 1,
                                         notificationsSms: settings.notificationsSms == 1,
                                         notificationsChats: settings.notificationsChats == 1,
                                         notificationsNews: settings.notificationsNews == 1)
    }
    
}
