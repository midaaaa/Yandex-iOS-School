//
//  TransactionsService.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 12.06.2025.
//

import Foundation

struct TransactionDTO: Codable {
    let id: Int
    let account: AccountInTransaction
    let category: CategoryInTransaction
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String?
    let updatedAt: String?
}

struct CreatedTransactionDTO: Codable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String?
    let updatedAt: String?
}

struct AccountInTransaction: Codable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
}

struct CategoryInTransaction: Codable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
}

@Observable
final class TransactionsService {
    private let networkClient = NetworkClient()
    
    func fetchTransaction(id: Int) async throws -> TransactionDTO {
        try await networkClient.request(
            path: "transactions/\(id)",
            method: "GET",
            body: Optional<String>.none
        )
    }
    
    func fetchTransactions(accountId: Int, from: String, to: String) async throws -> [TransactionDTO] {
        let queryItems = [
            URLQueryItem(name: "from", value: from),
            URLQueryItem(name: "to", value: to)
        ]
        return try await networkClient.request(
            path: "transactions/account/\(accountId)/period",
            method: "GET",
            body: Optional<String>.none,
            queryItems: queryItems
        )
    }
    
    struct CreateTransactionRequest: Encodable {
        let accountId: Int
        let categoryId: Int
        let amount: String
        let transactionDate: String
        let comment: String?

        enum CodingKeys: String, CodingKey {
            case accountId, categoryId, amount, transactionDate, comment
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(accountId, forKey: .accountId)
            try container.encode(categoryId, forKey: .categoryId)
            try container.encode(amount, forKey: .amount)
            try container.encode(transactionDate, forKey: .transactionDate)
            try container.encode(comment, forKey: .comment)
        }
    }
    
    func createTransaction(accountId: Int, categoryId: Int, amount: String, transactionDate: String, comment: String?) async throws -> CreatedTransactionDTO {
        let req = CreateTransactionRequest(accountId: accountId, categoryId: categoryId, amount: amount, transactionDate: transactionDate, comment: comment)
        return try await networkClient.request(
            path: "transactions",
            method: "POST",
            body: req
        )
    }
    
    struct EditTransactionRequest: Encodable {
        let accountId: Int
        let categoryId: Int
        let amount: String
        let transactionDate: String
        let comment: String?

        enum CodingKeys: String, CodingKey {
            case accountId, categoryId, amount, transactionDate, comment
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(accountId, forKey: .accountId)
            try container.encode(categoryId, forKey: .categoryId)
            try container.encode(amount, forKey: .amount)
            try container.encode(transactionDate, forKey: .transactionDate)
            try container.encode(comment, forKey: .comment)
        }
    }
    func editTransaction(id: Int, accountId: Int, categoryId: Int, amount: String, transactionDate: String, comment: String?) async throws -> TransactionDTO {
        let req = EditTransactionRequest(accountId: accountId, categoryId: categoryId, amount: amount, transactionDate: transactionDate, comment: comment)
        return try await networkClient.request(
            path: "transactions/\(id)",
            method: "PUT",
            body: req
        )
    }
    
    func deleteTransaction(id: Int) async throws {
        _ = try await networkClient.request(
            path: "transactions/\(id)",
            method: "DELETE",
            body: Optional<String>.none
        ) as EmptyResponse
    }
}

extension TransactionsService {
    private func map(dto: TransactionDTO) -> Transaction {
        Transaction(
            id: dto.id,
            accountId: String(dto.account.id),
            categoryId: String(dto.category.id),
            amount: Decimal(string: dto.amount) ?? 0,
            comment: dto.comment,
            timestamp: ISO8601DateFormatter().date(from: dto.transactionDate) ?? Date(),
            hidden: false
        )
    }
    
    func getTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        let formatter = ISO8601DateFormatter()
        let fromString = formatter.string(from: startDate)
        let toString = formatter.string(from: endDate)
        let accounts = try await BankAccountsService().fetchAccounts()
        guard let account = accounts.first else { return [] }
        let dtos = try await fetchTransactions(accountId: account.id, from: fromString, to: toString)
        return dtos.map(map(dto:))
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        guard let accountId = Int(transaction.accountId ?? ""), let categoryId = Int(transaction.categoryId ?? "") else { throw Error.invalidData }
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: transaction.timestamp)
        let cleanComment: String? = transaction.comment?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ? nil : transaction.comment
        _ = try await createTransaction(
            accountId: accountId,
            categoryId: categoryId,
            amount: transaction.amount.description,
            transactionDate: dateString,
            comment: cleanComment
        )
    }
    
    func editTransaction(_ newTransaction: Transaction) async throws {
        guard let accountId = Int(newTransaction.accountId ?? ""), let categoryId = Int(newTransaction.categoryId ?? "") else { throw Error.invalidData }
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: newTransaction.timestamp)
        let cleanComment: String? = newTransaction.comment?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ? nil : newTransaction.comment
        _ = try await editTransaction(
            id: newTransaction.id,
            accountId: accountId,
            categoryId: categoryId,
            amount: newTransaction.amount.description,
            transactionDate: dateString,
            comment: cleanComment
        )
    }
    
    func removeTransaction(withId id: Int) async throws {
        try await deleteTransaction(id: id)
    }
    
    private enum Error: Swift.Error {
        case invalidData
    }
}
