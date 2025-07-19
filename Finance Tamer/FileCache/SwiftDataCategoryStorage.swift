//
//  SwiftDataCategoryStorage.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation
import SwiftData

@ModelActor
actor CategoryModelActor {
    func getAllCategories() throws -> [Category] {
        let descriptor = FetchDescriptor<CategoryEntity>()
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toCategory() }
    }
    
    func getCategories(ofType type: Category.Direction) throws -> [Category] {
        let typeString = type == .income ? "income" : "outcome"
        let descriptor = FetchDescriptor<CategoryEntity>(
            predicate: #Predicate<CategoryEntity> { entity in
                entity.type == typeString
            }
        )
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toCategory() }
    }
    
    func updateCategories(_ categories: [Category]) throws {
        let descriptor = FetchDescriptor<CategoryEntity>()
        let existingEntities = try modelContext.fetch(descriptor)
        existingEntities.forEach { modelContext.delete($0) }
        
        for category in categories {
            let entity = CategoryEntity(from: category)
            modelContext.insert(entity)
        }
        
        try modelContext.save()
    }
}

final class SwiftDataCategoryStorage: CategoryStorage {
    private let modelContainer: ModelContainer
    private let modelActor: CategoryModelActor
    
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
            self.modelActor = CategoryModelActor(modelContainer: modelContainer)

        } catch {
            fatalError("Failed to initialize SwiftDataCategoryStorage ModelContainer: \(error)")
        }
    }
    
    static func create() -> SwiftDataCategoryStorage {
        return SwiftDataCategoryStorage()
    }
    
    func getAllCategories() async throws -> [Category] {
        try await modelActor.getAllCategories()
    }
    
    func getCategories(ofType type: Category.Direction) async throws -> [Category] {
        try await modelActor.getCategories(ofType: type)
    }
    
    func updateCategories(_ categories: [Category]) async throws {
        try await modelActor.updateCategories(categories)
    }
} 
