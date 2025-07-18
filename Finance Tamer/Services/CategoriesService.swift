//
//  CategoriesService.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 12.06.2025.
//

import Foundation

struct CategoryDTO: Codable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
}

@Observable
final class CategoriesService {
    private let networkClient = NetworkClient()
    
    func fetchCategories() async throws -> [CategoryDTO] {
        try await networkClient.request(
            path: "categories",
            method: "GET",
            body: Optional<String>.none
        )
    }
    
    func fetchCategories(isIncome: Bool) async throws -> [CategoryDTO] {
        try await networkClient.request(
            path: "categories/type/\(isIncome)",
            method: "GET",
            body: Optional<String>.none
        )
    }
}

extension CategoriesService {
    private func map(dto: CategoryDTO) -> Category {
        Category(
            id: String(dto.id),
            name: dto.name,
            icon: dto.emoji.first ?? " ",
            type: dto.isIncome ? .income : .outcome
        )
    }
    
    func categories() async throws -> [Category] {
        let dtos = try await fetchCategories()
        return dtos.map(map(dto:))
    }
    
    func categories(ofType type: Category.Direction) async throws -> [Category] {
        let isIncome = (type == .income)
        let dtos = try await fetchCategories(isIncome: isIncome)
        return dtos.map(map(dto:))
    }
}
