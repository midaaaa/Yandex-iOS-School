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
    @State private var selection: Tab = .expenses
    
    enum Tab {
        case expenses
        case incomes
        case account
        case articles
        case settings
    }
    
    var body: some View {
        VStack {
            TabView(selection: $selection) {
                TransactionsListView(viewModel: viewModel, isIncome: .constant(false))
                    .tabItem {
                        Label("Расходы", image: "outcome")
                    }
                    .task {
                        await viewModel.loadData(for: .outcome)
                    }
                    .environmentObject(viewModel)
                    .tag(Tab.expenses)

                TransactionsListView(viewModel: viewModel, isIncome: .constant(true))
                    .tabItem {
                        Label("Доходы", image: "income")
                    }
                    .task {
                        await viewModel.loadData(for: .income)
                    }
                    .environmentObject(viewModel)
                    .tag(Tab.incomes)
                
                AccountView(viewModel: viewModel2)
                    .tabItem {
                        Label("Счёт", image: "account")
                    }
                    .task {
                        await viewModel2.loadBankAccount()
                    }
                    .environmentObject(viewModel2)
                    .tag(Tab.account)
                
                Placeholder()
                    .tabItem {
                        Label("Статьи", image: "articles")
                    }
                
                Placeholder()
                    .tabItem {
                        Label("Настройки", image: "settings")
                    }
            }
        }
    }
}

#Preview {
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
