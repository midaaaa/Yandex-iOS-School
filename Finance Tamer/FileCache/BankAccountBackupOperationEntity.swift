//
//  BankAccountBackupOperationEntity.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation
import SwiftData

@Model
final class BankAccountBackupOperationEntity {
    var id: String
    var type: String
    var accountId: String
    var oldBalance: String
    var newBalance: String
    var reason: String
    var transactionId: Int?
    var timestamp: Date
    var synced: Bool
    
    init(from operation: BankAccountBackupOperation) {
        self.id = operation.id
        self.type = operation.type.rawValue
        self.accountId = operation.accountId
        self.oldBalance = operation.oldBalance.description
        self.newBalance = operation.newBalance.description
        self.reason = operation.reason
        self.transactionId = operation.transactionId
        self.timestamp = operation.timestamp
        self.synced = operation.synced
    }
    
    func toBankAccountBackupOperation() -> BankAccountBackupOperation? {
        guard let operationType = BankAccountBackupOperationType(rawValue: type),
              let oldBalanceDecimal = Decimal(string: oldBalance),
              let newBalanceDecimal = Decimal(string: newBalance) else {
            return nil
        }
        
        return BankAccountBackupOperation(
            id: id,
            type: operationType,
            accountId: accountId,
            oldBalance: oldBalanceDecimal,
            newBalance: newBalanceDecimal,
            reason: reason,
            transactionId: transactionId,
            timestamp: timestamp,
            synced: synced
        )
    }
} 
