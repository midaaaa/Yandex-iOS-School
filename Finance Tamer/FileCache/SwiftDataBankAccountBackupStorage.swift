//
//  SwiftDataBankAccountBackupStorage.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation
import SwiftData

@ModelActor
actor BankAccountBackupModelActor {
    func addOperation(_ operation: BankAccountBackupOperation) throws {
        let entity = BankAccountBackupOperationEntity(from: operation)
        modelContext.insert(entity)
        try modelContext.save()
    }
    
    func getUnsyncedOperations() throws -> [BankAccountBackupOperation] {
        let descriptor = FetchDescriptor<BankAccountBackupOperationEntity>(
            predicate: #Predicate<BankAccountBackupOperationEntity> { $0.synced == false },
            sortBy: [SortDescriptor(\.timestamp)]
        )
        
        let entities = try modelContext.fetch(descriptor)
        let operations = entities.compactMap { $0.toBankAccountBackupOperation() }
        return operations
    }
    
    func removeOperation(id: String) throws {
        let descriptor = FetchDescriptor<BankAccountBackupOperationEntity>(
            predicate: #Predicate<BankAccountBackupOperationEntity> { $0.id == id }
        )
        
        let entities = try modelContext.fetch(descriptor)
        guard let entity = entities.first else {
            return
        }
        
        modelContext.delete(entity)
        try modelContext.save()
    }
}

final class SwiftDataBankAccountBackupStorage: BankAccountBackupStorage {
    private let modelContainer: ModelContainer
    private let modelActor: BankAccountBackupModelActor
    
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
            self.modelActor = BankAccountBackupModelActor(modelContainer: modelContainer)

        } catch {
            fatalError("Failed to initialize SwiftDataBankAccountBackupStorage ModelContainer: \(error)")
        }
    }
    
    func addOperation(_ operation: BankAccountBackupOperation) async throws {
        try await modelActor.addOperation(operation)
    }
    
    func getUnsyncedOperations() async throws -> [BankAccountBackupOperation] {
        try await modelActor.getUnsyncedOperations()
    }
    
    func removeOperation(id: String) async throws {
        try await modelActor.removeOperation(id: id)
    }
} 
