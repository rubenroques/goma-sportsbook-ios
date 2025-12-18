import Foundation
import ArgumentParser

struct LocalizationHelper: ParsableCommand {
    @Argument(help: "Path to the project root.")
    var projectRootPath: String
    
    mutating func run() throws {
        let localizationManager = LocalizationManager(projectRootPath: projectRootPath)
        try localizationManager.processUnusedKeys()
    }
}