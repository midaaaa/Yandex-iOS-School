//
//  TransactionsFileCache.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 11.06.2025.
//

import Foundation

final actor TransactionsFileCache {
    private(set) var transactions: [Transaction] = []
    private let fileManager: FileManager
    private let fileURL: URL
    
    init(
        filename: String = "transactions",
        fileManager: FileManager = .default,
        documentsDirectory: URL? = nil
    ) {
        let documentsDirectory = documentsDirectory ?? fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        
        self.fileURL = documentsDirectory.appendingPathComponent("\(filename).json")
        self.fileManager = fileManager
    }
    
    func addTransaction(_ transaction: Transaction) async throws {
        guard !transactions.contains(where: { $0.id == transaction.id }) else {
            throw Error.duplicateTransaction
        }
        
        transactions.append(transaction)
        try await saveToFile()
    }
    
    func removeTransaction(withId id: Int) async throws {
        transactions.removeAll { $0.id == id }
        try await saveToFile()
    }
    
    func loadFromFile() throws {
        do {
            guard fileManager.fileExists(atPath: fileURL.path) else {
                self.transactions = []
                return
            }

            let data = try Data(contentsOf: fileURL)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let jsonArray = jsonObject as? [Any] else {
                throw Error.invalidFileFormat
            }
            
            self.transactions = jsonArray.compactMap { Transaction.parse(jsonObject: $0) }
        } catch {
            NSLog("Ошибка загрузки: \(error)")
            self.transactions = []
            throw Error.fileOperationFailed
        }
    }
    
    func saveToFile() async throws {
        do {
            let jsonArray = transactions.map { $0.jsonObject }
            let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted])
            try data.write(to: fileURL, options: [.atomicWrite])
        } catch {
            NSLog("Ошибка сохранения: \(error)")
            throw Error.fileOperationFailed
        }
    }
}

extension TransactionsFileCache {
    private enum Error: Swift.Error {
        case duplicateTransaction
        case invalidFileFormat
        case invalidTransactionData
        case fileOperationFailed
    }
}
