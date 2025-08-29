//
//  EveryMatrixOddsMatrixAPIConnector.swift
//  ServicesProvider
//
//  Created by André Lascas on 14/08/2025.
//

import Foundation
import Combine

class EveryMatrixOddsMatrixAPIConnector: EveryMatrixBaseConnector {
    
    private var cancellables: Set<AnyCancellable> = []

    init(sessionCoordinator: EveryMatrixSessionCoordinator,
         session: URLSession = .shared,
         decoder: JSONDecoder = JSONDecoder()) {
        super.init(sessionCoordinator: sessionCoordinator,
                   apiIdentifier: "OddsMatrix",
                   session: session,
                   decoder: decoder)
    }
    
    // MARK: - Legacy Session Management (for backward compatibility)
    func saveSessionToken(_ token: String) {
        print("[AUTH_LOG] 💾 EveryMatrixOddsMatrixAPIConnector: saveSessionToken() called (legacy)")
        // Token is now managed by authenticator, this is kept for backward compatibility
    }
    
    func clearSessionToken() {
        print("[AUTH_LOG] 🗑️ EveryMatrixOddsMatrixAPIConnector: clearSessionToken() called (legacy)")
        // Token is now managed by authenticator, this is kept for backward compatibility
    }
    
    func saveUserId(_ userId: String) {
        print("[AUTH_LOG] 👤 EveryMatrixOddsMatrixAPIConnector: saveUserId() called (legacy)")
        // User ID is now managed by authenticator, this is kept for backward compatibility
    }
    
    func clearUserId() {
        print("[AUTH_LOG] 🗑️ EveryMatrixOddsMatrixAPIConnector: clearUserId() called (legacy)")
        // User ID is now managed by authenticator, this is kept for backward compatibility
    }

    // Request method is inherited from EveryMatrixBaseConnector
    // which provides automatic token refresh on 401/403 errors
} 
