import XCTest
import Combine
@testable import AdresseFrancaise

class AdresseFrancaiseClientTests: XCTestCase {

    private let client = AdresseFrancaiseClient()

    func testSearchCommune() {
        let exp = expectation(description: "Waiting for the API response")
        let cancellable = client.searchCommune(query: "paris")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Error: \(error)")
                case .finished:
                    break
                }
                exp.fulfill()
            }, receiveValue: { addressResults in
                XCTAssertFalse(addressResults.isEmpty)
            })
        wait(for: [exp], timeout: 5.0)
        cancellable.cancel()
    }

    func testSearchStreet() {
        let exp = expectation(description: "Waiting for the API response")
        let cancellable = client.searchStreet(query: "avenue des champs")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Error: \(error)")
                case .finished:
                    break
                }
                exp.fulfill()
            }, receiveValue: { addressResults in
                XCTAssertFalse(addressResults.isEmpty)
            })
        wait(for: [exp], timeout: 5.0)
        cancellable.cancel()
    }

    func testSearchCommuneError() {
        let exp = expectation(description: "Waiting for the API response")
        let cancellable = client.searchCommune(query: "")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(error, AdresseFrancaiseError.shortQuery)
                case .finished:
                    XCTFail("Search should have failed.")
                }
                exp.fulfill()
            }, receiveValue: { _ in
                XCTFail("Search should have failed.")
            })
        wait(for: [exp], timeout: 5.0)
        cancellable.cancel()
    }

    func testSearchCommuneShortError() {
        let exp = expectation(description: "Waiting for the API response")
        let cancellable = client.searchCommune(query: "Pa")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(error, AdresseFrancaiseError.shortQuery)
                case .finished:
                    XCTFail("Search should have failed.")
                }
                exp.fulfill()
            }, receiveValue: { _ in
                XCTFail("Search should have failed.")
            })
        wait(for: [exp], timeout: 5.0)
        cancellable.cancel()
    }

}
