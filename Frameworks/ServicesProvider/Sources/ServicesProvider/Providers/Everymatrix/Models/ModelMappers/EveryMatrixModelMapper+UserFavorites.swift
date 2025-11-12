//
//  EveryMatrixModelMapper+UserFavorites.swift
//  ServicesProvider
//
//  Created by André Lascas on 12/11/2025.
//

import Foundation
import SharedModels

extension EveryMatrixModelMapper {
    
    static func userFavoritesResponse(fromUserFavoritesResponse internalUserFavoritesResponse: EveryMatrix.UserFavoritesResponse) -> UserFavoritesResponse {
        
        return UserFavoritesResponse(favoriteEvents: internalUserFavoritesResponse.favoriteEvents)
    }
}
