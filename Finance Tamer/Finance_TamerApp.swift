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
            let sg = ServiceGroup()
            let viewModel = TransactionsListViewModel(
                accountService: sg.bankAccountService,
                categoryService: sg.categoryService,
                transactionService: sg.transactionService
            )
            let viewModel2 = AccountViewModel(bankAccountService: sg.bankAccountService)
            let viewModel3 = ArticlesViewModel(categoryService: sg.categoryService)
            
            ContentView()
                .task {
                    await viewModel.loadData(for: .outcome)
                    await viewModel2.loadBankAccount()
                    await viewModel3.loadData()
                }
                .environmentObject(viewModel)
                .environmentObject(viewModel2)
                .environmentObject(viewModel3)
                .environmentObject(sg)
        }
    }
}

class ServiceGroup: ObservableObject {
    let bankAccountService = BankAccountsService()
    let categoryService = CategoriesService()
    let transactionService = TransactionsService()
}
