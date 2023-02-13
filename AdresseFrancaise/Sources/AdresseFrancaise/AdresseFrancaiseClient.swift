import Combine
import Foundation

public enum AdresseFrancaiseError: Error, Equatable {
    case invalidQuery
    case shortQuery
    case serverError(details: String)
    case decoding(details: String)
}

public struct AdresseFrancaiseClient {

    public init() {

    }

    public func searchCommune(query: String) -> AnyPublisher<[AddressResult], AdresseFrancaiseError> {
        return self.search(query: query, typeFilter: "municipality")
    }

    public func searchStreet(query: String) -> AnyPublisher<[AddressResult], AdresseFrancaiseError> {
        return self.search(query: query, typeFilter: "street")
    }

    private func search(query: String, typeFilter: String) -> AnyPublisher<[AddressResult], AdresseFrancaiseError> {

        guard
            var urlComponents = URLComponents(string: "https://api-adresse.data.gouv.fr/search/")
        else {
            return Fail(error: AdresseFrancaiseError.invalidQuery).eraseToAnyPublisher()
        }

        if query.count < 3 {
            return Fail(error: AdresseFrancaiseError.shortQuery).eraseToAnyPublisher()
        }

        let proccessedQuery = query.replacingOccurrences(of: " ", with: "+")

        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "q", value: "\(proccessedQuery)"))
        queryItems.append(URLQueryItem(name: "type", value: typeFilter))
        queryItems.append(URLQueryItem(name: "limit", value: "10"))
        queryItems.append(URLQueryItem(name: "autocomplete", value: "1"))

        urlComponents.queryItems = queryItems
        
        guard
            let completedURL = urlComponents.url
        else {
            return Fail(error: AdresseFrancaiseError.invalidQuery).eraseToAnyPublisher()
        }

        var request =  URLRequest(url: completedURL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let session = URLSession.shared

        let decoder = JSONDecoder()
        return session.dataTaskPublisher(for: request)
            .map(\.data)
//            .handleEvents(receiveOutput: { data in
//                print("DEBUG AdresseFrancaise: \(String.init(data: data, encoding: .utf8))")
//            })
            .decode(type: AddressSearchResponse.self, decoder: decoder)
            .mapError({ error in
                switch error {
                case let decodingError as DecodingError:
                    return AdresseFrancaiseError.decoding(details: decodingError.errorDescription ?? decodingError.localizedDescription)
                case let urlError as URLError:
                    return AdresseFrancaiseError.serverError(details: urlError.localizedDescription)
                default:
                    return AdresseFrancaiseError.serverError(details: error.localizedDescription)
                }
            })
            .map(\.results)
            .eraseToAnyPublisher()
    }

}

public struct AddressSearchResponse: Codable {

    public var results: [AddressResult]

    enum CodingKeys: String, CodingKey {
        case results = "features"
    }

    public init(results: [AddressResult]) {
        self.results = results
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.results = try container.decode([AddressResult].self, forKey: .results)
    }

}

public struct AddressResult: Codable {

    public var type: String
    public var name: String
    public var label: String
    public var street: String?
    public var city: String?
    public var district: String?

    enum CodingKeys: String, CodingKey {
        case type = "type"
        case name = "name"
        case label = "label"
        case city = "city"
        case street = "street"
        case district = "district"
        case properties = "properties"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let properties = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .properties)

        self.type = try properties.decode(String.self, forKey: .type)
        self.name = try properties.decode(String.self, forKey: .name)
        self.label = try properties.decode(String.self, forKey: .label)
        self.city = try properties.decodeIfPresent(String.self, forKey: .city)
        self.street = try properties.decodeIfPresent(String.self, forKey: .street)
        self.district = try properties.decodeIfPresent(String.self, forKey: .district)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.label, forKey: .label)
        try container.encodeIfPresent(self.city, forKey: .city)
        try container.encodeIfPresent(self.street, forKey: .street)
        try container.encodeIfPresent(self.district, forKey: .district)
    }

}
