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
            let viewModel = TransactionsListViewModel(accountService: bankAccountService)
            let viewModel2 = AccountViewModel(bankAccountService: bankAccountService)
            
            ContentView()
                .task {
                    await viewModel.loadData(for: .outcome)
                    await viewModel2.loadBankAccount()
                }
                .environmentObject(viewModel)
                .environmentObject(viewModel2)
        }
    }
}
