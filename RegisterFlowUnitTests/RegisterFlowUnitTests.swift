//
//  RegisterFlowUnitTests.swift
//  RegisterFlowUnitTests
//
//  Created by André Lascas on 20/02/2025.
//

import XCTest

import Foundation
import RegisterFlow
import ServicesProvider
import Combine
import XCTest
import SharedModels

final class RegisterFlowUnitTests: XCTestCase {
    var registrationViewModel: SteppedRegistrationViewModel!
    var mockServiceProvider: ServicesProviderClient?
    var mockEnvelopUpdater: UserRegisterEnvelopUpdater!
    
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        
        let servicesProviderConfiguration = ServicesProviderConfiguration(environment: .staging)
        
        let client = ServicesProviderClient(providerType: .sportradar, configuration: servicesProviderConfiguration)
        
        client.connect()
        
        self.mockServiceProvider = client
        
        let userRegisterEnvelop = UserRegisterEnvelop()
        
        self.mockEnvelopUpdater = UserRegisterEnvelopUpdater(userRegisterEnvelop: userRegisterEnvelop)
        
        if let mockServiceProvider {
            self.registrationViewModel = SteppedRegistrationViewModel(
                userRegisterEnvelop: userRegisterEnvelop,
                serviceProvider: mockServiceProvider,
                userRegisterEnvelopUpdater: mockEnvelopUpdater,
                registerFlowType: .betson
            )
        }
    }

    // MARK: - Navigation Tests
    
    func testStepNavigation() {
        XCTAssertEqual(registrationViewModel.currentStep.value, 0)
        
        registrationViewModel.scrollToNextStep()
        XCTAssertEqual(registrationViewModel.currentStep.value, 1)
        
        registrationViewModel.scrollToPreviousStep()
        XCTAssertEqual(registrationViewModel.currentStep.value, 0)
        
        // Test bounds
        registrationViewModel.scrollToIndex(-1)
        XCTAssertEqual(registrationViewModel.currentStep.value, 0)
        
        registrationViewModel.scrollToIndex(registrationViewModel.numberOfSteps)
        XCTAssertEqual(registrationViewModel.currentStep.value, registrationViewModel.numberOfSteps)
    }
    
    func testProgressPercentage() {
        let progressExpectation = expectation(description: "Progress updates")
        var progressValues: [Float] = []
        
        registrationViewModel.progressPercentage
            .sink { progress in
                progressValues.append(progress)
                if progressValues.count == 2 {
                    progressExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        XCTAssertEqual(progressValues.first, 0.0)
        registrationViewModel.scrollToNextStep()
        
        wait(for: [progressExpectation], timeout: 5.0)
        XCTAssertGreaterThan(progressValues[1], progressValues[0])
    }

    // MARK: - Phone Number Tests
    
    func testPhoneNumberValidation() {
        let phoneExpectation = expectation(description: "Phone validation")
        
        mockEnvelopUpdater.fullPhoneNumberPublisher
            .sink { fullNumber in
                XCTAssertEqual(fullNumber, "+33612345678")
                phoneExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        let country = SharedModels.Country(name: "France", region: "", iso2Code: "FR", iso3Code: "fr", numericCode: "", phonePrefix: "+33", frenchName: "France")

        mockEnvelopUpdater.setPhonePrefixCountry(country)
        mockEnvelopUpdater.setPhoneNumber("612345678")
        
        wait(for: [phoneExpectation], timeout: 5.0)
    }
    
    func testPhoneNumberFormatting() {
        let phoneExpectation = expectation(description: "Phone formatting")
        
        mockEnvelopUpdater.fullPhoneNumberPublisher
            .sink { fullNumber in
                // Should remove spaces and leading zeros
                XCTAssertEqual(fullNumber, "+33612345678")
                phoneExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        let country = SharedModels.Country(name: "France", region: "", iso2Code: "FR", iso3Code: "fr", numericCode: "", phonePrefix: "+33", frenchName: "France")
        
        mockEnvelopUpdater.setPhonePrefixCountry(country)
        mockEnvelopUpdater.setPhoneNumber("0612 34 56 78")
        
        wait(for: [phoneExpectation], timeout: 5.0)
    }

    // MARK: - Registration Flow Tests
    
    func testRegistration() {
        let registrationExpectation = expectation(description: "Registration completes")
        
        // Fill all required fields for a valid form
        mockEnvelopUpdater.setGender(.male)
        mockEnvelopUpdater.setName("Andre")
        mockEnvelopUpdater.setSurname("Lascas")
        mockEnvelopUpdater.setNickname("alascas0002")
        mockEnvelopUpdater.setAvatarName("avatar1")
        
        // Set date of birth (must be over 18)
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -20, to: Date())!
        mockEnvelopUpdater.setDateOfBirth(birthDate)
        
        // Set country and address info
        mockEnvelopUpdater.setCountryBirth(SharedModels.Country(name: "Portugal", region: "PT", iso2Code: "PT", iso3Code: "pt", numericCode: "", phonePrefix: "+351", frenchName: "Portugal"))
        mockEnvelopUpdater.setPlaceAddress("Rua Principal")
        mockEnvelopUpdater.setStreetNumber("123")
        mockEnvelopUpdater.setPostcode("1234-567")
        mockEnvelopUpdater.setStreetAddress("Rua Principal")
        mockEnvelopUpdater.setPlaceBirth("Brinches")
        mockEnvelopUpdater.setDepartmentOfBirth("08")
        
        // Set contact info
        mockEnvelopUpdater.setEmail("andrelascas0002@hotmail.com")
        mockEnvelopUpdater.setPhonePrefixCountry(SharedModels.Country(name: "Portugal", region: "PT", iso2Code: "PT", iso3Code: "pt", numericCode: "", phonePrefix: "+351", frenchName: "Portugal"))
        mockEnvelopUpdater.setPhoneNumber("962333444")
        
        // Set password
        mockEnvelopUpdater.setPassword("Slayer08&")
        
        // Set required consents
        mockEnvelopUpdater.setAcceptedTerms(true)
        
        registrationViewModel.userRegisterEnvelop = mockEnvelopUpdater.getUserRegisterEnvelop()
        
        XCTAssertTrue(registrationViewModel.requestRegister())
        
        registrationViewModel.shouldPushSuccessStep
            .sink { _ in
                registrationExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [registrationExpectation], timeout: 5.0)
    }
    
    func testRegistrationWithErrors() {
        let errorExpectation = expectation(description: "Registration errors")
        
        // Fill all required fields for a valid form
        mockEnvelopUpdater.setGender(.male)
        mockEnvelopUpdater.setName("Andre")
        mockEnvelopUpdater.setSurname("Lascas")
        mockEnvelopUpdater.setNickname("alascas8")
        mockEnvelopUpdater.setAvatarName("avatar1")
        
        // Set date of birth (must be over 18)
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .year, value: -20, to: Date())!
        mockEnvelopUpdater.setDateOfBirth(birthDate)
        
        // Set country and address info
        mockEnvelopUpdater.setCountryBirth(SharedModels.Country(name: "Portugal", region: "PT", iso2Code: "PT", iso3Code: "pt", numericCode: "", phonePrefix: "+351", frenchName: "Portugal"))
        mockEnvelopUpdater.setPlaceAddress("Rua Principal")
        mockEnvelopUpdater.setStreetNumber("123")
        mockEnvelopUpdater.setPostcode("1234-567")
        mockEnvelopUpdater.setStreetAddress("Rua Principal")
        mockEnvelopUpdater.setPlaceBirth("Brinches")
        mockEnvelopUpdater.setDepartmentOfBirth("08")
        
        // Set contact info
        mockEnvelopUpdater.setEmail("andrelascas@hotmail.com")
        mockEnvelopUpdater.setPhonePrefixCountry(SharedModels.Country(name: "Portugal", region: "PT", iso2Code: "PT", iso3Code: "pt", numericCode: "", phonePrefix: "+351", frenchName: "Portugal"))
        mockEnvelopUpdater.setPhoneNumber("912345678")
        
        // Set password
        mockEnvelopUpdater.setPassword("Slayer08&")
        
        // Set required consents
        mockEnvelopUpdater.setAcceptedTerms(true)
        
        registrationViewModel.userRegisterEnvelop = mockEnvelopUpdater.getUserRegisterEnvelop()
                
        XCTAssertTrue(registrationViewModel.requestRegister())
        
        registrationViewModel.showRegisterErrors
            .sink { errors in
                if let errors = errors {
                    XCTAssertEqual(errors.first?.field, "email")
                    XCTAssertEqual(errors.first?.error, "DUPLICATE")
                    errorExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [errorExpectation], timeout: 5.0)
    }
    
    // MARK: - Data Persistence Tests
    func testDataPersistenceBetweenSteps() {
        mockEnvelopUpdater.setName("John")
        mockEnvelopUpdater.setSurname("Doe")
        
        registrationViewModel.scrollToNextStep()
        
        registrationViewModel.userRegisterEnvelop = mockEnvelopUpdater.getUserRegisterEnvelop()
        
        XCTAssertEqual(registrationViewModel.userRegisterEnvelop.name, "John")
        XCTAssertEqual(registrationViewModel.userRegisterEnvelop.surname, "Doe")
        
        mockEnvelopUpdater.setNickname("johndoe")
        registrationViewModel.scrollToNextStep()
        
        registrationViewModel.userRegisterEnvelop = mockEnvelopUpdater.getUserRegisterEnvelop()
        
        XCTAssertEqual(registrationViewModel.userRegisterEnvelop.nickname, "johndoe")
    }
    
    func testUserDefaultsPersistence() {
        mockEnvelopUpdater.setName("John")
        mockEnvelopUpdater.setSurname("Doe")
        
        registrationViewModel.userRegisterEnvelop = mockEnvelopUpdater.getUserRegisterEnvelop()
        
        UserDefaults.standard.startedUserRegisterInfo = registrationViewModel.userRegisterEnvelop
        
        let savedEnvelop = UserDefaults.standard.startedUserRegisterInfo
        XCTAssertNotNil(savedEnvelop)
        XCTAssertEqual(savedEnvelop?.name, "John")
        XCTAssertEqual(savedEnvelop?.surname, "Doe")
    }

    // MARK: - Nickname Generation Tests
    
    func testNicknameGeneration() {
        let nicknameExpectation = expectation(description: "Nickname generates")
        
        mockEnvelopUpdater.generatedNickname
            .sink { nickname in
                XCTAssertEqual(nickname, "jdoe")
                nicknameExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        mockEnvelopUpdater.setName("John")
        mockEnvelopUpdater.setSurname("Doe")
        
        wait(for: [nicknameExpectation], timeout: 5.0)
    }
    
    func testNicknameGenerationWithSpecialCharacters() {
        let nicknameExpectation = expectation(description: "Nickname generates with special chars")
        
        mockEnvelopUpdater.generatedNickname
            .sink { nickname in
                XCTAssertEqual(nickname, "jo'reilly")
                nicknameExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        mockEnvelopUpdater.setName("John")
        mockEnvelopUpdater.setSurname("O'Reilly")
        
        wait(for: [nicknameExpectation], timeout: 5.0)
    }
    
}

extension UserDefaults {
    private enum Keys {
        static let startedUserRegisterInfo = "started_user_register_info"
    }
    
    var startedUserRegisterInfo: UserRegisterEnvelop? {
        get {
            guard let data = self.data(forKey: Keys.startedUserRegisterInfo) else { return nil }
            return try? JSONDecoder().decode(UserRegisterEnvelop.self, from: data)
        }
        set {
            guard let newValue = newValue,
                  let data = try? JSONEncoder().encode(newValue) else {
                self.removeObject(forKey: Keys.startedUserRegisterInfo)
                return
            }
            self.set(data, forKey: Keys.startedUserRegisterInfo)
        }
    }
}
