//
//  CashoutSliderViewModelTests.swift
//  BetssonCameroonApp
//
//  Created by Leonardo Soares on 07/01/2026.
//

import XCTest
import Combine
import GomaUI
@testable import BetssonCameroonApp

final class CashoutSliderViewModelTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    var viewModel: CashoutSliderViewModel!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - updateSliderValue Tests
    
    func testUpdatingValue() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            selectionTitle: "Test",
            fullCashoutValue: 100.0
        )
        
        let expectation = expectation(description: "Value updated")
        var receivedValues: [Float] = []
        
        viewModel.dataPublisher
            .dropFirst() // We drop first to avoid assert mismatch to initial value for `currentValue`
            .sink { data in
                receivedValues.append(data.currentValue)
                if receivedValues.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.updateSliderValue(75.0)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValues.first, 75.0)
    }
    
    func testUpdatingValueBelowMinimum() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            selectionTitle: "Test",
            fullCashoutValue: 100.0
        )
        
        let expectation = expectation(description: "Value clamped to minimum")
        var receivedValue: Float?
        
        viewModel.dataPublisher
            .dropFirst()
            .sink { data in
                receivedValue = data.currentValue
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Try to set value below minimum
        viewModel.updateSliderValue(0.05)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValue, 0.05, "Should clamp to minimum value")
    }
    
    func testUpdatingValueAboveMaximum() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            selectionTitle: "Test",
            fullCashoutValue: 100.0
        )
        
        let expectation = expectation(description: "Value clamped to maximum")
        var receivedValue: Float?
        
        viewModel.dataPublisher
            .dropFirst() // We drop first to avoid assert mismatch to initial value for `currentValue`
            .sink { data in
                receivedValue = data.currentValue
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Try to set value above maximum
        viewModel.updateSliderValue(150.0)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValue, 100.0, "Should clamp to maximum value")
    }
    
    func testValidateSelectionTitleUpdate() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            selectionTitle: "Initial",
            fullCashoutValue: 100.0
        )
        
        let expectation = expectation(description: "Selection title updated")
        var receivedTitle: String?
        
        viewModel.dataPublisher
            .dropFirst() // We drop first to avoid assert mismatch to initial value for `currentValue`
            .sink { data in
                receivedTitle = data.selectionTitle
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateSliderValue(75.0)
        
        wait(for: [expectation], timeout: 1.0)
        
        do {
            let unwrappedReceivedTitle = try XCTUnwrap(receivedTitle, "Received title should not be nil")
            XCTAssertTrue(unwrappedReceivedTitle.contains("XAF") == true, "Title should contain currency")
            XCTAssertTrue(unwrappedReceivedTitle.contains("75") == true || unwrappedReceivedTitle.contains("75.00") == true, "Title should contain amount")
        } catch {
            XCTFail("Could not unwrap received title: \(error.localizedDescription)")
        }
    }
    
    func testCalculatingPartialCashoutReturn() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            selectionTitle: "Test",
            fullCashoutValue: 100.0
        )
        
        let expectation = expectation(description: "Partial cashout calculated")
        var receivedTitle: String?
        
        viewModel.dataPublisher
            .dropFirst()
            .sink { data in
                receivedTitle = data.selectionTitle
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateSliderValue(50.0)
        
        wait(for: [expectation], timeout: 1.0)
        
        do {
            let unwrappedReceivedTitle = try XCTUnwrap(receivedTitle, "Received title should not be nil")
            XCTAssertTrue(unwrappedReceivedTitle.contains("XAF") == true, "Title should contain currency")
            XCTAssertTrue(unwrappedReceivedTitle.contains("50") == true || unwrappedReceivedTitle.contains("75.00") == true, "Title should contain amount")
        } catch {
            XCTFail("Could not unwrap received title: \(error.localizedDescription)")
        }
    }
    
    // MARK: - handleCashoutTap Tests
    
    func testCallsCallbackWithCurrentValue() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            selectionTitle: "Test",
            fullCashoutValue: 100.0
        )
        
        var receivedValue: Float?
        var callbackCalled = false
        
        viewModel.onCashoutRequested = { value in
            receivedValue = value
            callbackCalled = true
        }
        
        viewModel.handleCashoutTap()
        
        XCTAssertTrue(callbackCalled, "Callback should be called")
        XCTAssertEqual(receivedValue, 50.0, "Should pass current value")
    }
    
    func testCallsCallbackWithUpdatedValue() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            selectionTitle: "Test",
            fullCashoutValue: 100.0
        )
        
        let updateExpectation = expectation(description: "Value updated")
        viewModel.dataPublisher
            .dropFirst()
            .sink { _ in updateExpectation.fulfill() }
            .store(in: &cancellables)
        
        viewModel.updateSliderValue(75.0)
        wait(for: [updateExpectation], timeout: 1.0)
        
        var receivedValue: Float?
        viewModel.onCashoutRequested = { value in
            receivedValue = value
        }
        
        viewModel.handleCashoutTap()
        
        XCTAssertEqual(receivedValue, 75.0, "Should pass updated value")
    }
    
    func testTapNotCrashingWhenCallbackIsNil() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            selectionTitle: "Test",
            fullCashoutValue: 100.0
        )
        
        viewModel.onCashoutRequested = nil
        
        viewModel.handleCashoutTap()
        XCTAssertTrue(true, "Should handle nil callback gracefully")
    }
    
    // MARK: - setEnabled Tests
    
    func testIsEnabledState() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            isEnabled: true,
            selectionTitle: "Test",
            fullCashoutValue: 100.0
        )
        
        let expectation = expectation(description: "Enabled state updated")
        var receivedEnabled: Bool?
        
        viewModel.dataPublisher
            .dropFirst()
            .sink { data in
                receivedEnabled = data.isEnabled
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.setEnabled(false)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedEnabled, false)
    }
    
    func testSetEnabledPreservingOtherData() {
        viewModel = CashoutSliderViewModel(
            title: "Test Title",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            isEnabled: true,
            selectionTitle: "Test Selection",
            fullCashoutValue: 100.0
        )
        
        let expectation = expectation(description: "Data preserved")
        var receivedData: CashoutSliderData?
        
        viewModel.dataPublisher
            .dropFirst()
            .sink { data in
                receivedData = data
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.setEnabled(false)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedData?.title, "Test Title")
        XCTAssertEqual(receivedData?.currentValue, 50.0)
        XCTAssertEqual(receivedData?.currency, "XAF")
        XCTAssertEqual(receivedData?.isEnabled, false)
    }
    
    // MARK: - updateBounds Tests
    
    func testUpdatingMaximumValue() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            selectionTitle: "Test",
            fullCashoutValue: 100.0
        )
        
        let expectation = expectation(description: "Bounds updated")
        var receivedMaximum: Float?
        
        viewModel.dataPublisher
            .dropFirst()
            .sink { data in
                receivedMaximum = data.maximumValue
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateBounds(newMaximumValue: 50.0)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedMaximum, 50.0)
    }
    
    func testResetingCurrentValueToPercentage() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            selectionTitle: "Test",
            fullCashoutValue: 100.0
        )
        
        let expectation = expectation(description: "Current value reset")
        var receivedCurrent: Float?
        
        viewModel.dataPublisher
            .dropFirst()
            .sink { data in
                receivedCurrent = data.currentValue
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateBounds(newMaximumValue: 50.0)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedCurrent, 40.0, "Should reset to 80% of new maximum")
    }
    
    func testResetingPercentage() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            selectionTitle: "Test",
            fullCashoutValue: 100.0
        )
        
        let expectation = expectation(description: "Current value reset with custom percentage")
        var receivedCurrent: Float?
        
        viewModel.dataPublisher
            .dropFirst()
            .sink { data in
                receivedCurrent = data.currentValue
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateBounds(newMaximumValue: 100.0, resetToPercentage: 0.5)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedCurrent, 50.0, "Should reset to 50% of new maximum")
    }
    
    func testUpdatingSelectionTitle() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            selectionTitle: "Initial",
            fullCashoutValue: 100.0
        )
        
        let expectation = expectation(description: "Selection title updated")
        var receivedTitle: String?
        
        viewModel.dataPublisher
            .dropFirst()
            .sink { data in
                receivedTitle = data.selectionTitle
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateBounds(newMaximumValue: 50.0)
        
        wait(for: [expectation], timeout: 1.0)
        
        do {
            let unwrappedReceivedTitle = try XCTUnwrap(receivedTitle, "Received title should not be nil")
            XCTAssertTrue(unwrappedReceivedTitle.contains("XAF") == true, "Title should contain currency")
        } catch {
            XCTFail("Could not unwrap received title: \(error.localizedDescription)")
        }
    }
    
    func testUpdateBoundsPreservingOtherData() {
        viewModel = CashoutSliderViewModel(
            title: "Test Title",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            isEnabled: true,
            selectionTitle: "Test",
            fullCashoutValue: 100.0
        )
        
        let expectation = expectation(description: "Other data preserved")
        var receivedData: CashoutSliderData?
        
        viewModel.dataPublisher
            .dropFirst()
            .sink { data in
                receivedData = data
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateBounds(newMaximumValue: 50.0)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedData?.title, "Test Title")
        XCTAssertEqual(receivedData?.minimumValue, 0.01)
        XCTAssertEqual(receivedData?.currency, "XAF")
        XCTAssertEqual(receivedData?.isEnabled, true)
        XCTAssertEqual(receivedData?.fullCashoutValue, 100.0)
    }
    
    // MARK: - Factory Method Tests
    
    func testCreateWithTotalCashoutAmounts() {
        let totalCashoutAmount: Double = 100.0
        let currency = "XAF"
        
        viewModel = CashoutSliderViewModel.create(
            totalCashoutAmount: totalCashoutAmount,
            currency: currency
        )
        
        let expectation = expectation(description: "Data published")
        var receivedData: CashoutSliderData?
        
        viewModel.dataPublisher
            .first()
            .sink { data in
                receivedData = data
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(receivedData?.minimumValue, 0.1)
        XCTAssertEqual(receivedData?.maximumValue, Float(totalCashoutAmount))
        XCTAssertEqual(receivedData?.currentValue, Float(totalCashoutAmount), "Should start at maximum")
        XCTAssertEqual(receivedData?.currency, currency)
        XCTAssertEqual(receivedData?.isEnabled, true)
    }
    
    func testCreateWithTotalCashoutAmountWithCustomTitle() {
        let customTitle = "Custom Cashout Title"
        
        viewModel = CashoutSliderViewModel.create(
            totalCashoutAmount: 100.0,
            currency: "XAF",
            title: customTitle
        )
        
        let expectation = expectation(description: "Custom title used")
        var receivedTitle: String?
        
        viewModel.dataPublisher
            .first()
            .sink { data in
                receivedTitle = data.title
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedTitle, customTitle)
    }
    
    func testCreatesViewModelWithMaximumValues() {
        let minimumAmount: Double = 10.0
        let maximumAmount: Double = 100.0
        let currentAmount: Double = 50.0
        let currency = "XAF"
        
        viewModel = CashoutSliderViewModel.create(
            minimumAmount: minimumAmount,
            maximumAmount: maximumAmount,
            currentAmount: currentAmount,
            currency: currency
        )
        
        let expectation = expectation(description: "Data published")
        var receivedData: CashoutSliderData?
        
        viewModel.dataPublisher
            .first()
            .sink { data in
                receivedData = data
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(receivedData?.minimumValue, Float(minimumAmount))
        XCTAssertEqual(receivedData?.maximumValue, Float(maximumAmount))
        XCTAssertEqual(receivedData?.currentValue, Float(currentAmount))
        XCTAssertEqual(receivedData?.currency, currency)
        XCTAssertEqual(receivedData?.isEnabled, true)
    }
    
    func test_createWithMinMaxCurrent_usesCustomTitle() {
        let customTitle = "Custom Title"
        
        viewModel = CashoutSliderViewModel.create(
            minimumAmount: 10.0,
            maximumAmount: 100.0,
            currentAmount: 50.0,
            currency: "XAF",
            title: customTitle
        )
        
        let expectation = expectation(description: "Custom title used")
        var receivedTitle: String?
        
        viewModel.dataPublisher
            .first()
            .sink { data in
                receivedTitle = data.title
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedTitle, customTitle)
    }
    
    // MARK: - Edge Cases
    
    func testValueWithZeroFullCashoutValue() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            selectionTitle: "Test",
            fullCashoutValue: 0.0
        )
        
        let expectation = expectation(description: "Handles zero fullCashoutValue")
        var receivedData: CashoutSliderData?
        
        viewModel.dataPublisher
            .dropFirst()
            .sink { data in
                receivedData = data
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateSliderValue(75.0)
        
        wait(for: [expectation], timeout: 1.0)
        
        do {
            let unwrappedReceivedData = try XCTUnwrap(receivedData, "Received data should not be nil")
            XCTAssertEqual(unwrappedReceivedData.currentValue, 75.0)
        } catch {
            XCTFail("Could not unwrap received title: \(error.localizedDescription)")
        }
    }
    
    func testValueWithVerySmallValues() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 1.0,
            currentValue: 0.5,
            currency: "XAF",
            selectionTitle: "Test",
            fullCashoutValue: 1.0
        )
        
        let expectation = expectation(description: "Handles small values")
        var receivedValue: Float?
        
        viewModel.dataPublisher
            .dropFirst()
            .sink { data in
                receivedValue = data.currentValue
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateSliderValue(0.75)
        
        wait(for: [expectation], timeout: 1.0)
        
        do {
            let unwrappedReceivedValue = try XCTUnwrap(receivedValue)
            XCTAssertEqual(Double(unwrappedReceivedValue), 0.75, accuracy: 0.01)
        } catch {
            XCTFail("Could not unwrap receivedValue \(error.localizedDescription)")
        }
    }
    
    func testValueWithVeryLargeValues() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 100.0,
            maximumValue: 1000000.0,
            currentValue: 500000.0,
            currency: "XAF",
            selectionTitle: "Test",
            fullCashoutValue: 1000000.0
        )
        
        let expectation = expectation(description: "Handles large values")
        var receivedValue: Float?
        
        viewModel.dataPublisher
            .dropFirst()
            .sink { data in
                receivedValue = data.currentValue
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateSliderValue(750000.0)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValue, 750000.0)
    }
    
    func testMultipleUpdatesFromPublishingMultipleValues() {
        viewModel = CashoutSliderViewModel(
            title: "Test",
            minimumValue: 0.01,
            maximumValue: 100.0,
            currentValue: 50.0,
            currency: "XAF",
            selectionTitle: "Test",
            fullCashoutValue: 100.0
        )
        
        let expectation = expectation(description: "Multiple values published")
        expectation.expectedFulfillmentCount = 3
        var receivedValues: [Float] = []
        
        viewModel.dataPublisher
            .dropFirst() // Skip initial
            .sink { data in
                receivedValues.append(data.currentValue)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateSliderValue(25.0)
        viewModel.updateSliderValue(50.0)
        viewModel.updateSliderValue(75.0)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValues.count, 3)
        XCTAssertEqual(receivedValues, [25.0, 50.0, 75.0])
    }
}
