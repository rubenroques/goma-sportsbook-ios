import Foundation

class LocalizationManager {
    private let projectRootPath: String
    
    init(projectRootPath: String) {
        self.projectRootPath = projectRootPath
    }
    
    func processUnusedKeys() throws {
        print("Finding used keys in the project...")
        let usedKeys = try findUsedKeysInProject()

        print("Finding Localization.strings files...")
        let localizationFilePaths = try findLocalizationStringsFiles()
        
        print("Found \(usedKeys.count) used localization keys \( Array(usedKeys.prefix(6) ) )")
        print("Found \(localizationFilePaths.count) localization files")

        for (index, localizationFilePath) in localizationFilePaths.enumerated() {
            print("Processing Localization.strings file (\(index + 1)/\(localizationFilePaths.count)): \(localizationFilePath)")

            let keys = try extractKeysFromLocalizationFile(localizationFilePath: localizationFilePath)
            let unusedKeys = keys.subtracting(usedKeys)
            
            try addCommentsToUnusedKeys(unusedKeys: unusedKeys, localizationFilePath: localizationFilePath)
        }
        
        print("Finished processing all Localization.strings files.")
    }

    private func extractKeysFromLocalizationFile(localizationFilePath: String) throws -> Set<String> {
        let fileURL = URL(fileURLWithPath: localizationFilePath)
        let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
        let keyValuePairs = fileContent.components(separatedBy: .newlines)
        
        var keys = Set<String>()
        for pair in keyValuePairs {
            let key = pair.trimmingCharacters(in: .whitespacesAndNewlines)
            if key.isEmpty { continue }
            let keyComponents = key.components(separatedBy: " = ")
            let extractedKey = keyComponents[0].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            keys.insert(extractedKey)
        }
        
        print("Localized Keys: ", Array(keys.prefix(6)))
        return keys
    }
    

    private func findLocalizationStringsFiles() throws -> [String] {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: projectRootPath)
        
        var localizationFilePaths: [String] = []
        
        while let filePath = enumerator?.nextObject() as? String {
            if filePath.hasSuffix("Localizable.strings") {
                let fullPath = projectRootPath + "/" + filePath
                localizationFilePaths.append(fullPath)
            }
        }
        
        return localizationFilePaths
    }
    

private func findUsedKeysInProject() throws -> Set<String> {
    let fileManager = FileManager.default
    let enumerator = fileManager.enumerator(atPath: projectRootPath)
    
    var usedKeys = Set<String>()
    
    while let filePath = enumerator?.nextObject() as? String {
        if filePath.hasSuffix(".swift") {
            let fullPath = projectRootPath + "/" + filePath
            let fileURL = URL(fileURLWithPath: fullPath)
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            
              let regexPatterns = [
                #"(?<=Localization.localized\(\")[^\"]*(?=\"\)\(\))"#,
                #"(?<=localized\(\")[^\"]*(?=\"\))"#
            ]
            
            for pattern in regexPatterns {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: fileContent, options: [], range: NSRange(location: 0, length: fileContent.utf16.count))
                
                for match in matches {
                    let keyRange = Range(match.range(at: 0), in: fileContent)!
                    let key = String(fileContent[keyRange])
                    usedKeys.insert(key)
                }
            }
        }
    }
    
    return usedKeys
}

private func addCommentsToUnusedKeys(unusedKeys: Set<String>, localizationFilePath: String) throws {
    let fileURL = URL(fileURLWithPath: localizationFilePath)
    var fileContent = try String(contentsOf: fileURL, encoding: .utf8)
    
    for key in unusedKeys {
        let regexPattern = "(^|\n)\\s*\"\(NSRegularExpression.escapedPattern(for: key))\"\\s*=\\s*\"[^\"]*\";"
        let regex = try NSRegularExpression(pattern: regexPattern, options: [])
        let comment = " // UNUSED"
        let replacement = "$0\(comment)"
        
        fileContent = regex.stringByReplacingMatches(in: fileContent, options: [], range: NSRange(location: 0, length: fileContent.utf16.count), withTemplate: replacement)
    }
    
    try fileContent.write(to: fileURL, atomically: true, encoding: .utf8)
}



}