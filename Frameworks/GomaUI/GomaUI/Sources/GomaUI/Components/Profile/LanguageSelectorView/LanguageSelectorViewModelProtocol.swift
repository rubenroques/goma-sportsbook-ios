import Foundation
import Combine

/// Protocol defining the interface for LanguageSelectorView view model
public protocol LanguageSelectorViewModelProtocol {
    
    /// Publisher that emits the list of available languages
    var languagesPublisher: AnyPublisher<[LanguageModel], Never> { get }
    
    /// Publisher that emits the currently selected language
    var selectedLanguagePublisher: AnyPublisher<LanguageModel?, Never> { get }
    
    /// Publisher that emits when a language selection change occurs
    var languageChangedPublisher: AnyPublisher<LanguageModel, Never> { get }
    
    /// Called when user selects a language
    /// - Parameter language: The selected language model
    func selectLanguage(_ language: LanguageModel)
    
    /// Loads the available languages list
    func loadLanguages()
    
    /// Updates the available languages
    /// - Parameter languages: Array of language models to set
    func setLanguages(_ languages: [LanguageModel])
    
    /// Sets the initial selected language
    /// - Parameter language: Language model to select initially
    func setInitialSelection(_ language: LanguageModel)
    
    /// Gets the currently selected language synchronously
    /// - Returns: Currently selected language model, if any
    func getCurrentSelection() -> LanguageModel?
}
