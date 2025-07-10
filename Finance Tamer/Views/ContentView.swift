//
//  ContentView.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 11.06.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: TransactionsListViewModel
    @EnvironmentObject var viewModel2: AccountViewModel
    @EnvironmentObject var viewModel3: ArticlesViewModel

    var body: some View {
        TabView {
            Group {
                TransactionsListView(viewModel: viewModel, isIncome: .constant(false))
                    .tabItem {
                        Label("Расходы", image: "outcome")
                    }
                        .task {
                            await viewModel.loadData(for: .outcome)
                        }
                    .environmentObject(viewModel)
                
                TransactionsListView(viewModel: viewModel, isIncome: .constant(true))
                    .tabItem {
                        Label("Доходы", image: "income")
                    }
                        .task {
                            await viewModel.loadData(for: .income)
                        }
                    .environmentObject(viewModel)
                
                AccountView(viewModel: viewModel2)
                    .tabItem {
                        Label("Счёт", image: "account")
                    }
                        .task {
                            await viewModel2.loadBankAccount()
                        }
                    .environmentObject(viewModel2)
                
                ArticlesView(viewModel: viewModel3)
                    .tabItem {
                        Label("Статьи", image: "articles")
                    }
                        .task {
                            await viewModel3.loadData()
                        }
                    .environmentObject(viewModel3)
                
                Placeholder()
                    .tabItem {
                        Label("Настройки", image: "settings")
                    }
            }
            .toolbarBackgroundVisibility(.visible, for: .tabBar)
        }
    }
}

#Preview {
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
