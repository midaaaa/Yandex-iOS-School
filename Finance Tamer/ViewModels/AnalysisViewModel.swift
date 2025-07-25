//
//  AnalysisViewModel.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 09.07.2025.
//

import Foundation
import PieChart

class AnalysisViewModel: ObservableObject {
    @Published var account: BankAccount = .init(
        id: "1",
        name: "2",
        balance: 3,
        currency: "USD"
    )
    @Published var categories: [Category] = []
    @Published var transactions: [Transaction] = []
    
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    enum SortType {
        case byDate
        case byAmount
    }
    
    @Published var sortType: SortType = .byDate {
        didSet {
            sortTransactions()
        }
    }
    
    // greater values on top
    private func sortTransactions() {
        switch sortType {
        case .byDate:
            transactions.sort { $0.timestamp > $1.timestamp }
        case .byAmount:
            transactions.sort { abs($0.amount) > abs($1.amount) }
        }
        updateChartEntities()
    }
    
    private let accountService: BankAccountsService
    private let categoryService: CategoriesService
    private let transactionService: TransactionsService
    
    init(accountService: BankAccountsService, categoryService: CategoriesService, transactionService: TransactionsService) {
        self.accountService = accountService
        self.categoryService = categoryService
        self.transactionService = transactionService
    }
    
    var total: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    var chartEntities: [Entity] = []

    private func updateChartEntities() {
        let grouped = Dictionary(grouping: transactions) { $0.categoryId ?? "" }
        let categorySums: [(category: Category, sum: Decimal)] = categories.compactMap { category in
            guard let txs = grouped[category.id], !txs.isEmpty else { return nil }
            let sum = txs.reduce(Decimal(0)) { $0 + $1.amount }
            return (category, sum)
        }
        .filter { $0.sum != 0 }
        .sorted { abs($0.sum) > abs($1.sum) }
        
        let entities: [Entity] = categorySums.map { Entity(value: $0.sum, label: $0.category.name) }
        self.chartEntities = entities
    }
    
    @MainActor
    func loadData(for direction: Category.Direction, from startDate: Date?, to endDate: Date?) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let calendar = Calendar.current
            let safeStartDate = calendar.startOfDay(for: startDate ?? Date())
            guard let safeEndDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate ?? Date()))?
                .addingTimeInterval(-1)
            else { return }
            
            async let account = accountService.bankAccount()
            async let categories = categoryService.categories(ofType: direction)
            async let transactions = transactionService.getTransactions(from: safeStartDate, to: safeEndDate)
            
            let (
                fetchedAccount,
                fetchedCategories,
                fetchedTransactions
            ) = await (try account, try categories, try transactions)
            
            let validCategoryIds = fetchedCategories.map { $0.id }
            let filteredTransactions = fetchedTransactions.filter {
                validCategoryIds.contains($0.categoryId ?? "")
            }
            
            self.account = fetchedAccount
            self.categories = fetchedCategories
            self.transactions = filteredTransactions
            sortTransactions()
            updateChartEntities()
        } catch {
            self.error = "Ошибка загрузки данных"
            self.transactions = []
            self.chartEntities = []
        }
    }
}
