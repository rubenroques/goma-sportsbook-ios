import Foundation
import Combine

class EveryMatrixCasinoConnector: EveryMatrixBaseConnector {
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(sessionCoordinator: EveryMatrixSessionCoordinator,
         session: URLSession = .shared,
         decoder: JSONDecoder = JSONDecoder()) {
        super.init(sessionCoordinator: sessionCoordinator,
                   apiIdentifier: "Casino",
                   session: session,
                   decoder: decoder)
        
        setupNetworkMonitoring()
    }
    
    // Request method is inherited from EveryMatrixBaseConnector
    // which provides automatic token refresh on 401/403 errors
    // Note: Casino API uses Cookie header for session token, which is handled in BaseConnector
    
    func updateSessionToken(sessionId: String, userId: String) {
        // Update the session coordinator's session
        let session = EveryMatrixSessionResponse(
            sessionId: sessionId,
            userId: userId
        )
        sessionCoordinator.updateSession(session)
    }
    
    private func setupNetworkMonitoring() {
        NotificationCenter.default.publisher(for: .NSURLCredentialStorageChanged)
            .sink { [weak self] _ in
                self?.checkConnectivity()
            }
            .store(in: &cancellables)
    }
    
    private func checkConnectivity() {
        connectionStateSubject.send(.connected)
    }
}
