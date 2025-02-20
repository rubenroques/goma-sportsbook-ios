//
//  RegisterFlowDataValidationTests.swift
//  SportsbookTests
//
//  Created by André Lascas on 20/02/2025.
//

import XCTest

//final class RegisterFlowDataValidationTests: XCTestCase {
//
//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
//}

import Foundation
import RegisterFlow
import ServicesProvider
import Combine
import XCTest
import SharedModels

class RegisterFlowDataValidationTests: XCTestCase {
    var sut: SteppedRegistrationViewModel!
    var mockServiceProvider: ServicesProviderClient!
    var mockEnvelopUpdater: UserRegisterEnvelopUpdater!
    
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockServiceProvider = ServicesProviderClient(providerType: .sportradar, configuration: ServicesProviderConfiguration(environment: .development))
        let userRegisterEnvelop = UserRegisterEnvelop()
        mockEnvelopUpdater = UserRegisterEnvelopUpdater(userRegisterEnvelop: userRegisterEnvelop)
        sut = SteppedRegistrationViewModel(
            userRegisterEnvelop: userRegisterEnvelop,
            serviceProvider: mockServiceProvider,
            userRegisterEnvelopUpdater: mockEnvelopUpdater,
            registerFlowType: .betson
        )
    }

    // MARK: - Navigation Tests
    
    func testStepNavigation() {
        XCTAssertEqual(sut.currentStep.value, 0)
        
        sut.scrollToNextStep()
        XCTAssertEqual(sut.currentStep.value, 1)
        
        sut.scrollToPreviousStep()
        XCTAssertEqual(sut.currentStep.value, 0)
        
        // Test bounds
        sut.scrollToIndex(-1)
        XCTAssertEqual(sut.currentStep.value, 0)
        
        sut.scrollToIndex(sut.numberOfSteps + 1)
        XCTAssertEqual(sut.currentStep.value, sut.numberOfSteps - 1)
    }
    
    func testProgressPercentage() {
        let progressExpectation = expectation(description: "Progress updates")
        var progressValues: [Float] = []
        
        sut.progressPercentage
            .sink { progress in
                progressValues.append(progress)
                if progressValues.count == 2 {
                    progressExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        XCTAssertEqual(progressValues.first, 0.0)
        sut.scrollToNextStep()
        
        wait(for: [progressExpectation], timeout: 1.0)
        XCTAssertGreaterThan(progressValues[1], progressValues[0])
    }

    // MARK: - Personal Information Validation Tests
    
    func testNameValidation() {
        let validationExpectation = expectation(description: "Name validation")
        
        // Test empty name
        mockEnvelopUpdater.setName("")
        
        // Test name with numbers
        mockEnvelopUpdater.setName("John123")
        
        // Test valid name
        mockEnvelopUpdater.setName("John Doe")
        
        // Test special characters
        mockEnvelopUpdater.setName("John-Doe O'Connor")
        
        // Test very long name
        let longName = String(repeating: "a", count: 101)
        mockEnvelopUpdater.setName(longName)
        
        mockEnvelopUpdater.didUpdateUserRegisterEnvelop
            .sink { envelop in
                validationExpectation.fulfill()
            }
            .store(in: &cancellables)
            
        wait(for: [validationExpectation], timeout: 1.0)
    }

    func testEmailValidation() {
        let validationExpectation = expectation(description: "Email validation")
        
        // Test various email formats
        let testEmails = [
            "",                     // empty
            "notanemail",          // invalid format
            "user@",               // missing domain
            "user@example.com",    // valid
            "user+test@example.com" // valid with special chars
        ]
        
        for email in testEmails {
            mockEnvelopUpdater.setEmail(email)
        }
        
        mockEnvelopUpdater.didUpdateUserRegisterEnvelop
            .sink { _ in
                validationExpectation.fulfill()
            }
            .store(in: &cancellables)
            
        wait(for: [validationExpectation], timeout: 1.0)
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
        
        wait(for: [phoneExpectation], timeout: 1.0)
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
        
        wait(for: [phoneExpectation], timeout: 1.0)
    }

    // MARK: - Registration Flow Tests
    
    func testRegistration() {
        let registrationExpectation = expectation(description: "Registration completes")
                
        // Fill required data
        mockEnvelopUpdater.setName("John")
        mockEnvelopUpdater.setSurname("Doe")
        mockEnvelopUpdater.setEmail("john@example.com")
        mockEnvelopUpdater.setPassword("Password123!")
        
        XCTAssertTrue(sut.requestRegister())
        
        sut.shouldPushSuccessStep
            .sink { _ in
                registrationExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [registrationExpectation], timeout: 1.0)
    }
    
    func testRegistrationWithErrors() {
        let errorExpectation = expectation(description: "Registration errors")
                
        mockEnvelopUpdater.setEmail("andrelascas@hotmail.com")
        mockEnvelopUpdater.setPassword("Slayer08&")
        
        XCTAssertTrue(sut.requestRegister())
        
        sut.showRegisterErrors
            .sink { errors in
                if let errors = errors {
                    XCTAssertEqual(errors.first?.field, "personalInfo")
                    XCTAssertEqual(errors.first?.error, "EMAIL_DUPLICATE")
                    errorExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [errorExpectation], timeout: 1.0)
    }

    // MARK: - Data Persistence Tests
    
    func testDataPersistenceBetweenSteps() {
        mockEnvelopUpdater.setName("John")
        mockEnvelopUpdater.setSurname("Doe")
        sut.scrollToNextStep()
        
        XCTAssertEqual(sut.userRegisterEnvelop.name, "John")
        XCTAssertEqual(sut.userRegisterEnvelop.surname, "Doe")
        
        mockEnvelopUpdater.setNickname("johndoe")
        sut.scrollToNextStep()
        
        XCTAssertEqual(sut.userRegisterEnvelop.nickname, "johndoe")
    }
    
    func testUserDefaultsPersistence() {
        mockEnvelopUpdater.setName("John")
        mockEnvelopUpdater.setSurname("Doe")
        
        UserDefaults.standard.startedUserRegisterInfo = sut.userRegisterEnvelop
        
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
        
        wait(for: [nicknameExpectation], timeout: 1.0)
    }
    
    func testNicknameGenerationWithSpecialCharacters() {
        let nicknameExpectation = expectation(description: "Nickname generates with special chars")
        
        mockEnvelopUpdater.generatedNickname
            .sink { nickname in
                XCTAssertEqual(nickname, "joreilly")
                nicknameExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        mockEnvelopUpdater.setName("John")
        mockEnvelopUpdater.setSurname("O'Reilly")
        
        wait(for: [nicknameExpectation], timeout: 1.0)
    }

    // MARK: - Consent Tests
    
    func testConsentHandling() {
        let consentExpectation = expectation(description: "Consent handling")
        
//        mockServiceProvider.getAllConsentsResponse = .success([
//            ConsentInfo(key: "terms", consentVersionId: 1),
//            ConsentInfo(key: "sms_promotions", consentVersionId: 2),
//            ConsentInfo(key: "email_promotions", consentVersionId: 3)
//        ])
        
        mockEnvelopUpdater.setAcceptedTerms(true)
        mockEnvelopUpdater.setAcceptedMarketing(true)
        
        XCTAssertTrue(sut.requestRegister())
        
        sut.shouldPushSuccessStep
            .sink { _ in
                consentExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [consentExpectation], timeout: 1.0)
    }
    
}
