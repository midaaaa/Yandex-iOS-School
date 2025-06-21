//
//  CategoriesService.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 12.06.2025.
//

final class CategoriesService {
    private var mockCategories = [
        Category(id: "1111", name: "Ремонт", icon: "🔨", type: Category.Direction.outcome),
        Category(id: "2222", name: "Зарплата", icon: "💼", type: Category.Direction.income)
        //Category(...),
        //Category(...),
    ]
    
    func categories() async throws -> [Category] {
        return mockCategories
    }
    
    func categories(ofType: Category.Direction) async throws -> [Category] {
        return mockCategories.filter { $0.type == ofType }
    }
}
