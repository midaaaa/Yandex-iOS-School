//
//  Transaction.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 11.06.2025.
//

import Foundation

struct Transaction: Codable, Identifiable {
    var id: Int
    var accountId: String?
    var categoryId: String?
    var amount: Decimal  // only Decimal decoded from String
    //var transactionDate: Date
    var comment: String?
    var timestamp: Date
    var hidden: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id, accountId, categoryId, amount, comment, timestamp, hidden
    }
    
    init(
        id: Int,
        accountId: String?,
        categoryId: String?,
        amount: Decimal,
        comment: String?,
        timestamp: Date,
        hidden: Bool
    ) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.comment = comment
        self.timestamp = timestamp
        self.hidden = hidden
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        accountId = try container.decodeIfPresent(String.self, forKey: .accountId)
        categoryId = try container.decodeIfPresent(String.self, forKey: .categoryId)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        hidden = try container.decode(Bool.self, forKey: .hidden)
        
        guard let amountString = try? container.decode(String.self, forKey: .amount),
              let decimalAmount = Decimal(string: amountString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .amount,
                in: container,
                debugDescription: "Invalid decimal string format"
            )
        }
        amount = decimalAmount
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(accountId, forKey: .accountId)
        try container.encodeIfPresent(categoryId, forKey: .categoryId)
        try container.encode(amount.description, forKey: .amount)
        try container.encodeIfPresent(comment, forKey: .comment)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(hidden, forKey: .hidden)
    }
}

// MARK: Transaction JSON Extension

extension Transaction {
    static func parse(jsonObject: Any) -> Transaction? {
        guard let data = try? JSONSerialization.data(withJSONObject: jsonObject) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try? decoder.decode(Transaction.self, from: data)
    }
    
    var jsonObject: Any {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .sortedKeys
        
        guard let data = try? encoder.encode(self),
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
