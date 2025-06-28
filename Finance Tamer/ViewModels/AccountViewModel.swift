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
    private static let currencies = ["RUB", "USD", "EUR", "GBP", "CNY"]
    
    init(bankAccountService: BankAccountsService) {
        self.bankAccountService = bankAccountService
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
}
