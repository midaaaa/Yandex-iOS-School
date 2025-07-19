//
//  BankAccountStorage.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation

protocol BankAccountStorage {
    func getBankAccount() async throws -> BankAccount?
    func updateBankAccount(_ bankAccount: BankAccount) async throws
    func createBankAccount(_ bankAccount: BankAccount) async throws
} 
