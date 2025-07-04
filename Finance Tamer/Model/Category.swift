//
//  Category.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 11.06.2025.
//

import Foundation

struct Category: Identifiable, FuzzySearchable {
    var id: String
    var name: String
    var icon: Character
    var type: Direction
    
    var searchableString: String {
        return name
    }
    
    enum Direction {
        case income
        case outcome
    }
}
/*
// MARK: Codable (posible use in future)

import Foundation

struct Category2: Codable {
    var id: String
    var name: String
    var icon: Character
    var type: Directions
    
    enum Directions: String,Codable {
        case income = "income"
        case outcome = "outcome"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, icon, type
    }
    
    init(id: String, name: String, icon: Character, type: Directions) {
        self.id = id
        self.name = name
        self.icon = icon
        self.type = type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        let iconString = try container.decode(String.self, forKey: .icon)
        guard let firstChar = iconString.first else {
            throw DecodingError.dataCorruptedError(forKey: .icon, in: container, debugDescription: "Icon string is empty")
        }
        icon = firstChar
        
        type = try container.decode(Directions.self, forKey: .type)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(String(icon), forKey: .icon)
        try container.encode(type, forKey: .type)
    }
}

extension Category2 {
    static func parse(jsonObject: Any) -> Category2? {
        guard let data = try? JSONSerialization.data(withJSONObject: jsonObject) else {
            return nil
        }
        return try? JSONDecoder().decode(Category2.self, from: data)
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
