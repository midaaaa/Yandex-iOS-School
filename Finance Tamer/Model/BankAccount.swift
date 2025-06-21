//
//  BankAccount.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 11.06.2025.
//

import Foundation

struct BankAccount: Codable {
    var id: String
    //var userId: Int
    var name: String
    var balance: Decimal
    var currency: String
    //var createdAt: String
    //var updatedAt: String
}
/*
// MARK: Codable (posible use in future)

extension BankAccount {
    static func parse(jsonObject: Any) -> BankAccount? {
        guard let data = try? JSONSerialization.data(withJSONObject: jsonObject) else {
            return nil
        }
        return try? JSONDecoder().decode(BankAccount.self, from: data)
    }
    
    var jsonObject: Any {
        guard let data = try? JSONEncoder().encode(self),
              let json = try? JSONSerialization.jsonObject(with: data) else {
            return [:]
        }
        return json
    }
}
*/
