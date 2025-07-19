//
//  TransactionStorage.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation

protocol TransactionStorage {
    func getAllTransactions() async throws -> [Transaction]
    func updateTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(withId id: Int) async throws
    func createTransaction(_ transaction: Transaction) async throws
} 
