//
//  CategoryEntity.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation
import SwiftData

@Model
final class CategoryEntity {
    var id: String
    var name: String
    var icon: String
    var type: String
    
    init(from category: Category) {
        self.id = category.id
        self.name = category.name
        self.icon = String(category.icon)
        self.type = category.type == .income ? "income" : "outcome"
    }
    
    func toCategory() -> Category {
        return Category(
            id: id,
            name: name,
            icon: icon.first ?? " ",
            type: type == "income" ? .income : .outcome
        )
    }
} 
