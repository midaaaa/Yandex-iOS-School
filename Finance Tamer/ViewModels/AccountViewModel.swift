//
//  AccountViewModel.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 27.06.2025.
//

import Foundation

class AccountViewModel: ObservableObject {
    @Published var bankAccount: BankAccount?
    @Published var isEditing: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var isBalanceHidden: Bool = false
    private let bankAccountService: BankAccountsService
    private let transactionsService: TransactionsService
    private static let currencies = ["RUB", "USD", "EUR", "GBP", "CNY"]
    @Published private var balanceHistoryEntries: [AccountView.StatType: [BalanceHistoryEntry]] = [:]
    
    init(bankAccountService: BankAccountsService, transactionsService: TransactionsService) {
        self.bankAccountService = bankAccountService
        self.transactionsService = transactionsService
    }
    
    func getCurrencies() -> [String] {
        Self.currencies
    }
    
    @MainActor
    func loadBankAccount() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            bankAccount = try await bankAccountService.bankAccount()
            self.error = nil
        } catch {
            self.error = "Ошибка загрузки"
        }
    }
    
    @MainActor
    func editBankAccount(amount: String, currency: String) async {
        // currency is enum
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard var bankAccount = bankAccount else { return }
            bankAccount.balance = Decimal(string: amount) ?? bankAccount.balance
            bankAccount.currency = currency
            
            try await bankAccountService.editBankAccount(bankAccount)
            self.error = nil
            
            await loadBankAccount()
        } catch {
            self.error = "Ошибка загрузки"
        }
    }
    
    func balanceHistory(for type: AccountView.StatType) -> [BalanceHistoryEntry] {
        balanceHistoryEntries[type] ?? []
    }
    
    @MainActor
    func loadBalanceHistory(type: AccountView.StatType) async {
        guard let account = bankAccount else { return }
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date
        let endDate: Date = now
        switch type {
        case .day:
            startDate = calendar.date(byAdding: .day, value: -29, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -23, to: now) ?? now
        }
        do {
            let categoriesService = CategoriesService()
            let allCategories = try await categoriesService.categories()
            let categoryMap = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0.type) })
            
            let transactions = try await transactionsService.getTransactions(from: startDate, to: endDate)
                .filter { $0.accountId == account.id }
                .sorted { $0.timestamp < $1.timestamp }
            var entries: [BalanceHistoryEntry] = []
            let balanceToday = account.balance
            
            switch type {
            case .day:
                var dateBalances: [Date: Decimal] = [:]
                var runningBalance = balanceToday
                for offset in 0..<30 {
                    let day = calendar.date(byAdding: .day, value: -offset, to: now) ?? now
                    let dayStart = calendar.startOfDay(for: day)
                    let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)?.addingTimeInterval(-1) ?? dayStart
                    let dayTxs = transactions.filter { $0.timestamp >= dayStart && $0.timestamp <= dayEnd }
                    
                    let daySum = dayTxs.reduce(Decimal(0)) { sum, tx in
                        let type = categoryMap[tx.categoryId ?? ""] ?? .outcome
                        return sum + (type == .income ? tx.amount : -tx.amount)
                    }
                    dateBalances[dayStart] = runningBalance
                    runningBalance -= daySum
                }
                let sorted = dateBalances.sorted { $0.key < $1.key }
                entries = sorted.map { BalanceHistoryEntry(label: DateFormatter.shortDate.string(from: $0.key), balance: $0.value) }
                
            case .month:
                var dateBalances: [Date: Decimal] = [:]
                var runningBalance = balanceToday
                for offset in 0..<24 {
                    let month = calendar.date(byAdding: .month, value: -offset, to: now) ?? now
                    let comps = calendar.dateComponents([.year, .month], from: month)
                    let monthStart = calendar.date(from: comps) ?? month
                    let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)?.addingTimeInterval(-1) ?? monthStart
                    let monthTxs = transactions.filter { $0.timestamp >= monthStart && $0.timestamp <= monthEnd }
                    let monthSum = monthTxs.reduce(Decimal(0)) { sum, tx in
                        let type = categoryMap[tx.categoryId ?? ""] ?? .outcome
                        return sum + (type == .income ? tx.amount : -tx.amount)
                    }
                    dateBalances[monthStart] = runningBalance
                    runningBalance -= monthSum
                }
                let sorted = dateBalances.sorted { $0.key < $1.key }
                entries = sorted.map { BalanceHistoryEntry(label: DateFormatter.shortMonth.string(from: $0.key), balance: $0.value) }
            }
            
            balanceHistoryEntries[type] = entries
        } catch {
            balanceHistoryEntries[type] = []
        }
    }
}

private extension DateFormatter {
    static let shortDate: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM"
        return df
    }()
    static let shortMonth: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM.yy"
        return df
    }()
}
