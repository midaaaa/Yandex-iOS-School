//
//  TransactionBackupStorage.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation

enum BackupOperationType: String, Codable {
    case create = "create"
    case update = "update"
    case delete = "delete"
}

struct BackupOperation: Codable {
    let id: String
    let type: BackupOperationType
    let transactionId: Int?
    let data: Transaction
    let timestamp: Date
    let synced: Bool
}

protocol TransactionBackupStorage {
    func addOperation(_ operation: BackupOperation) async throws
    func getUnsyncedOperations() async throws -> [BackupOperation]
    func removeOperation(id: String) async throws
} 
