//
//  TransactionsService.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 12.06.2025.
//

import Foundation

@Observable
final class TransactionsService {
    private var mockTransactions = [
        Transaction(id: 1, accountId: "g5ldpb73", categoryId: "1111", amount: Decimal(string: "-1000000.33") ?? 500, comment: nil, timestamp: Date(), hidden: false),
        Transaction(id: 2, accountId: "g5ldpb73", categoryId: "1112", amount: Decimal(string: "-15000.33") ?? 500, comment: "Энни", timestamp: Date()+1, hidden: false),
        Transaction(id: 3, accountId: "g5ldpb73", categoryId: "2222", amount: Decimal(string: "15004.33") ?? 500, comment: "Джон", timestamp: Date()+2, hidden: false),
        Transaction(id: 4, accountId: "g5ldpb73", categoryId: "2223", amount: Decimal(string: "11002.33") ?? 500, comment: "Энни", timestamp: Date()+3, hidden: false),
        Transaction(id: 5, accountId: "g5ldpb73", categoryId: "1111", amount: Decimal(string: "-999999") ?? 500, comment: "тест", timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, hidden: false),
        Transaction(id: 6, accountId: "g5ldpb73", categoryId: "2222", amount: Decimal(string: "999999") ?? 500, comment: "тест", timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, hidden: false),
        //Transaction(...),
        //Transaction(...),
    ]

    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        return mockTransactions.filter {
            startDate <= $0.timestamp && $0.timestamp <= endDate
        }
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        mockTransactions.append(transaction)
    }
    
    func editTransaction(_ newTransaction: Transaction) async throws {
        if let index = mockTransactions.firstIndex(where: { $0.id == newTransaction.id }) {
            mockTransactions[index] = newTransaction
        } else {
            throw Error.notFound
        }
    }
    
    func removeTransaction(withId id: Int) async throws {
        mockTransactions.removeAll { $0.id == id }
    }
}

extension TransactionsService {
    private enum Error: Swift.Error {
        case notFound
        case duplicate
        case invalidData
    }
}
