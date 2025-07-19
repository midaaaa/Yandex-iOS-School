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
    private let localStorage: TransactionStorage
    private let backupStorage: TransactionBackupStorage
    private let bankAccountService: BankAccountsService
    
    private static var lastSyncTime: Date?
    private static let syncCooldown: TimeInterval = 5.0
    
    init(localStorage: TransactionStorage = SwiftDataTransactionStorage.create(), 
         backupStorage: TransactionBackupStorage = SwiftDataBackupStorage(),
         bankAccountService: BankAccountsService? = nil) {
        self.localStorage = localStorage
        self.backupStorage = backupStorage
        self.bankAccountService = bankAccountService ?? BankAccountsService()
    }
    
    func fetchTransactions(accountId: Int, from: String, to: String) async throws -> [TransactionDTO] {
        let queryItems = [
            URLQueryItem(name: "startDate", value: from),
            URLQueryItem(name: "endDate", value: to)
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

struct EmptyResponse: Decodable {}

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
        if let lastSync = Self.lastSyncTime, Date().timeIntervalSince(lastSync) < Self.syncCooldown {
            let allLocalTransactions = try await localStorage.getAllTransactions()
            
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: startDate)
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
            
            let filteredTransactions = allLocalTransactions.filter { transaction in
                transaction.timestamp >= startOfDay && transaction.timestamp <= endOfDay
            }
            
            return filteredTransactions
        }
        
        do {
            let unsyncedOperations = try await backupStorage.getUnsyncedOperations()
            if !unsyncedOperations.isEmpty {
                _ = await syncBackupOperations()
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let fromString = dateFormatter.string(from: startDate)
            let toString = dateFormatter.string(from: endDate)
            let accounts = try await bankAccountService.fetchAccounts()
            guard let account = accounts.first else { return [] }
            
            let dtos = try await fetchTransactions(accountId: account.id, from: fromString, to: toString)
            
            let networkTransactions = dtos.map(map(dto:))
            let allLocalTransactions = try await localStorage.getAllTransactions()
            
            var updatedCount = 0
            var createdCount = 0
            
            for transaction in networkTransactions {
                let existingTransaction = allLocalTransactions.first { $0.id == transaction.id }
                
                if let existing = existingTransaction {
                    if existing.amount != transaction.amount ||
                       existing.comment != transaction.comment ||
                       existing.timestamp != transaction.timestamp ||
                       existing.accountId != transaction.accountId ||
                       existing.categoryId != transaction.categoryId {
                        try await localStorage.updateTransaction(transaction)
                        updatedCount += 1
                    }
                } else {
                    try await localStorage.createTransaction(transaction)
                    createdCount += 1
                }
            }
            
            var deletedCount = 0
            for localTransaction in allLocalTransactions {
                let existsOnServer = networkTransactions.contains { $0.id == localTransaction.id }
                if !existsOnServer && localTransaction.id > 0 {
                    try await localStorage.deleteTransaction(withId: localTransaction.id)
                    deletedCount += 1
                }
            }
            
            Self.lastSyncTime = Date()
            
            return networkTransactions
            
        } catch {
            let allLocalTransactions = try await localStorage.getAllTransactions()
            let unsyncedOperations = try await backupStorage.getUnsyncedOperations()
            
            var mergedTransactions = allLocalTransactions
            
            for operation in unsyncedOperations {
                switch operation.type {
                case .create:
                    if !mergedTransactions.contains(where: { $0.id == operation.data.id }) {
                        mergedTransactions.append(operation.data)
                    }
                case .update:
                    if let index = mergedTransactions.firstIndex(where: { $0.id == operation.data.id }) {
                        mergedTransactions[index] = operation.data
                    }
                case .delete:
                    mergedTransactions.removeAll { $0.id == operation.data.id }
                }
            }
            
            var uniqueTransactions: [Transaction] = []
            for transaction in mergedTransactions {
                let isDuplicate = uniqueTransactions.contains { existing in
                    existing.accountId == transaction.accountId &&
                    existing.categoryId == transaction.categoryId &&
                    existing.amount == transaction.amount &&
                    existing.timestamp == transaction.timestamp &&
                    existing.comment == transaction.comment
                }
                if !isDuplicate {
                    uniqueTransactions.append(transaction)
                }
            }
            mergedTransactions = uniqueTransactions
            
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: startDate)
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
            
            let filteredTransactions = mergedTransactions.filter { transaction in
                transaction.timestamp >= startOfDay && transaction.timestamp <= endOfDay
            }
            
            return filteredTransactions
        }
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        let allLocalTransactions = try await localStorage.getAllTransactions()
        let existingTransaction = allLocalTransactions.first { localTransaction in
            localTransaction.accountId == transaction.accountId &&
            localTransaction.categoryId == transaction.categoryId &&
            localTransaction.amount == transaction.amount &&
            localTransaction.timestamp == transaction.timestamp &&
            localTransaction.comment == transaction.comment
        }
        
        if existingTransaction != nil {
            return
        }
        
        do {
            guard let accountId = Int(transaction.accountId ?? ""), let categoryId = Int(transaction.categoryId ?? "") else { throw Error.invalidData }
            let formatter = ISO8601DateFormatter()
            let dateString = formatter.string(from: transaction.timestamp)
            let cleanComment: String? = transaction.comment?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ? nil : transaction.comment
            
            let createdDTO = try await createTransaction(
                accountId: accountId,
                categoryId: categoryId,
                amount: transaction.amount.description,
                transactionDate: dateString,
                comment: cleanComment
            )
            
            var networkTransaction = transaction
            networkTransaction.id = createdDTO.id
            try await localStorage.createTransaction(networkTransaction)
            
            let unsyncedOperations = try await backupStorage.getUnsyncedOperations()
            for operation in unsyncedOperations {
                if operation.type == .create && 
                   operation.data.accountId == transaction.accountId &&
                   operation.data.categoryId == transaction.categoryId &&
                   operation.data.amount == transaction.amount &&
                   operation.data.timestamp == transaction.timestamp &&
                   operation.data.comment == transaction.comment {
                    try await backupStorage.removeOperation(id: operation.id)
                }
            }
            
        } catch {
            var offlineTransaction = transaction
            offlineTransaction.id = Int.random(in: -1000000...(-1))
            
            try await localStorage.createTransaction(offlineTransaction)
            
            let backupOperation = BackupOperation(
                id: UUID().uuidString,
                type: .create,
                transactionId: nil,
                data: offlineTransaction,
                timestamp: Date(),
                synced: false
            )
            try await backupStorage.addOperation(backupOperation)
            
            await updateBalanceForTransaction(transaction: offlineTransaction, isIncome: true)
        }
    }
    
    func editTransaction(_ newTransaction: Transaction) async throws {
        do {
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
            
            try await localStorage.updateTransaction(newTransaction)
            
            let unsyncedOperations = try await backupStorage.getUnsyncedOperations()
            for operation in unsyncedOperations {
                if operation.type == .update && operation.transactionId == newTransaction.id {
                    try await backupStorage.removeOperation(id: operation.id)
                }
            }
            
        } catch {
            let allTransactions = try await localStorage.getAllTransactions()
            let oldTransaction = allTransactions.first { $0.id == newTransaction.id }
            
            try await localStorage.updateTransaction(newTransaction)
            
            let backupOperation = BackupOperation(
                id: UUID().uuidString,
                type: .update,
                transactionId: newTransaction.id,
                data: newTransaction,
                timestamp: Date(),
                synced: false
            )
            try await backupStorage.addOperation(backupOperation)
            
            if let oldTransaction = oldTransaction {
                await updateBalanceForTransactionEdit(
                    oldTransaction: oldTransaction,
                    newTransaction: newTransaction
                )
            }
        }
    }
    
    func removeTransaction(withId id: Int) async throws {
        do {
            try await deleteTransaction(id: id)
            try await localStorage.deleteTransaction(withId: id)
            
            let unsyncedOperations = try await backupStorage.getUnsyncedOperations()
            for operation in unsyncedOperations {
                if operation.type == .delete && operation.transactionId == id {
                    try await backupStorage.removeOperation(id: operation.id)
                }
            }
            
        } catch {
            let allTransactions = try await localStorage.getAllTransactions()
            guard let transaction = allTransactions.first(where: { $0.id == id }) else {
                try await localStorage.deleteTransaction(withId: id)
                return
            }
            
            try await localStorage.deleteTransaction(withId: id)
            
            let backupOperation = BackupOperation(
                id: UUID().uuidString,
                type: .delete,
                transactionId: id,
                data: transaction,
                timestamp: Date(),
                synced: false
            )
            try await backupStorage.addOperation(backupOperation)
            await updateBalanceForTransactionDelete(transaction: transaction)
        }
    }
    
    private enum Error: Swift.Error {
        case invalidData
    }
    
    private func syncBackupOperations() async -> Bool {
        do {
            let unsyncedOperations = try await backupStorage.getUnsyncedOperations()
            guard !unsyncedOperations.isEmpty else {
                return false
            }
            
            var syncedCount = 0
            var failedCount = 0
            
            for operation in unsyncedOperations {
                do {
                    switch operation.type {
                    case .create:
                        try await syncCreateOperation(operation)
                    case .update:
                        try await syncUpdateOperation(operation)
                    case .delete:
                        try await syncDeleteOperation(operation)
                    }
                    
                    try await backupStorage.removeOperation(id: operation.id)
                    syncedCount += 1
                    
                } catch {
                    if let httpError = error as? NetworkError,
                       case .httpError(let statusCode, _) = httpError, 
                       statusCode == 404 {
                        try await backupStorage.removeOperation(id: operation.id)
                        failedCount += 1
                    }
                }
            }
            
            return syncedCount > 0 || failedCount > 0
            
        } catch {
            print("Ошибка получения операций бекапа: \(error)")
            return false
        }
    }
    
    private func syncCreateOperation(_ operation: BackupOperation) async throws {
        guard let accountId = Int(operation.data.accountId ?? ""), 
              let categoryId = Int(operation.data.categoryId ?? "") else { 
            throw Error.invalidData 
        }
        
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: operation.data.timestamp)
        let cleanComment: String? = operation.data.comment?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ? nil : operation.data.comment
        
        let createdDTO = try await createTransaction(
            accountId: accountId,
            categoryId: categoryId,
            amount: operation.data.amount.description,
            transactionDate: dateString,
            comment: cleanComment
        )
        
        let allLocalTransactions = try await localStorage.getAllTransactions()
        let existingTransaction = allLocalTransactions.first { localTransaction in
            localTransaction.accountId == operation.data.accountId &&
            localTransaction.categoryId == operation.data.categoryId &&
            localTransaction.amount == operation.data.amount &&
            localTransaction.timestamp == operation.data.timestamp &&
            localTransaction.comment == operation.data.comment &&
            localTransaction.id != operation.data.id && localTransaction.id > 0
        }
        
        if let existing = existingTransaction {
            try await localStorage.deleteTransaction(withId: operation.data.id)
            print("Транзакция уже существует с серверным ID \(existing.id), удаляем временную \(operation.data.id)")
        } else {
            try await localStorage.deleteTransaction(withId: operation.data.id)
            
            var updatedTransaction = operation.data
            updatedTransaction.id = createdDTO.id
            try await localStorage.createTransaction(updatedTransaction)
            
            print("Синхронизирована операция создания: временный ID \(operation.data.id) -> серверный ID \(createdDTO.id)")
        }
    }
    
    private func syncUpdateOperation(_ operation: BackupOperation) async throws {
        guard let accountId = Int(operation.data.accountId ?? ""), 
              let categoryId = Int(operation.data.categoryId ?? "") else { 
            throw Error.invalidData 
        }
        
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: operation.data.timestamp)
        let cleanComment: String? = operation.data.comment?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ? nil : operation.data.comment
        
        _ = try await editTransaction(
            id: operation.data.id,
            accountId: accountId,
            categoryId: categoryId,
            amount: operation.data.amount.description,
            transactionDate: dateString,
            comment: cleanComment
        )
        
        print("Синхронизирована операция обновления: ID \(operation.data.id)")
    }
    
    private func syncDeleteOperation(_ operation: BackupOperation) async throws {
        try await deleteTransaction(id: operation.data.id)
        print("Синхронизирована операция удаления: ID \(operation.data.id)")
    }
    
    private func updateBalanceForTransaction(transaction: Transaction, isIncome: Bool) async {
        do {
            let categoriesService = CategoriesService()
            let categories = try await categoriesService.categories()
            let category = categories.first { $0.id == transaction.categoryId }
            
            let isTransactionIncome = category?.type == .income
            
            try await bankAccountService.updateBalanceForTransaction(
                transactionId: transaction.id,
                oldAmount: nil,
                newAmount: transaction.amount,
                isIncome: isTransactionIncome,
                accountId: transaction.accountId ?? ""
            )
            
        } catch {
            print("Ошибка обновления баланса: \(error)")
        }
    }
    
    private func updateBalanceForTransactionEdit(oldTransaction: Transaction, newTransaction: Transaction) async {
        do {
            let categoriesService = CategoriesService()
            let categories = try await categoriesService.categories()
            _ = categories.first { $0.id == oldTransaction.categoryId }
            let newCategory = categories.first { $0.id == newTransaction.categoryId }
            
            let isNewIncome = newCategory?.type == .income
            
            try await bankAccountService.updateBalanceForTransaction(
                transactionId: newTransaction.id,
                oldAmount: oldTransaction.amount,
                newAmount: newTransaction.amount,
                isIncome: isNewIncome,
                accountId: newTransaction.accountId ?? ""
            )
            
        } catch {
            print("Ошибка обновления баланса при редактировании: \(error)")
        }
    }
    
    private func updateBalanceForTransactionDelete(transaction: Transaction) async {
        do {
            let categoriesService = CategoriesService()
            let categories = try await categoriesService.categories()
            let category = categories.first { $0.id == transaction.categoryId }
            
            let isTransactionIncome = category?.type == .income
            
            try await bankAccountService.removeBalanceForTransaction(
                transactionId: transaction.id,
                amount: transaction.amount,
                isIncome: isTransactionIncome,
                accountId: transaction.accountId ?? ""
            )
            
        } catch {
            print("Ошибка обновления баланса при удалении: \(error)")
        }
    }
}
