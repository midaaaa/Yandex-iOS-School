//
//  BankAccountsService.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 12.06.2025.
//

import Foundation

struct BankAccountDTO: Codable {
    let id: Int
    let userId: Int?
    let name: String
    let balance: String
    let currency: String
    let createdAt: String?
    let updatedAt: String?
}

@Observable
final class BankAccountsService {
    private let networkClient = NetworkClient()
    private let localStorage: BankAccountStorage
    private let backupStorage: BankAccountBackupStorage
    
    init(localStorage: BankAccountStorage = SwiftDataBankAccountStorage.create(),
         backupStorage: BankAccountBackupStorage = SwiftDataBankAccountBackupStorage()) {
        self.localStorage = localStorage
        self.backupStorage = backupStorage
    }
    
    func fetchAccounts() async throws -> [BankAccountDTO] {
        try await networkClient.request(
            path: "accounts",
            method: "GET",
            body: Optional<String>.none
        )
    }
    
    struct EditAccountRequest: Encodable {
        let name: String
        let balance: String
        let currency: String
    }
    
    func editAccount(id: Int, name: String, balance: String, currency: String) async throws -> BankAccountDTO {
        let req = EditAccountRequest(name: name, balance: balance, currency: currency)
        return try await networkClient.request(
            path: "accounts/\(id)",
            method: "PUT",
            body: req
        )
    }
}

extension BankAccountsService {
    private func map(dto: BankAccountDTO) -> BankAccount {
        BankAccount(
            id: String(dto.id),
            name: dto.name,
            balance: Decimal(string: dto.balance) ?? 0,
            currency: dto.currency
        )
    }
    
    func bankAccount() async throws -> BankAccount {
        do {
            let hadUnsyncedOperations = await syncBackupOperations()
            if hadUnsyncedOperations {
                if let localBankAccount = try await localStorage.getBankAccount() {
                    return localBankAccount
                } else {
                    throw Error.notFound
                }
            }
            
            let dtos = try await fetchAccounts()
            guard let first = dtos.first else { throw Error.notFound }
            let networkBankAccount = map(dto: first)
            
            try await localStorage.updateBankAccount(networkBankAccount)
            
            return networkBankAccount
            
        } catch {
            if let localBankAccount = try await localStorage.getBankAccount() {
                return localBankAccount
            } else {
                throw Error.notFound
            }
        }
    }
    
    func editBankAccount(_ updatedBankAccount: BankAccount) async throws {
        do {
            guard let id = Int(updatedBankAccount.id) else { throw Error.invalidData }
            _ = try await editAccount(
                id: id,
                name: updatedBankAccount.name,
                balance: updatedBankAccount.balance.description,
                currency: updatedBankAccount.currency
            )
            
            try await localStorage.updateBankAccount(updatedBankAccount)
        } catch {
            try await localStorage.updateBankAccount(updatedBankAccount)
            throw error
        }
    }
    
    private enum Error: Swift.Error {
        case notFound
        case invalidData
    }
    
    func updateBalanceForTransaction(
        transactionId: Int,
        oldAmount: Decimal?,
        newAmount: Decimal,
        isIncome: Bool,
        accountId: String
    ) async throws {
        guard let currentAccount = try await localStorage.getBankAccount() else {
            return
        }
        
        let oldBalance = currentAccount.balance
        var newBalance = oldBalance
        
        if let oldAmount = oldAmount {
            let oldImpact = isIncome ? oldAmount : -oldAmount
            let newImpact = isIncome ? newAmount : -newAmount
            let balanceChange = newImpact - oldImpact
            newBalance += balanceChange
        } else {
            let impact = isIncome ? newAmount : -newAmount
            newBalance += impact
        }
        
        var updatedAccount = currentAccount
        updatedAccount.balance = newBalance
        
        try await localStorage.updateBankAccount(updatedAccount)
    }
    
    func removeBalanceForTransaction(
        transactionId: Int,
        amount: Decimal,
        isIncome: Bool,
        accountId: String
    ) async throws {
        guard let currentAccount = try await localStorage.getBankAccount() else {
            return
        }
        
        let oldBalance = currentAccount.balance
        let impact = isIncome ? amount : -amount
        let newBalance = oldBalance - impact
        
        var updatedAccount = currentAccount
        updatedAccount.balance = newBalance
        
        try await localStorage.updateBankAccount(updatedAccount)
    }
    
    func syncBackupOperations() async -> Bool {
        do {
            let unsyncedOperations = try await backupStorage.getUnsyncedOperations()
            guard !unsyncedOperations.isEmpty else {
                return false
            }
            
            for operation in unsyncedOperations {
                do {
                    try await backupStorage.removeOperation(id: operation.id)
                } catch {
                }
            }
            return true
        } catch {
            print("Ошибка получения операций бекапа счета: \(error)")
            return false
        }
    }

}


