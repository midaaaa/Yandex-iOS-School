//
//  TransactionsFileCache.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 11.06.2025.
//

import Foundation

final class TransactionsFileCache {
    private(set) var transactions: [Transaction] = []
    
    private let fileURL: URL

    private let queue = DispatchQueue(label: "com.FinanceTamer.transactionsCache", qos: .userInitiated)

    init(filename: String = "transactions") {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = documentsDirectory.appendingPathComponent("\(filename).json")
    }
    
    func addTransaction(_ transaction: Transaction) async throws {
        guard !transactions.contains(where: { $0.id == transaction.id }) else { return }
        
        transactions.append(transaction)
        
        try await saveToFile()
    }
    
    func removeTransaction(withId id: Int) async throws {
        transactions.removeAll { $0.id == id }
        
        try await saveToFile()
    }
    
    func loadFromFile() throws {
        queue.sync {
            do {
                guard FileManager.default.fileExists(atPath: fileURL.path) else {
                    self.transactions = []
                    return
                }
                
                let data = try Data(contentsOf: fileURL)
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonArray = jsonObject as? [Any] else {
                    throw CacheError.invalidFileFormat
                }
                
                self.transactions = jsonArray.compactMap { Transaction.parse(jsonObject: $0) }
            } catch {
                print("Ошибка загрузки:", error)
                self.transactions = []
            }
        }
    }
    
    func saveToFile() async throws {
        let jsonArray = transactions.map { $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [.prettyPrinted])
        
        try queue.sync {
            try data.write(to: fileURL, options: [.atomicWrite])
        }
    }

    enum CacheError: Error {
        case duplicateTransaction  // Попытка добавить транзакцию с существующим ID
        case invalidFileFormat     // Файл не в формате JSON-массива
        case invalidTransactionData  // Не хватает данных для создания Transaction
        case fileOperationFailed  // Ошибка чтения/записи файла
    }
}
