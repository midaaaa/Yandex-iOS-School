//
//  TransactionEditViewModel.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 10.07.2025.
//

import Foundation

class TransactionEditViewModel: ObservableObject {
    @Published var id: Int? = nil
    @Published var account: BankAccount? = nil
    @Published var category: Category? = nil
    @Published var categories: [Category] = []
    @Published var amount: String = ""
    @Published var comment: String = ""
    @Published var date: Date = Date()
    @Published var isIncome: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var showCategoryPicker: Bool = false
    @Published var showAlert: Bool = false
    
    private let transactionService: TransactionsService
    private let categoryService: CategoriesService
    private let accountService: BankAccountsService

    init(direction: Category.Direction, 
         transactionService: TransactionsService,
         categoryService: CategoriesService,
         accountService: BankAccountsService) {
        self.transactionService = transactionService
        self.categoryService = categoryService
        self.accountService = accountService
        self.isIncome = (direction == .income)
        Task {
            await loadCategories(direction: direction)
            await loadAccount()
        }
    }
    
    init(transaction: Transaction, category: Category, account: BankAccount,
         transactionService: TransactionsService,
         categoryService: CategoriesService,
         accountService: BankAccountsService
    ) {
        self.transactionService = transactionService
        self.categoryService = categoryService
        self.accountService = accountService
        self.id = transaction.id
        self.account = account
        self.amount = abs(transaction.amount).description.replacingOccurrences(
            of: ".",
            with: Locale.current.decimalSeparator ?? "."
        )
        self.comment = transaction.comment ?? ""
        self.date = transaction.timestamp
        self.category = category
        self.isIncome = (category.type == .income)
        self.categories = [category]
        Task {
            await loadCategories(direction: category.type)
        }
    }
    
    @MainActor
    func loadCategories(direction: Category.Direction) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let cats = try await categoryService.categories(ofType: direction)
            self.categories = cats
        } catch {
            self.error = "Ошибка загрузки категорий"
        }
    }
    
    @MainActor
    func loadAccount() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let acc = try await accountService.bankAccount()
            self.account = acc
        } catch {
            self.error = "Ошибка загрузки счёта"
        }
    }
    
    @MainActor
    func save() async {
        guard let account = account, let category = category else {
            self.error = "Заполните все поля корректно"
            self.showAlert = true
            return
        }
        
        let locale = Locale.current
        let decimalSeparator = locale.decimalSeparator ?? "."
        let cleanedAmount = amount.replacingOccurrences(of: decimalSeparator, with: ".")
        guard let amountDecimal = Decimal(string: cleanedAmount), amountDecimal > 0 else {
            self.error = "Введите корректную сумму"
            self.showAlert = true
            return
        }
        let finalAmount = amountDecimal
        let finalComment: String? = comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : comment
        let transaction = Transaction(
            id: id ?? Int(Date().timeIntervalSince1970),
            accountId: account.id,
            categoryId: category.id,
            amount: finalAmount,
            comment: finalComment,
            timestamp: date,
            hidden: false
        )
        isLoading = true
        defer { isLoading = false }
        do {
            if id == nil {
                try await transactionService.createTransaction(transaction)
            } else {
                try await transactionService.editTransaction(transaction)
            }
        } catch {
            self.error = "Ошибка сохранения"
            self.showAlert = true
        }
    }
    
    @MainActor
    func deleteTransaction() async {
        guard let id = id else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await transactionService.removeTransaction(withId: id)
            self.error = nil
            self.showAlert = false
        } catch {
            self.error = "Ошибка удаления"
            self.showAlert = true
        }
    }
    

} 
