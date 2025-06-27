//
//  TransactionsListHistoryViewModel.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 21.06.2025.
//

import Foundation

class TransactionsListHistoryViewModel: ObservableObject {
    @Published var account: BankAccount = .init(
        id: "1",
        name: "2",
        balance: 3,
        currency: "USD"
    )
    @Published var categories: [Category] = [
        .init(
            id: "1",
            name: "2",
            icon: "A",
            type: .income
        )
    ]
    @Published var transactions: [Transaction] = [
        .init(
            id: 1,
            accountId: "2",
            categoryId: "3",
            amount: 3,
            comment: "321",
            timestamp: Date(),
            hidden: false
        ),
        .init(
            id: 2,
            accountId: "2",
            categoryId: "3",
            amount: 3,
            comment: nil,
            timestamp: Date(),
            hidden: false
        )
    ]
    
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
    }
    
    private let accountService = BankAccountsService()
    private let categoryService = CategoriesService()
    private let transactionService = TransactionsService()
    
    var total: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
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
            self.error = nil
        } catch {
            self.error = "Ошибка загрузки данных"
            self.transactions = []
        }
    }
}
