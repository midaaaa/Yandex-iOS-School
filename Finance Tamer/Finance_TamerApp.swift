//
//  Finance_TamerApp.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 11.06.2025.
//

import SwiftUI

@main
struct Finance_TamerApp: App {
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            let sg = ServiceGroup()
            let viewModel = TransactionsListViewModel(
                accountService: sg.bankAccountService,
                categoryService: sg.categoryService,
                transactionService: sg.transactionService
            )
            let viewModel2 = AccountViewModel(bankAccountService: sg.bankAccountService, transactionsService: sg.transactionService)
            let viewModel3 = ArticlesViewModel(categoryService: sg.categoryService)
            
            if showSplash {
                LottieSplashView(animationName: "animation") {
                    withAnimation {
                        showSplash = false
                    }
                }
                .ignoresSafeArea()
            } else {
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
}

final class ServiceGroup: ObservableObject {
    let bankAccountService: BankAccountsService
    let categoryService: CategoriesService
    let transactionService: TransactionsService
    
    init() {
        let transactionStorage = SwiftDataTransactionStorage.create()
        let bankAccountStorage = SwiftDataBankAccountStorage.create()
        let categoryStorage = SwiftDataCategoryStorage.create()
        
        self.bankAccountService = BankAccountsService(localStorage: bankAccountStorage)
        self.categoryService = CategoriesService(localStorage: categoryStorage)
        self.transactionService = TransactionsService(
            localStorage: transactionStorage,
            bankAccountService: self.bankAccountService
        )
    }
}
