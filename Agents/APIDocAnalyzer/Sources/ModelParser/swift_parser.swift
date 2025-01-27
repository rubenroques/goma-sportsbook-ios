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
}

struct TypeInfo: Codable {
    let name: String
    let kind: String // "class" or "struct"
    let properties: [Property]
}

class TypeVisitor: SyntaxVisitor {
    var targetTypeName: String
    var currentTypeInfo: TypeInfo?
    
    init(targetTypeName: String) {
        self.targetTypeName = targetTypeName
        super.init(viewMode: .sourceAccurate)
    }
    
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.name.text == targetTypeName {
            var properties: [Property] = []
            for member in node.memberBlock.members {
                if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                    if let property = processVariableDecl(varDecl) {
                        properties.append(property)
                    }
                }
            }
            currentTypeInfo = TypeInfo(name: targetTypeName, kind: "struct", properties: properties)
            return .skipChildren
        }
        return .skipChildren
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.name.text == targetTypeName {
            var properties: [Property] = []
            for member in node.memberBlock.members {
                if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                    if let property = processVariableDecl(varDecl) {
                        properties.append(property)
                    }
                }
            }
            currentTypeInfo = TypeInfo(name: targetTypeName, kind: "class", properties: properties)
            return .skipChildren
        }
        return .skipChildren
    }
    
    private func processVariableDecl(_ varDecl: VariableDeclSyntax) -> Property? {
        guard let binding = varDecl.bindings.first,
              let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
              let type = binding.typeAnnotation?.type else {
            return nil
        }
        
        let propertyName = pattern.identifier.text
        let (baseType, isOptional, isArray, isDictionary, keyType, valueType) = analyzeType(type)
        
        return Property(
            name: propertyName,
            type: baseType,
            isOptional: isOptional,
            isArray: isArray,
            isDictionary: isDictionary,
            keyType: keyType,
            valueType: valueType
        )
    }
    
    private func analyzeType(_ type: TypeSyntax) -> (String, Bool, Bool, Bool, String?, String?) {
        var isOptional = false
        var isArray = false
        var isDictionary = false
        var keyType: String? = nil
        var valueType: String? = nil
        var baseType = type.description.trimmingCharacters(in: .whitespaces)
        
        // Check for Optional
        if baseType.hasSuffix("?") {
            isOptional = true
            baseType = String(baseType.dropLast())
        }
        
        // Check for Array
        if baseType.hasPrefix("[") && baseType.hasSuffix("]") {
            isArray = true
            baseType = String(baseType.dropFirst().dropLast())
        }
        
        // Check for Dictionary
        if baseType.contains(":") && baseType.hasPrefix("[") && baseType.hasSuffix("]") {
            isDictionary = true
            let components = baseType.dropFirst().dropLast().components(separatedBy: ":")
            if components.count == 2 {
                keyType = components[0].trimmingCharacters(in: .whitespaces)
                valueType = components[1].trimmingCharacters(in: .whitespaces)
                baseType = "Dictionary"
            }
        }
        
        return (baseType, isOptional, isArray, isDictionary, keyType, valueType)
    }
}

// Main execution
guard CommandLine.arguments.count == 3 else {
    print("Usage: swift swift_parser.swift <swift-file-path> <type-name>")
    exit(1)
}

let filePath = CommandLine.arguments[1]
let typeName = CommandLine.arguments[2]

do {
    let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
    let sourceFile = Parser.parse(source: fileContents)
    
    let visitor = TypeVisitor(targetTypeName: typeName)
    visitor.walk(sourceFile)
    
    if let typeInfo = visitor.currentTypeInfo {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(typeInfo)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }
    } else {
        print("Type '\(typeName)' not found in file.")
    }
} catch {
    print("Error: \(error)")
    exit(1)
} 