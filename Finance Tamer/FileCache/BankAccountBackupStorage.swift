//
//  BankAccountBackupStorage.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation

enum BankAccountBackupOperationType: String, Codable {
    case balanceUpdate = "balance_update"
}

struct BankAccountBackupOperation: Codable {
    let id: String
    let type: BankAccountBackupOperationType
    let accountId: String
    let oldBalance: Decimal
    let newBalance: Decimal
    let reason: String
    let transactionId: Int?
    let timestamp: Date
    let synced: Bool
}

protocol BankAccountBackupStorage {
    func addOperation(_ operation: BankAccountBackupOperation) async throws
    func getUnsyncedOperations() async throws -> [BankAccountBackupOperation]
    func removeOperation(id: String) async throws
} 
