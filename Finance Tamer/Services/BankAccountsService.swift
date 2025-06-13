//
//  BankAccountsService.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 12.06.2025.
//
import Foundation

final class BankAccountsService {
    private var mockBankAccounts = [
        BankAccount(id: "g5ldpb73", name: "Основной счет", balance: 15000.50, currency: "USD"),
        BankAccount(id: "g99dpb99", name: "Дополнительный счет", balance: 9999.99, currency: "EUR"),
        //BankAccount(...),
        //BankAccount(...),
    ]
    
    func bankAccount() async throws -> BankAccount {
        guard let bankAccount = mockBankAccounts.first else {
            throw MockError.notFound
        }
        return bankAccount
    }
    
    func editBankAccount(_ updatedBankAccount: BankAccount) async throws {
        if let index = mockBankAccounts.firstIndex(where: { $0.id == updatedBankAccount.id }) {
            mockBankAccounts[index] = updatedBankAccount
        } else {
            throw MockError.notFound
        }
    }
}

enum MockError: Error {
    case notFound
    case duplicate
    case invalidData
}
