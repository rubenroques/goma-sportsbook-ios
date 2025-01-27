import Foundation

// MARK: - Data Structures
struct APIInventory: Codable {
    let models: [Model]
    let endpoints: Endpoints
}

struct Model: Codable {
    let name: String
    let path: String
    let properties: [Property]
    let relationships: [Relationship]
}

struct Property: Codable {
    let name: String
    let type: String
}

struct Relationship: Codable {
    let source_property: String
    let target_type: String
}

struct Endpoints: Codable {
    let rest: [String]
    let websocket: [String]
}

// MARK: - Sportradar Documentation Structures
struct SportradarDoc: Codable {
    let api_methods: [String: [String: EndpointDetails]]
    let websocket_methods: [String: EndpointDetails]
}

struct EndpointDetails: Codable {
    let description: String?
    let signature: String?
    let parameters: Parameters?
    let returns: ReturnDetails?
    let subscription_details: SubscriptionDetails?
    let content_identifier: ContentIdentifier?
}

// Make Parameters handle both dictionary and string cases
enum Parameters: Codable {
    case dictionary([String: ParameterDetails])
    case single(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let dict = try? container.decode([String: ParameterDetails].self) {
            self = .dictionary(dict)
        } else if let str = try? container.decode(String.self) {
            self = .single(str)
        } else {
            throw DecodingError.typeMismatch(
                Parameters.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected either a dictionary or a string"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .dictionary(let dict):
            try container.encode(dict)
        case .single(let str):
            try container.encode(str)
        }
    }
}

struct ParameterDetails: Codable {
    let type: String?
    let description: String?

    // Handle nested parameters
    private enum CodingKeys: String, CodingKey {
        case type, description
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try to decode as regular parameter first
        if let typeValue = try? container.decodeIfPresent(String.self, forKey: .type) {
            self.type = typeValue
            self.description = try container.decodeIfPresent(String.self, forKey: .description)
        } else {
            // If that fails, treat it as a nested parameter
            self.type = "Object"
            self.description = "Complex parameter with multiple fields"
        }
    }
}

struct ReturnDetails: Codable {
    let type: String?
    let description: String?
}

struct SubscriptionDetails: Codable {
    let requires_socket_token: Bool?
    let auto_unsubscribe: Bool?
    let update_frequency: String?
    let event_updates: EventUpdates?
    let market_types: MarketTypes?
}

struct EventUpdates: Codable {
    let includes: [String]?
}

struct MarketTypes: Codable {
    let includes: [String]?
}

struct ContentIdentifier: Codable {
    let type: String?
    let route: String?
}

// MARK: - Documentation Generator
class DocumentationGenerator {
    private let inventory: APIInventory
    private let sportradarDoc: SportradarDoc
    private var modelLinks: [String: String] = [:]

    init(inventoryPath: String, docPath: String) throws {
        // Load API inventory
        let inventoryData = try Data(contentsOf: URL(fileURLWithPath: inventoryPath))
        self.inventory = try JSONDecoder().decode(APIInventory.self, from: inventoryData)

        print("📝 Found \(inventory.models.count) models in inventory")
        print("🔍 Looking for Event model...")

        // Debug: Print all model names
        let modelNames = inventory.models.map { $0.name }
        print("📋 All models: \(modelNames.joined(separator: ", "))")

        if let eventModel = inventory.models.first(where: { $0.name == "Event" }) {
            print("✅ Found Event model at path: \(eventModel.path)")
        } else {
            print("❌ Event model not found in inventory")
        }

        // Load Sportradar documentation
        let docData = try Data(contentsOf: URL(fileURLWithPath: docPath))
        self.sportradarDoc = try JSONDecoder().decode(SportradarDoc.self, from: docData)

        // Generate model anchors
        for model in inventory.models {
            modelLinks[model.name] = "#\(model.name.lowercased())"
        }

        // Debug: Print all model links
        print("🔗 Model links created: \(modelLinks.keys.joined(separator: ", "))")
    }

    func generateMarkdown() -> String {
        var markdown = """
        # API Documentation

        This documentation provides a comprehensive overview of our API services, including available endpoints and data models.

        ## Table of Contents
        1. [REST Services](#rest-services)
        2. [Real-time Services](#real-time-services)
        3. [Data Models](#data-models)

        """

        // Add REST Services
        markdown += "\n# REST Services\n\n"
        for (category, endpoints) in sportradarDoc.api_methods {
            markdown += "## \(category)\n\n"

            for (endpoint, details) in endpoints {
                markdown += formatEndpoint(name: endpoint, details: details)
            }
        }

        // Add WebSocket Services
        markdown += "\n# Real-time Services\n\n"
        markdown += "_These services provide real-time updates through WebSocket connections._\n\n"

        for (endpoint, details) in sportradarDoc.websocket_methods {
            markdown += formatWebSocketEndpoint(name: endpoint, details: details)
        }

        // Add Models
        markdown += "\n# Data Models\n\n"
        markdown += "_This section describes the data structures used in the API._\n\n"

        for model in inventory.models.sorted(by: { $0.name < $1.name }) {
            markdown += formatModel(model: model)
        }

        return markdown
    }

    private func formatEndpoint(name: String, details: EndpointDetails) -> String {
        var output = "### 🔸 \(name)\n\n"  // Just use the raw name

        if let description = details.description {
            output += "_\(description)_\n\n"
        }

        // Handle parameters
        if let parameters = details.parameters {
            output += "**Arguments:**\n"
            switch parameters {
            case .dictionary(let params):
                for (paramName, param) in params {
                    // let description = param.description ?? "No description available"
                    let type = param.type ?? "Unknown type"
                    let linkedType = linkModelsInType(type)
                    output += "- \(paramName): \(linkedType)\n"
                }
            case .single(let param):
                output += "- \(param)\n"
            }
            output += "\n"
        }


        // Extract return type from signature if available
        if let signature = details.signature {
            let returnTypes = extractReturnTypes(from: signature)
            if !returnTypes.isEmpty {
                output += "**Returns:** "
                output += returnTypes.map { linkModelsInType($0) }.joined(separator: ", ")
                output += "\n\n"
            }
        }

        // Add subscription details if available
        if let subscription = details.subscription_details {
            output += "**Subscription Details:**\n"
            if let frequency = subscription.update_frequency {
                output += "- Update Frequency: \(frequency)\n"
            }
            if let updates = subscription.event_updates?.includes {
                output += "- Updates Include:\n"
                for update in updates {
                    output += "  - \(update)\n"
                }
            }
            if let marketTypes = subscription.market_types?.includes {
                output += "- Market Types:\n"
                for type in marketTypes {
                    output += "  - \(type)\n"
                }
            }
            output += "\n"
        }

        return output
    }

    private func extractReturnTypes(from signature: String) -> [String] {
        // Match return types in different formats, ignoring AnyPublisher wrapper:
        // 1. AnyPublisher<Type, Error> -> extract Type
        // 2. -> Type
        // 3. [Type]
        let patterns = [
            #"AnyPublisher<([^,]+),\s*[^>]+>"#,  // Extract type from AnyPublisher<Type, Error>
            #"-> *([A-Za-z0-9_\[\]]+)"#,         // -> Type or -> [Type]
            #"\[([A-Za-z0-9_]+)\]"#              // [Type] in other contexts
        ]

        var types = Set<String>()

        for pattern in patterns {
            let regex = try? NSRegularExpression(pattern: pattern)
            let nsRange = NSRange(signature.startIndex..<signature.endIndex, in: signature)

            regex?.matches(in: signature, range: nsRange).forEach { match in
                if let typeRange = Range(match.range(at: 1), in: signature) {
                    var type = String(signature[typeRange]).trimmingCharacters(in: .whitespaces)

                    // Remove AnyPublisher wrapper if present
                    if type.hasPrefix("AnyPublisher<") {
                        type = type.replacingOccurrences(of: "AnyPublisher<", with: "")
                            .replacingOccurrences(of: ", Error>", with: "")
                            .trimmingCharacters(in: .whitespaces)
                    }

                    // Filter out non-model types
                    if !type.isEmpty && !["Error", "Void", "AnyPublisher"].contains(type) {
                        types.insert(type)
                    }
                }
            }
        }

        return Array(types).sorted()
    }

    private func linkModelsInSignature(_ signature: String) -> String {
        // Regular expression to find Swift types in function signature
        let pattern = #"(?:->|:)\s*(?:AnyPublisher<)?([A-Za-z_][A-Za-z0-9_]*(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*)?)"#
        var result = signature

        let regex = try? NSRegularExpression(pattern: pattern)
        let nsRange = NSRange(signature.startIndex..<signature.endIndex, in: signature)

        // Process matches in reverse to avoid messing up string indices
        regex?.matches(in: signature, range: nsRange)
            .reversed()
            .forEach { match in
                if let typeRange = Range(match.range(at: 1), in: signature) {
                    let type = String(signature[typeRange])
                    // Split for cases like "Model, Error"
                    let types = type.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }

                    for modelName in types {
                        if let link = modelLinks[modelName] {
                            result = result.replacingOccurrences(
                                of: modelName,
                                with: "[\(modelName)](\(link))"
                            )
                        }
                    }
                }
            }

        return result
    }

    private func linkModelsInType(_ type: String) -> String {
        // Check if this type exists in our model links
        if let link = modelLinks[type] {
            return "[\(type)](\(link))"
        }
        return type
    }

    private func formatWebSocketEndpoint(name: String, details: EndpointDetails) -> String {
        var output = "### 🔹 \(name)\n\n"  // Just use the raw name

        if let description = details.description {
            output += "_\(description)_\n\n"
        }

        if let subscription = details.subscription_details {
            output += "**Update Information:**\n"
            if let frequency = subscription.update_frequency {
                output += "- Frequency: \(frequency)\n"
            }
            if let updates = subscription.event_updates?.includes {
                output += "- Includes:\n"
                for update in updates {
                    output += "  - \(update)\n"
                }
            }
            output += "\n"
        }

        return output
    }

    private func formatModel(model: Model) -> String {
        var output = "### Ⓜ️ \(model.name)\n\n"

        output += "**Properties:**\n\n"
        output += "| Name | Type |\n"
        output += "|------|------|\n"

        for property in model.properties {
            let typeString = property.type
            output += "| \(property.name) | \(typeString) |\n"
        }

        if !model.relationships.isEmpty {
            // Use a Set to remove duplicates while preserving order
            var uniqueRelations = Set<String>()
            output += "\n**Related Models:**\n"
            for relationship in model.relationships {
                let targetModel = relationship.target_type
                if !targetModel.isEmpty && !uniqueRelations.contains(targetModel), let targetLink = modelLinks[targetModel] {
                    uniqueRelations.insert(targetModel)
                    output += "- [\(targetModel)](\(targetLink))\n"
                }
            }
        }

        output += "\n"
        return output
    }
}

// MARK: - Main
do {
    guard CommandLine.arguments.count > 2 else {
        print("Usage: swift DocGenerator.swift <path_to_api_inventory.json> <path_to_sportradar_documentation.json>")
        exit(1)
    }

    let inventoryPath = CommandLine.arguments[1]
    let docPath = CommandLine.arguments[2]
    let generator = try DocumentationGenerator(inventoryPath: inventoryPath, docPath: docPath)
    let markdown = generator.generateMarkdown()

    // Write to documentation file
    try markdown.write(toFile: "API.md", atomically: true, encoding: .utf8)
    print("✅ Documentation generated successfully in API.md")
} catch {
    print("❌ Error: \(error)")
    exit(1)
}