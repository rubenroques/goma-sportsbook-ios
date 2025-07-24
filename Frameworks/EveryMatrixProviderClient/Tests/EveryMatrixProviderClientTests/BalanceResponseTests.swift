import XCTest
@testable import EveryMatrixProviderClient

class BalanceResponseTests: XCTestCase {

    // Sample JSON based on the curl response
    let sampleJson = """
    {
        "totalAmount": {"EUR": 123.45},
        "totalCashAmount": {"EUR": 100.00},
        "totalWithdrawableAmount": {"EUR": 95.50},
        "totalRealAmount": {"EUR": 100.00},
        "totalBonusAmount": {"EUR": 23.45},
        "items": [
            {
                "type": "Real",
                "amount": 100.00,
                "currency": "EUR",
                "productType": null,
                "sessionTimestamp": null,
                "walletAccountType": "Ordinary",
                "sessionId": null,
                "creditLine": null
            },
            {
                "type": "Bonus",
                "amount": 23.45,
                "currency": "EUR",
                "productType": "CasinoBonus",
                "sessionTimestamp": "2023-10-27T10:00:00Z",
                "walletAccountType": "Bonus",
                "sessionId": "session-abc",
                "creditLine": 5.0
            }
        ]
    }
    """

    func testBalanceResponseDecoding() {
        let data = sampleJson.data(using: .utf8)!
        let decoder = JSONDecoder()

        do {
            let response = try decoder.decode(BalanceResponse.self, from: data)

            // Verify totals
            XCTAssertEqual(response.totalAmount, ["EUR": 123.45])
            XCTAssertEqual(response.totalCashAmount, ["EUR": 100.00])
            XCTAssertEqual(response.totalWithdrawableAmount, ["EUR": 95.50])
            XCTAssertEqual(response.totalRealAmount, ["EUR": 100.00])
            XCTAssertEqual(response.totalBonusAmount, ["EUR": 23.45])

            // Verify items count
            XCTAssertEqual(response.items.count, 2)

            // Verify first item
            let item1 = response.items[0]
            XCTAssertEqual(item1.type, "Real")
            XCTAssertEqual(item1.amount, 100.00)
            XCTAssertEqual(item1.currency, "EUR")
            XCTAssertNil(item1.productType)
            XCTAssertNil(item1.sessionTimestamp)
            XCTAssertEqual(item1.walletAccountType, "Ordinary")
            XCTAssertNil(item1.sessionId)
            XCTAssertNil(item1.creditLine)

            // Verify second item
            let item2 = response.items[1]
            XCTAssertEqual(item2.type, "Bonus")
            XCTAssertEqual(item2.amount, 23.45)
            XCTAssertEqual(item2.currency, "EUR")
            XCTAssertEqual(item2.productType, "CasinoBonus")
            XCTAssertEqual(item2.sessionTimestamp, "2023-10-27T10:00:00Z")
            XCTAssertEqual(item2.walletAccountType, "Bonus")
            XCTAssertEqual(item2.sessionId, "session-abc")
            XCTAssertEqual(item2.creditLine, 5.0)

        } catch {
            XCTFail("Failed to decode BalanceResponse: \(error)")
        }
    }

    func testBalanceResponseEncoding() {
        // Create a BalanceResponse instance
        let item1 = BalanceItem(type: "Real", amount: 50.0, currency: "USD", productType: nil, sessionTimestamp: nil, walletAccountType: "Ord", sessionId: nil, creditLine: nil)
        let item2 = BalanceItem(type: "Bonus", amount: 10.0, currency: "USD", productType: "PB", sessionTimestamp: "ts", walletAccountType: "Bon", sessionId: "sid", creditLine: 1.0)
        let response = BalanceResponse(
            totalAmount: ["USD": 60.0],
            totalCashAmount: ["USD": 50.0],
            totalWithdrawableAmount: ["USD": 45.0],
            totalRealAmount: ["USD": 50.0],
            totalBonusAmount: ["USD": 10.0],
            items: [item1, item2]
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys // Ensure consistent order for comparison

        do {
            let data = try encoder.encode(response)
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(BalanceResponse.self, from: data)

            // Verify the decoded response matches the original
            XCTAssertEqual(decodedResponse, response)

        } catch {
            XCTFail("Failed to encode or decode BalanceResponse: \(error)")
        }
    }

    func testBalanceItemEquality() {
        let item1 = BalanceItem(type: "A", amount: 1, currency: "C", productType: "P", sessionTimestamp: "T", walletAccountType: "W", sessionId: "S", creditLine: 1.0)
        let item2 = BalanceItem(type: "A", amount: 1, currency: "C", productType: "P", sessionTimestamp: "T", walletAccountType: "W", sessionId: "S", creditLine: 1.0)
        let item3 = BalanceItem(type: "B", amount: 2, currency: nil, productType: nil, sessionTimestamp: nil, walletAccountType: nil, sessionId: nil, creditLine: nil)

        XCTAssertEqual(item1, item2)
        XCTAssertNotEqual(item1, item3)
    }

    func testBalanceResponseEquality() {
        let item1 = BalanceItem(type: "A", amount: 1, currency: "C", productType: nil, sessionTimestamp: nil, walletAccountType: nil, sessionId: nil, creditLine: nil)
        let item2 = BalanceItem(type: "B", amount: 2, currency: "D", productType: nil, sessionTimestamp: nil, walletAccountType: nil, sessionId: nil, creditLine: nil)

        let response1 = BalanceResponse(totalAmount: ["C":1], totalCashAmount: [:], totalWithdrawableAmount: [:], totalRealAmount: [:], totalBonusAmount: [:], items: [item1])
        let response2 = BalanceResponse(totalAmount: ["C":1], totalCashAmount: [:], totalWithdrawableAmount: [:], totalRealAmount: [:], totalBonusAmount: [:], items: [item1])
        let response3 = BalanceResponse(totalAmount: ["D":2], totalCashAmount: [:], totalWithdrawableAmount: [:], totalRealAmount: [:], totalBonusAmount: [:], items: [item2])

        XCTAssertEqual(response1, response2)
        XCTAssertNotEqual(response1, response3)
    }
}