//
//  BankAccountsService.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 12.06.2025.
//

import Foundation

final class BankAccountsService {
    private var mockBankAccounts = [
        BankAccount(id: "g5ldpb73", name: "Основной счет", balance: Decimal(string: "15000.52") ?? 500, currency: "USD"),
        BankAccount(id: "g99dpb99", name: "Дополнительный счет", balance: Decimal(string: "9999.99") ?? 500, currency: "EUR"),
        //BankAccount(...),
        //BankAccount(...),
    ]
    
    func bankAccount() async throws -> BankAccount {
        guard let bankAccount = mockBankAccounts.first else {
            throw Error.notFound
        }
        return bankAccount
    }
    
    func editBankAccount(_ updatedBankAccount: BankAccount) async throws {
        if let index = mockBankAccounts.firstIndex(where: { $0.id == updatedBankAccount.id }) {
            mockBankAccounts[index] = updatedBankAccount
        } else {
            throw Error.notFound
        }
    }
}

extension BankAccountsService {
    private enum Error: Swift.Error {
        case notFound
        case duplicate
        case invalidData
    }
}
