// swift-tools-version:5.9
import Foundation
import SwiftSyntax
import SwiftParser

struct Property: Codable {
    let name: String
    let type: String
    let isOptional: Bool
    let isArray: Bool
    let isDictionary: Bool
    let keyType: String?
    let valueType: String?
    let isEnumCase: Bool
    let associatedValues: [String]?  // For enum cases with associated values
}

struct TypeInfo: Codable {
    let name: String
    let kind: String // "class", "struct", or "enum"
    let properties: [Property]
}

class TypeVisitor: SyntaxVisitor {
    var targetTypeName: String
    var currentTypeInfo: TypeInfo?
    var isVerbose: Bool

    init(targetTypeName: String, isVerbose: Bool) {
        self.targetTypeName = targetTypeName
        self.isVerbose = isVerbose
        super.init(viewMode: .sourceAccurate)
    }

    private func debug(_ message: String) {
        if isVerbose {
            print("DEBUG: " + message)
        }
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        debug("📄 Found struct: \(node.name.text)")
        if node.name.text == targetTypeName {
            debug("✅ Found matching struct: \(targetTypeName)")
            var properties: [Property] = []
            for member in node.memberBlock.members {
                if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                    debug("  📝 Processing variable declaration")
                    if let property = processVariableDecl(varDecl) {
                        debug("    ✓ Found property: \(property.name): \(property.type)")
                        properties.append(property)
                    }
                }
            }
            currentTypeInfo = TypeInfo(name: targetTypeName, kind: "struct", properties: properties)
            debug("✨ Finished processing struct with \(properties.count) properties")
            return .skipChildren
        }
        return .skipChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        debug("📄 Found class: \(node.name.text)")
        if node.name.text == targetTypeName {
            debug("✅ Found matching class: \(targetTypeName)")
            var properties: [Property] = []
            for member in node.memberBlock.members {
                if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                    debug("  📝 Processing variable declaration")
                    if let property = processVariableDecl(varDecl) {
                        debug("    ✓ Found property: \(property.name): \(property.type)")
                        properties.append(property)
                    }
                }
            }
            currentTypeInfo = TypeInfo(name: targetTypeName, kind: "class", properties: properties)
            debug("✨ Finished processing class with \(properties.count) properties")
            return .skipChildren
        }
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        debug("📄 Found enum: \(node.name.text)")
        if node.name.text == targetTypeName {
            debug("✅ Found matching enum: \(targetTypeName)")
            var properties: [Property] = []

            // Process enum cases
            for member in node.memberBlock.members {
                if let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) {
                    debug("  📝 Processing enum case declaration")
                    for element in caseDecl.elements {
                        let caseName = element.name.text
                        debug("    🔍 Processing case: \(caseName)")

                        // Handle associated values if present
                        var associatedValues: [String]? = nil
                        if let parameterClause = element.parameterClause {
                            associatedValues = []
                            for parameter in parameterClause.parameters {
                                let typeString = parameter.type.description.trimmingCharacters(in: .whitespaces)
                                associatedValues?.append(typeString)
                            }
                            debug("      📦 Associated values: \(associatedValues ?? [])")
                        }

                        let property = Property(
                            name: caseName,
                            type: targetTypeName, // The enum type itself
                            isOptional: false,
                            isArray: false,
                            isDictionary: false,
                            keyType: nil,
                            valueType: nil,
                            isEnumCase: true,
                            associatedValues: associatedValues
                        )
                        debug("    ✓ Added enum case: \(caseName)")
                        properties.append(property)
                    }
                }

                // Also process any regular properties (like computed properties)
                if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                    debug("  📝 Processing variable declaration")
                    if let property = processVariableDecl(varDecl) {
                        debug("    ✓ Found property: \(property.name): \(property.type)")
                        properties.append(property)
                    }
                }
            }

            currentTypeInfo = TypeInfo(name: targetTypeName, kind: "enum", properties: properties)
            debug("✨ Finished processing enum with \(properties.count) cases/properties")
            return .skipChildren
        }
        return .skipChildren
    }

    private func processVariableDecl(_ varDecl: VariableDeclSyntax) -> Property? {
        guard let binding = varDecl.bindings.first,
              let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
              let type = binding.typeAnnotation?.type else {
            debug("    ⚠️ Skipping invalid variable declaration")
            return nil
        }

        let propertyName = pattern.identifier.text
        debug("    🔍 Analyzing type for property: \(propertyName)")
        let (baseType, isOptional, isArray, isDictionary, keyType, valueType) = analyzeType(type)
        debug("      Type details:")
        debug("      - Base type: \(baseType)")
        debug("      - Optional: \(isOptional)")
        debug("      - Array: \(isArray)")
        debug("      - Dictionary: \(isDictionary)")
        if isDictionary {
            debug("      - Key type: \(keyType ?? "nil")")
            debug("      - Value type: \(valueType ?? "nil")")
        }

        return Property(
            name: propertyName,
            type: baseType,
            isOptional: isOptional,
            isArray: isArray,
            isDictionary: isDictionary,
            keyType: keyType,
            valueType: valueType,
            isEnumCase: false,
            associatedValues: nil
        )
    }

    private func analyzeType(_ type: TypeSyntax) -> (String, Bool, Bool, Bool, String?, String?) {
        var isOptional = false
        var isArray = false
        var isDictionary = false
        var keyType: String? = nil
        var valueType: String? = nil
        var baseType = type.description.trimmingCharacters(in: .whitespaces)

        debug("      Raw type: \(baseType)")

        // Check for Optional
        if baseType.hasSuffix("?") {
            isOptional = true
            baseType = String(baseType.dropLast())
            debug("      Detected optional type")
        }

        // Check for Array
        if baseType.hasPrefix("[") && baseType.hasSuffix("]") {
            if baseType.contains(":") {
                // This is actually a dictionary
                isDictionary = true
                let components = baseType.dropFirst().dropLast().components(separatedBy: ":")
                if components.count == 2 {
                    keyType = components[0].trimmingCharacters(in: .whitespaces)
                    valueType = components[1].trimmingCharacters(in: .whitespaces)
                    baseType = "Dictionary"
                    debug("      Detected dictionary type: [\(keyType ?? ""): \(valueType ?? "")]")
                }
            } else {
                isArray = true
                baseType = String(baseType.dropFirst().dropLast())
                debug("      Detected array type: [\(baseType)]")
            }
        }

        return (baseType, isOptional, isArray, isDictionary, keyType, valueType)
    }
}

// Main execution
let isVerbose = CommandLine.arguments.contains("--verbose")

if isVerbose {
    print("🚀 Swift Parser starting")
    print("Arguments: \(CommandLine.arguments)")
}

// Check arguments
let requiredArgCount = isVerbose ? 4 : 3 // Add 1 if --verbose is present
guard CommandLine.arguments.count >= 3 else {
    if isVerbose {
        print("❌ Error: Wrong number of arguments")
    }
    print("Usage: swift swift_parser.swift <swift-file-path> <type-name> [--verbose]")
    exit(1)
}

let filePath = CommandLine.arguments[1]
let typeName = CommandLine.arguments[2]

if isVerbose {
    print("📂 File path: \(filePath)")
    print("🔍 Type name: \(typeName)")
}

do {
    if isVerbose { print("📖 Reading file contents...") }
    let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
    if isVerbose { print("📝 Parsing source file...") }
    let sourceFile = Parser.parse(source: fileContents)

    if isVerbose { print("🔍 Creating visitor...") }
    let visitor = TypeVisitor(targetTypeName: typeName, isVerbose: isVerbose)
    if isVerbose { print("🚶‍♂️ Walking syntax tree...") }
    visitor.walk(sourceFile)

    if let typeInfo = visitor.currentTypeInfo {
        if isVerbose { print("✅ Type found, encoding to JSON...") }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(typeInfo)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            // Only output the JSON, nothing else
            print(jsonString)
        }
    } else {
        if isVerbose {
            print("❌ Type '\(typeName)' not found in file.")
        }
        // Output empty JSON object when type not found
        print("{}")
    }
} catch {
    if isVerbose {
        print("❌ Error: \(error)")
    }
    // Output empty JSON object on error
    print("{}")
    exit(1)
}
