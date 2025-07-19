//
//  BackupOperationEntity.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation
import SwiftData

@Model
final class BackupOperationEntity {
    var id: String
    var type: String
    var transactionId: Int?
    var transactionData: Data
    var timestamp: Date
    var synced: Bool
    
    init(from operation: BackupOperation) {
        self.id = operation.id
        self.type = operation.type.rawValue
        self.transactionId = operation.transactionId
        self.timestamp = operation.timestamp
        self.synced = operation.synced
        
        do {
            let encoder = JSONEncoder()
            self.transactionData = try encoder.encode(operation.data)
        } catch {
            self.transactionData = Data()
        }
    }
    
    func toBackupOperation() -> BackupOperation? {
        do {
            let decoder = JSONDecoder()
            let transaction = try decoder.decode(Transaction.self, from: transactionData)
            
            guard let operationType = BackupOperationType(rawValue: type) else {
                return nil
            }
            
            return BackupOperation(
                id: id,
                type: operationType,
                transactionId: transactionId,
                data: transaction,
                timestamp: timestamp,
                synced: synced
            )
        } catch {
            return nil
        }
    }
} 
