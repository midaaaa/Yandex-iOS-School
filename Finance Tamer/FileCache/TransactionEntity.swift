//
//  TransactionEntity.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation
import SwiftData

@Model
final class TransactionEntity {
    var id: Int
    var accountId: String?
    var categoryId: String?
    var amount: String
    var comment: String?
    var timestamp: Date
    var hidden: Bool
    
    init(from transaction: Transaction) {
        self.id = transaction.id
        self.accountId = transaction.accountId
        self.categoryId = transaction.categoryId
        self.amount = transaction.amount.description
        self.comment = transaction.comment
        self.timestamp = transaction.timestamp
        self.hidden = transaction.hidden
    }
    
    func toTransaction() -> Transaction {
        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: Decimal(string: amount) ?? 0,
            comment: comment,
            timestamp: timestamp,
            hidden: hidden
        )
    }
} 
