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
    private let localStorage: CategoryStorage
    
    init(localStorage: CategoryStorage = SwiftDataCategoryStorage.create()) {
        self.localStorage = localStorage
    }
    
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
        do {
            let dtos = try await fetchCategories()
            let networkCategories = dtos.map(map(dto:))
            
            try await localStorage.updateCategories(networkCategories)
            
            return networkCategories
            
        } catch {
            return try await localStorage.getAllCategories()
        }
    }
    
    func categories(ofType type: Category.Direction) async throws -> [Category] {
        do {
            let isIncome = (type == .income)
            let dtos = try await fetchCategories(isIncome: isIncome)
            let networkCategories = dtos.map(map(dto:))
            
            let allDtos = try await fetchCategories()
            let allNetworkCategories = allDtos.map(map(dto:))
            try await localStorage.updateCategories(allNetworkCategories)
            
            return networkCategories
            
        } catch {
            return try await localStorage.getCategories(ofType: type)
        }
    }
}
