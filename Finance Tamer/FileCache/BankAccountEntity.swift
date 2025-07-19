//
//  BankAccountEntity.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation
import SwiftData

@Model
final class BankAccountEntity {
    var id: String
    var name: String
    var balance: String
    var currency: String
    
    init(from bankAccount: BankAccount) {
        self.id = bankAccount.id
        self.name = bankAccount.name
        self.balance = bankAccount.balance.description
        self.currency = bankAccount.currency
    }
    
    func toBankAccount() -> BankAccount {
        return BankAccount(
            id: id,
            name: name,
            balance: Decimal(string: balance) ?? 0,
            currency: currency
        )
    }
} 
