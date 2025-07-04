//
//  Finance_TamerApp.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 11.06.2025.
//

import SwiftUI

@main
struct Finance_TamerApp: App {
    var body: some Scene {
        WindowGroup {
            let bankAccountService = BankAccountsService()
            let categoryService = CategoriesService()
            let viewModel = TransactionsListViewModel(accountService: bankAccountService)
            let viewModel2 = AccountViewModel(bankAccountService: bankAccountService)
            let viewModel3 = ArticlesViewModel(categoryService: categoryService)
            
            ContentView()
                .task {
                    await viewModel.loadData(for: .outcome)
                    await viewModel2.loadBankAccount()
                    await viewModel3.loadData()
                }
                .environmentObject(viewModel)
                .environmentObject(viewModel2)
                .environmentObject(viewModel3)
        }
    }
}
