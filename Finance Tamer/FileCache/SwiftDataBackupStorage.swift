//
//  SwiftDataBackupStorage.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation
import SwiftData

@ModelActor
actor BackupModelActor {
    func addOperation(_ operation: BackupOperation) throws {
        let entity = BackupOperationEntity(from: operation)
        modelContext.insert(entity)
        try modelContext.save()
    }
    
    func getUnsyncedOperations() throws -> [BackupOperation] {
        let descriptor = FetchDescriptor<BackupOperationEntity>(
            predicate: #Predicate<BackupOperationEntity> { $0.synced == false },
            sortBy: [SortDescriptor(\.timestamp)]
        )
        
        let entities = try modelContext.fetch(descriptor)
        let operations = entities.compactMap { $0.toBackupOperation() }
        return operations
    }
    
    func removeOperation(id: String) throws {
        let descriptor = FetchDescriptor<BackupOperationEntity>(
            predicate: #Predicate<BackupOperationEntity> { $0.id == id }
        )
        
        let entities = try modelContext.fetch(descriptor)
        guard let entity = entities.first else {
            return
        }
        
        modelContext.delete(entity)
        try modelContext.save()
    }
}

final class SwiftDataBackupStorage: TransactionBackupStorage {
    private let modelContainer: ModelContainer
    private let modelActor: BackupModelActor
    
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
            self.modelActor = BackupModelActor(modelContainer: modelContainer)

        } catch {
            fatalError("Failed to initialize SwiftDataBackupStorage ModelContainer: \(error)")
        }
    }
    
    func addOperation(_ operation: BackupOperation) async throws {
        try await modelActor.addOperation(operation)
    }
    
    func getUnsyncedOperations() async throws -> [BackupOperation] {
        try await modelActor.getUnsyncedOperations()
    }

    func removeOperation(id: String) async throws {
        try await modelActor.removeOperation(id: id)
    }
} 
