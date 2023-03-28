import Foundation

final class StructExtractor {
    private let sourceURL: URL

    init(sourceURL: URL) {
        self.sourceURL = sourceURL
    }

    func processFile() throws {
        let sourceContent = try String(contentsOf: sourceURL, encoding: .utf8)
        
        let structPattern = "(?sm)\\s*struct\\s+(\\w+)\\s*\\{[^\\{\\}]*\\}"
        let regex = try NSRegularExpression(pattern: structPattern, options: [])
        
        let matches = regex.matches(in: sourceContent, options: [], range: NSRange(sourceContent.startIndex..., in: sourceContent))

        if !matches.isEmpty {
            print("File: \(sourceURL.path)")
            for match in matches {
                let structNameRange = Range(match.range(at: 1), in: sourceContent)!
                let structName = String(sourceContent[structNameRange])
                print("  Struct: \(structName)")
            }
        }
    }
}
