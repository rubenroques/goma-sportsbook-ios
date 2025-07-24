import Foundation
import XCTest

/// Utility for loading JSON files in tests
class JSONLoader {
    
    /// Error types that can occur when loading JSON
    enum JSONLoaderError: Error {
        case fileNotFound(String)
        case invalidJSON(String)
        case decodingFailed(String)
    }
    
    /// The base directory for mock responses
    static let mockResponsesDirectory = "MockResponses"
    
    /// Load a JSON file from the mock responses directory
    /// - Parameters:
    ///   - fileName: The name of the file to load (default: "response.json")
    ///   - subdirectory: The subdirectory within the mock responses directory
    /// - Returns: The loaded JSON data
    static func loadJSON(fileName: String = "response.json", subdirectory: String) throws -> Data {
        // Build the path to the JSON file
        let bundle = Bundle(for: JSONLoader.self)
        
        // First try to find the file in the test bundle
        if let path = bundle.path(forResource: fileName, ofType: nil, inDirectory: "\(mockResponsesDirectory)/\(subdirectory)") {
            return try Data(contentsOf: URL(fileURLWithPath: path))
        }
        
        // If not found in the bundle, try to find it relative to the current file
        let currentFilePath = #file
        let currentDirectoryURL = URL(fileURLWithPath: currentFilePath).deletingLastPathComponent()
        let mockResponsesURL = currentDirectoryURL.appendingPathComponent("../MockResponses/\(subdirectory)/\(fileName)")
        
        do {
            return try Data(contentsOf: mockResponsesURL)
        } catch {
            throw JSONLoaderError.fileNotFound("Could not find JSON file at path: \(mockResponsesURL.path)")
        }
    }
    
    /// Load and decode a JSON file into a Decodable type
    /// - Parameters:
    ///   - fileName: The name of the file to load (default: "response.json")
    ///   - subdirectory: The subdirectory within the mock responses directory
    ///   - type: The type to decode the JSON into
    /// - Returns: The decoded object
    static func decode<T: Decodable>(fileName: String = "response.json", subdirectory: String, as type: T.Type) throws -> T {
        let data = try loadJSON(fileName: fileName, subdirectory: subdirectory)
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode(type, from: data)
        } catch {
            throw JSONLoaderError.decodingFailed("Failed to decode JSON as \(String(describing: type)): \(error)")
        }
    }
    
    /// Load a JSON file and convert it to a dictionary
    /// - Parameters:
    ///   - fileName: The name of the file to load (default: "response.json")
    ///   - subdirectory: The subdirectory within the mock responses directory
    /// - Returns: The JSON as a dictionary
    static func loadJSONAsDictionary(fileName: String = "response.json", subdirectory: String) throws -> [String: Any] {
        let data = try loadJSON(fileName: fileName, subdirectory: subdirectory)
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                throw JSONLoaderError.invalidJSON("JSON is not a dictionary")
            }
            return json
        } catch {
            throw JSONLoaderError.invalidJSON("Failed to parse JSON: \(error)")
        }
    }
    
    /// Load a JSON file and convert it to an array
    /// - Parameters:
    ///   - fileName: The name of the file to load (default: "response.json")
    ///   - subdirectory: The subdirectory within the mock responses directory
    /// - Returns: The JSON as an array
    static func loadJSONAsArray(fileName: String = "response.json", subdirectory: String) throws -> [[String: Any]] {
        let data = try loadJSON(fileName: fileName, subdirectory: subdirectory)
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                throw JSONLoaderError.invalidJSON("JSON is not an array of dictionaries")
            }
            return json
        } catch {
            throw JSONLoaderError.invalidJSON("Failed to parse JSON: \(error)")
        }
    }
} 