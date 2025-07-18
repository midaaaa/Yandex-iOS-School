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
    
    func fetchAccounts() async throws -> [BankAccountDTO] {
        try await networkClient.request(
            path: "accounts",
            method: "GET",
            body: Optional<String>.none
        )
    }
    
    func fetchAccount(id: Int) async throws -> BankAccountDTO {
        try await networkClient.request(
            path: "accounts/\(id)",
            method: "GET",
            body: Optional<String>.none
        )
    }
    
    struct CreateAccountRequest: Encodable {
        let name: String
        let balance: String
        let currency: String
    }
    
    func createAccount(name: String, balance: String, currency: String) async throws -> BankAccountDTO {
        let req = CreateAccountRequest(name: name, balance: balance, currency: currency)
        return try await networkClient.request(
            path: "accounts",
            method: "POST",
            body: req
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
    
    func deleteAccount(id: Int) async throws {
        _ = try await networkClient.request(
            path: "accounts/\(id)",
            method: "DELETE",
            body: Optional<String>.none
        ) as EmptyResponse
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
        let dtos = try await fetchAccounts()
        guard let first = dtos.first else { throw Error.notFound }
        return map(dto: first)
    }
    
    func editBankAccount(_ updatedBankAccount: BankAccount) async throws {
        guard let id = Int(updatedBankAccount.id) else { throw Error.invalidData }
        _ = try await editAccount(
            id: id,
            name: updatedBankAccount.name,
            balance: updatedBankAccount.balance.description,
            currency: updatedBankAccount.currency
        )
    }
    
    private enum Error: Swift.Error {
        case notFound
        case invalidData
    }
}

struct EmptyResponse: Decodable {}
