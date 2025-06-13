//
//  Transaction.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 11.06.2025.
//

import Foundation

struct Transaction: Codable {
    var id: Int
    var accountId: String?
    var categoryId: String?
    var amount: Decimal // value Decimal?
    //var transactionDate: Date
    var comment: String?
    var timestamp: Date // Int?
    var hidden: Bool
}

extension Transaction {
    static func parse(jsonObject: Any) -> Transaction? {
        guard let data = try? JSONSerialization.data(withJSONObject: jsonObject) else {
            return nil  // throw Error.invalidTransactionData
        }
        return try? JSONDecoder().decode(Transaction.self, from: data)
    }
    
    var jsonObject: Any {
        guard let data = try? JSONEncoder().encode(self),
              let json = try? JSONSerialization.jsonObject(with: data) else {
            return [:]
        }
        return json
    }
}

// MARK: Transaction CSV Extension

extension Transaction {
    static func parse(csvObject: Any) -> Transaction? {
        let components = (csvObject as AnyObject).components(separatedBy: ",")
        guard components.count >= 7 else { return nil }
        
        guard let id = Int(components[0]),
              let amount = Decimal(string: components[3]),
              let timestamp = parseDate(components[5]),
              let hidden = Bool(components[6]) else {
            return nil
        }
        
        let accountId = components[1]
        let categoryId = components[2]
        let comment = components[4].isEmpty ? nil : components[4]
        
        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            comment: comment,
            timestamp: timestamp,
            hidden: hidden
        )
    }
    
    private static let csvDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    private static func parseDate(_ string: String) -> Date? {
        if let timestamp = TimeInterval(string) {
            return Date(timeIntervalSince1970: timestamp)
        }
        return csvDateFormatter.date(from: string)
    }
    
    var csvObject: Any {
        let dateString = Self.csvDateFormatter.string(from: timestamp)
        return [
            String(id),
            accountId ?? "",
            categoryId ?? "",
            amount.description,
            comment ?? "",
            dateString,
            String(hidden)
        ].joined(separator: ",")
    }
}

