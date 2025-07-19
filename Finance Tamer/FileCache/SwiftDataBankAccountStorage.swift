//
//  SwiftDataBankAccountStorage.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation
import SwiftData

@ModelActor
actor BankAccountModelActor {
    func getBankAccount() throws -> BankAccount? {
        let descriptor = FetchDescriptor<BankAccountEntity>()
        let entities = try modelContext.fetch(descriptor)
        return entities.first?.toBankAccount()
    }
    
    func updateBankAccount(_ bankAccount: BankAccount) throws {
        let descriptor = FetchDescriptor<BankAccountEntity>()
        let entities = try modelContext.fetch(descriptor)
        
        if let entity = entities.first {
            entity.id = bankAccount.id
            entity.name = bankAccount.name
            entity.balance = bankAccount.balance.description
            entity.currency = bankAccount.currency
        } else {
            let newEntity = BankAccountEntity(from: bankAccount)
            modelContext.insert(newEntity)
        }
        
        try modelContext.save()
    }
    
    func createBankAccount(_ bankAccount: BankAccount) throws {
        let entity = BankAccountEntity(from: bankAccount)
        modelContext.insert(entity)
        try modelContext.save()
    }
}

final class SwiftDataBankAccountStorage: BankAccountStorage {
    private let modelContainer: ModelContainer
    private let modelActor: BankAccountModelActor
    
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
            self.modelActor = BankAccountModelActor(modelContainer: modelContainer)

        } catch {
            fatalError("Failed to initialize SwiftDataBankAccountStorage ModelContainer: \(error)")
        }
    }
    
    static func create() -> SwiftDataBankAccountStorage {
        return SwiftDataBankAccountStorage()
    }
    
    func getBankAccount() async throws -> BankAccount? {
        try await modelActor.getBankAccount()
    }
    
    func updateBankAccount(_ bankAccount: BankAccount) async throws {
        try await modelActor.updateBankAccount(bankAccount)
    }
    
    func createBankAccount(_ bankAccount: BankAccount) async throws {
        try await modelActor.createBankAccount(bankAccount)
    }
} 
