import Foundation
import Combine

class EveryMatrixCasinoConnector: Connector {
    
    var connectionStateSubject: CurrentValueSubject<ConnectorState, Never> = .init(.connected)
    var connectionStatePublisher: AnyPublisher<ConnectorState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private var cancellables: Set<AnyCancellable> = []
    
    private(set) var sessionToken: EveryMatrixSessionToken?
    
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
        
        setupNetworkMonitoring()
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, ServiceProviderError> {
        
        guard let request = endpoint.request() else {
            return Fail(error: ServiceProviderError.invalidRequestFormat).eraseToAnyPublisher()
        }
        
        var finalRequest = request
        if endpoint.requireSessionKey, let token = sessionToken?.sessionId {
            finalRequest.setValue("sessionId=\(token)", forHTTPHeaderField: "Cookie")
        }
        
        return session.dataTaskPublisher(for: finalRequest)
            .tryMap { [weak self] result -> Data in
                guard let self = self else { throw ServiceProviderError.unknown }
                
                if let httpResponse = result.response as? HTTPURLResponse {
                    
                    switch httpResponse.statusCode {
                    case 200, 201:
                        return result.data
                    case 401:
                        self.sessionToken = nil
                        throw ServiceProviderError.unauthorized
                    case 403:
                        throw ServiceProviderError.forbidden
                    case 404:
                        throw ServiceProviderError.notFound
                    case 429:
                        throw ServiceProviderError.rateLimitExceeded
                    case 500...599:
                        if let apiError = try? JSONDecoder().decode(EveryMatrix.EveryMatrixAPIError.self, from: result.data) {
                            let errorMessage = apiError.thirdPartyResponse?.message ?? "Server Error"
                            throw ServiceProviderError.errorMessage(message: errorMessage)
                        } else {
                            throw ServiceProviderError.internalServerError
                        }
                    default:
                        throw ServiceProviderError.unknown
                    }
                }
                return result.data
            }
            .mapError { error -> ServiceProviderError in
                if let serviceError = error as? ServiceProviderError {
                    return serviceError
                }
                if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    self.connectionStateSubject.send(.disconnected)
                    return ServiceProviderError.noNetworkConnection
                }
                return ServiceProviderError.errorMessage(message: error.localizedDescription)
            }
            .flatMap { [weak self] data -> AnyPublisher<T, ServiceProviderError> in
                guard let self = self else {
                    return Fail(error: ServiceProviderError.unknown).eraseToAnyPublisher()
                }
                
                do {
                    let decodedObject = try self.decoder.decode(T.self, from: data)
                    return Just(decodedObject)
                        .setFailureType(to: ServiceProviderError.self)
                        .eraseToAnyPublisher()
                } catch {
                    if error is DecodingError {
                        return Fail(error: ServiceProviderError.decodingError(message: error.localizedDescription))
                            .eraseToAnyPublisher()
                    }
                    return Fail(error: ServiceProviderError.invalidResponse)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func updateSessionToken(sessionId: String, userId: String) {
        self.sessionToken = EveryMatrixSessionToken(sessionId: sessionId, id: userId)
    }
    
    func clearSession() {
        self.sessionToken = nil
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
