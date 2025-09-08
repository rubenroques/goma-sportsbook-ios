//
//  EveryMatrixSessionCoordinator.swift
//  ServicesProvider
//
//  Created by André Lascas on 09/07/2025.
//  Enhanced with token refresh mechanism
//

import Foundation
import Combine

public protocol EveryMatrixSessionTokenUpdater: AnyObject {
    func forceTokenRefresh(forKey key: EveryMatrixSessionCoordinatorKey) -> AnyPublisher<String?, Never>
}

public enum EveryMatrixSessionCoordinatorKey: String {
    case playerSessionToken
    case oddsMatrixSessionToken
}

/// Credentials for EveryMatrix authentication
struct EveryMatrixCredentials {
    let username: String
    let password: String
}

/// Session response from EveryMatrix login
struct EveryMatrixSessionResponse {
    let sessionId: String
    let userId: String
    
    init(sessionId: String, userId: String) {
        self.sessionId = sessionId
        self.userId = userId
    }
}

public class EveryMatrixSessionCoordinator {

    // MARK: - Existing Properties (for backward compatibility)
    private var accessTokensPublishers: [String: CurrentValueSubject<String?, Never>]
    private var accessTokensUpdaters: [String: EveryMatrixSessionTokenUpdater]
    
    // User ID storage
    private var userIdPublisher: CurrentValueSubject<String?, Never> = .init(nil)
    
    // MARK: - New Properties (from Authenticator)
    
    /// Current session information
    private var currentSession: EveryMatrixSessionResponse?
    
    /// Stored credentials for re-authentication
    private var credentials: EveryMatrixCredentials?
    
    /// Serial queue for thread-safe token management
    private let queue = DispatchQueue(label: "EveryMatrixSessionCoordinator.\(UUID().uuidString)")
    
    /// Shared refresh publisher to prevent concurrent refresh attempts
    private var refreshPublisher: AnyPublisher<EveryMatrixSessionResponse, Error>?
    
    /// URLSession for making authentication requests
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.accessTokensPublishers = [:]
        self.accessTokensUpdaters = [:]
        self.session = session
    }
    
    // MARK: - User ID Management
    
    public func saveUserId(_ userId: String) {
        self.userIdPublisher.send(userId)
    }
    
    public func clearUserId() {
        self.userIdPublisher.send(nil)
    }
    
    public func userId() -> AnyPublisher<String?, Never> {
        return userIdPublisher.eraseToAnyPublisher()
    }
    
    public var currentUserId: String? {
        return userIdPublisher.value
    }

    public func clearSession() {
        queue.sync {
            // Clear all publishers
            for publisher in self.accessTokensPublishers.values {
                publisher.send(nil)
            }
            // Clear user ID
            self.userIdPublisher.send(nil)
            // Clear session data
            self.currentSession = nil
            self.credentials = nil
            self.refreshPublisher = nil
        }
    }

    public func saveToken(_ token: String, withKey key: EveryMatrixSessionCoordinatorKey) {
        self.accessTokensPublishers[key.rawValue]?.send(token)
    }

    public func clearToken(withKey key: EveryMatrixSessionCoordinatorKey) {
        self.accessTokensPublishers[key.rawValue]?.send(nil)
    }

    public func token(forKey key: EveryMatrixSessionCoordinatorKey) -> AnyPublisher<String?, Never> {
        if let publisher = self.accessTokensPublishers[key.rawValue] {
            return publisher.eraseToAnyPublisher()
        }
        else {
            self.accessTokensPublishers[key.rawValue] = .init(nil)
            return self.accessTokensPublishers[key.rawValue]!.eraseToAnyPublisher()
        }
    }

    public func registerUpdater(_ updater: EveryMatrixSessionTokenUpdater, forKey key: EveryMatrixSessionCoordinatorKey) {
        self.accessTokensUpdaters[key.rawValue] = updater
    }

    public func forceTokenRefresh(forKey key: EveryMatrixSessionCoordinatorKey) -> AnyPublisher<String?, Never>? {
        self.accessTokensPublishers[key.rawValue]?.send(nil)

        // Use internal refresh logic
        return publisherWithValidToken(forceRefresh: true)
            .map { session in session.sessionId }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    // MARK: - New Methods (from Authenticator)
    
    /// Get current session token
    func getSessionToken() -> String? {
        return queue.sync { currentSession?.sessionId }
    }
    
    /// Get current user ID
    func getUserId() -> String? {
        return queue.sync { currentSession?.userId }
    }
    
    /// Update session with new token
    func updateSession(_ session: EveryMatrixSessionResponse) {
        queue.sync {
            self.currentSession = session
            // Distribute token to publishers
            self.saveToken(session.sessionId, withKey: .playerSessionToken)
            self.saveUserId(session.userId)
            print("[EveryMatrixSessionCoordinator] Session updated - Token: \(session.sessionId), UserID: \(session.userId)")
        }
    }
    
    /// Update stored credentials for re-authentication
    func updateCredentials(_ credentials: EveryMatrixCredentials?) {
        queue.sync {
            self.credentials = credentials
            print("[EveryMatrixSessionCoordinator] Credentials updated for user: \(credentials?.username ?? "nil")")
        }
    }
    
    /// Get valid token, refreshing if necessary
    /// - Parameter forceRefresh: Force token refresh even if current token exists
    /// - Returns: Publisher emitting valid session or error
    func publisherWithValidToken(forceRefresh: Bool = false) -> AnyPublisher<EveryMatrixSessionResponse, Error> {
        return queue.sync { [weak self] in
            guard let self = self else {
                return Fail(error: ServiceProviderError.unknown).eraseToAnyPublisher()
            }
            
            print("[EveryMatrixSessionCoordinator] publisherWithValidToken - forceRefresh: \(forceRefresh)")
            
            // If refresh is already in progress, return shared publisher
            if let publisher = self.refreshPublisher {
                print("[EveryMatrixSessionCoordinator] Refresh already in progress, returning shared publisher")
                return publisher
            }
            
            // Check if we need to force refresh
            var shouldRefresh = forceRefresh
            
            // If no current session, we must refresh
            if self.currentSession == nil {
                print("[EveryMatrixSessionCoordinator] No current session, forcing refresh")
                shouldRefresh = true
            }
            
            // If we have a valid session and don't need to refresh, return it
            if let session = self.currentSession, !shouldRefresh {
                print("[EveryMatrixSessionCoordinator] Returning existing valid session")
                return Just(session).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            
            // We need to refresh - check if we have credentials
            guard let credentials = self.credentials else {
                print("[EveryMatrixSessionCoordinator] No credentials available for refresh")
                return Fail(error: ServiceProviderError.unauthorized).eraseToAnyPublisher()
            }
            
            // Create and store refresh publisher
            let publisher = self.performLogin(credentials: credentials)
                .handleEvents(
                    receiveOutput: { [weak self] session in
                        self?.queue.sync {
                            self?.currentSession = session
                            self?.saveToken(session.sessionId, withKey: .playerSessionToken)
                            self?.saveUserId(session.userId)
                            print("[EveryMatrixSessionCoordinator] Token refresh successful")
                        }
                    },
                    receiveCompletion: { [weak self] _ in
                        self?.queue.sync {
                            self?.refreshPublisher = nil
                        }
                    }
                )
                .share() // Share to prevent multiple simultaneous refreshes
                .eraseToAnyPublisher()
            
            self.refreshPublisher = publisher
            return publisher
        }
    }
    
    // MARK: - Private Methods
    
    /// Perform login with credentials
    private func performLogin(credentials: EveryMatrixCredentials) -> AnyPublisher<EveryMatrixSessionResponse, Error> {
        print("[EveryMatrixSessionCoordinator] Performing login for user: \(credentials.username)")
        
        // Create login endpoint
        let endpoint = EveryMatrixPlayerAPI.login(username: credentials.username, password: credentials.password)
        
        guard let request = endpoint.request() else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { result in
                // Check HTTP status
                if let httpResponse = result.response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200, 201:
                        return result.data
                    case 401:
                        throw ServiceProviderError.unauthorized
                    case 403:
                        // EveryMatrix returns 403 for invalid credentials
                        throw ServiceProviderError.forbidden
                    default:
                        throw ServiceProviderError.unknown
                    }
                }
                return result.data
            }
            .tryMap { data in
                // Decode login response
                let decoder = JSONDecoder()
                let loginResponse = try decoder.decode(EveryMatrix.PhoneLoginResponse.self, from: data)
                
                // Create session response
                return EveryMatrixSessionResponse(
                    sessionId: loginResponse.sessionId,
                    userId: String(loginResponse.userId)
                )
            }
            .mapError { error -> Error in
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                return ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
} 
