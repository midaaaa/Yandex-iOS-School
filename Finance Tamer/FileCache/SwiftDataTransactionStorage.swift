//
//  SwiftDataTransactionStorage.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation
import SwiftData

@ModelActor
actor TransactionModelActor {
    func getAllTransactions() throws -> [Transaction] {
        let descriptor = FetchDescriptor<TransactionEntity>()
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toTransaction() }
    }
    
    func updateTransaction(_ transaction: Transaction) throws {
        let descriptor = FetchDescriptor<TransactionEntity>(
            predicate: #Predicate<TransactionEntity> { entity in
                entity.id == transaction.id
            }
        )
        
        let entities = try modelContext.fetch(descriptor)
        if let entity = entities.first {
            entity.accountId = transaction.accountId
            entity.categoryId = transaction.categoryId
            entity.amount = transaction.amount.description
            entity.comment = transaction.comment
            entity.timestamp = transaction.timestamp
            entity.hidden = transaction.hidden
        } else {
            let newEntity = TransactionEntity(from: transaction)
            modelContext.insert(newEntity)
        }
        
        try modelContext.save()
    }
    
    func deleteTransaction(withId id: Int) throws {
        let descriptor = FetchDescriptor<TransactionEntity>(
            predicate: #Predicate<TransactionEntity> { entity in
                entity.id == id
            }
        )
        
        let entities = try modelContext.fetch(descriptor)
        entities.forEach { modelContext.delete($0) }
        try modelContext.save()
    }
    
    func createTransaction(_ transaction: Transaction) throws {
        let entity = TransactionEntity(from: transaction)
        modelContext.insert(entity)
        try modelContext.save()
    }
}

final class SwiftDataTransactionStorage: TransactionStorage {
    private let modelContainer: ModelContainer
    private let modelActor: TransactionModelActor
    
    init() {
        do {
            let schema = Schema([
                TransactionEntity.self,
                BankAccountEntity.self,
                CategoryEntity.self,
                BackupOperationEntity.self,
                BankAccountBackupOperationEntity.self
            ])
            
            self.modelContainer = try ModelContainer(for: schema)
            self.modelActor = TransactionModelActor(modelContainer: modelContainer)

        } catch {
            fatalError("Failed to initialize SwiftDataTransactionStorage ModelContainer: \(error)")
        }
    }
    
    static func create() -> SwiftDataTransactionStorage {
        return SwiftDataTransactionStorage()
    }
    
    func getAllTransactions() async throws -> [Transaction] {
        try await modelActor.getAllTransactions()
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        try await modelActor.updateTransaction(transaction)
    }
    
    func deleteTransaction(withId id: Int) async throws {
        try await modelActor.deleteTransaction(withId: id)
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        try await modelActor.createTransaction(transaction)
    }
} 
