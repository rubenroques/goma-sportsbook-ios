import Foundation

func processDirectory(_ url: URL) throws {
    let fileManager = FileManager.default
    let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
    
    for contentURL in contents {
        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: contentURL.path, isDirectory: &isDirectory)
        
        if isDirectory.boolValue {
            try processDirectory(contentURL)
        } else if contentURL.pathExtension == "swift" {
            let extractor = StructExtractor(sourceURL: contentURL)
            try extractor.processFile()
        }
    }
}

if CommandLine.arguments.count < 2 {
    print("Usage: SwiftModelOrganizer /path/to/your/swift/files")
    exit(1)
}

let inputPath = CommandLine.arguments[1]
let inputURL = URL(fileURLWithPath: inputPath)

do {
    try processDirectory(inputURL)
} catch {
    print("Error: \(error)")
    exit(1)
}
