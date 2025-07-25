//
//  TransactionsListViewModel.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 20.06.2025.
//

import Foundation

final class ArticlesViewModel: ObservableObject {
    @Published var categories: [Category]?
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var searchText = ""
    
    private let categoryService: CategoriesService
    
    var filteredCategories: [Category] {
        guard let categories = categories else { return [] }
        
        if searchText.isEmpty {
            return categories
        } else {
            return categories.fuzzySearch(searchText).map { $0.item }
        }
    }

    init(categoryService: CategoriesService) {
        self.categoryService = categoryService
    }
    
    @MainActor
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let categories = categoryService.categories()
            
            let fetchedCategories = try await categories
            
            self.categories = fetchedCategories
            self.error = nil
        } catch {
            self.error = "Ошибка загрузки данных"
        }
    }
}
