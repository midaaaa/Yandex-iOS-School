//
//  TransactionJSONTests.swift
//  Finance Tamer Tests
//
//  Created by Дмитрий Филимонов on 13.06.2025.
//

import XCTest
@testable import Finance_Tamer

final class TransactionJSONTests: XCTestCase {
    // MARK: - Test Data
    
    private var validTransactionJSON: [String: Any] {
        return [
            "id": 1,
            "accountId": "101",
            "categoryId": "201",
            "amount": "15000.33",
            "comment": "Test transaction",
            "timestamp": Date().timeIntervalSince1970,
            "hidden": false
        ]
    }
    
    // MARK: - parse(jsonObject:) Tests
    
    func testParseValidJSON() {
        let json = validTransactionJSON
        let transaction = Transaction.parse(jsonObject: json)
        
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction?.id, 1)
        XCTAssertEqual(transaction?.accountId, "101")
        XCTAssertEqual(transaction?.amount, Decimal(string: "15000.33"))
    }
    
    func testParseMissingRequiredField() {
        var invalidJSON = validTransactionJSON
        invalidJSON.removeValue(forKey: "id")
        let transaction = Transaction.parse(jsonObject: invalidJSON)
        
        XCTAssertNil(transaction)
    }
    
    func testParseInvalidAmountFormat() {
        var invalidJSON = validTransactionJSON
        invalidJSON["amount"] = "not_a_number"
        let transaction = Transaction.parse(jsonObject: invalidJSON)
        
        XCTAssertNil(transaction)
    }
    
    func testParseWithNonDictionaryObject() {
        let invalidJSON = ["invalid", "data"] as [Any]
        let transaction = Transaction.parse(jsonObject: invalidJSON)
        
        XCTAssertNil(transaction)
    }
    
    // MARK: - jsonObject Tests
    
    func testJsonObjectConversion() {
        let originalTransaction = Transaction(
            id: 2,
            accountId: "102",
            categoryId: "202",
            amount: Decimal(string: "15000.33") ?? 15000,
            comment: "Test conversion",
            timestamp: Date(),
            hidden: true
        )

        let jsonObject = originalTransaction.jsonObject
        let parsedTransaction = Transaction.parse(jsonObject: jsonObject)
        
        XCTAssertNotNil(parsedTransaction)
        XCTAssertEqual(parsedTransaction?.id, originalTransaction.id)
        XCTAssertEqual(parsedTransaction?.accountId, originalTransaction.accountId)
        XCTAssertEqual(parsedTransaction?.amount, originalTransaction.amount)
    }
    
    func testJsonObjectWithNilValues() {
        let transaction = Transaction(
            id: 3,
            accountId: nil,
            categoryId: nil,
            amount: Decimal(string: "100") ?? 100,
            comment: nil,
            timestamp: Date(),
            hidden: false
        )
        
        let jsonObject = transaction.jsonObject
        let parsedTransaction = Transaction.parse(jsonObject: jsonObject)
        
        XCTAssertNotNil(parsedTransaction)
        XCTAssertNil(parsedTransaction?.accountId)
        XCTAssertNil(parsedTransaction?.comment)
    }
}
