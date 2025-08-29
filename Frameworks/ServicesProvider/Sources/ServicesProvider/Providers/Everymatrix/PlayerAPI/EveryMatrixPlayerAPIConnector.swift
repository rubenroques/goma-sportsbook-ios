//
//  EveryMatrixAPIConnector.swift
//  ServicesProvider
//
//  Created by André Lascas on 09/07/2025.
//

import Foundation
import Combine

class EveryMatrixPlayerAPIConnector: EveryMatrixBaseConnector {
    
    private var cancellables: Set<AnyCancellable> = []

    init(sessionCoordinator: EveryMatrixSessionCoordinator,
         session: URLSession = .shared,
         decoder: JSONDecoder = JSONDecoder()) {
        super.init(sessionCoordinator: sessionCoordinator,
                   apiIdentifier: "PlayerAPI",
                   session: session,
                   decoder: decoder)
    }

    // Request method is inherited from EveryMatrixBaseConnector
    // which provides automatic token refresh on 401/403 errors
    
    func updateSessionToken(sessionId: String, id: String) {
        // Update the session coordinator's session
        let session = EveryMatrixSessionResponse(
            sessionId: sessionId,
            userId: id
        )
        sessionCoordinator.updateSession(session)
    }
}

public struct EveryMatrixSessionToken {
    public let sessionId: String
    public let id: String
    
    public init(sessionId: String, id: String) {
        self.sessionId = sessionId
        self.id = id
    }
}
