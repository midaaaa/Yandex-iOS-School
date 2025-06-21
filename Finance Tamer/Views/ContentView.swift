//
//  ContentView.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 11.06.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: TransactionsListViewModel
    @State private var selection: Tab = .expenses
    
    enum Tab {
        case expenses
        case incomes
        case count
        case articles
        case settings
    }
    
    var body: some View {
        VStack {
            TabView(selection: $selection) {
                TransactionsListView(viewModel: viewModel, isIncome: .constant(false))
                    .tabItem {
                        Label("Расходы", systemImage: "arrow.up.forward.square")
                    }
                    .task {
                        await viewModel.loadData(for: .outcome)
                    }
                    .environmentObject(viewModel)
                    .tag(Tab.expenses)

                TransactionsListView(viewModel: viewModel, isIncome: .constant(true))
                    .tabItem {
                        Label("Доходы", systemImage: "arrow.down.forward.square")
                    }
                    .task {
                        await viewModel.loadData(for: .income)
                    }
                    .environmentObject(viewModel)
                    .tag(Tab.incomes)
                
                Placeholder()
                    .tabItem {
                        Label("Счёт", systemImage: "calendar")
                    }
                Placeholder()
                    .tabItem {
                        Label("Статьи", systemImage: "align.horizontal.left")
                    }
                Placeholder()
                    .tabItem {
                        Label("Настройки", systemImage: "gear")
                    }
            }
        }
    }
}

#Preview {
    let viewModel = TransactionsListViewModel()
    
    ContentView()
        .task {
            await viewModel.loadData(for: .outcome)
        }
        .environmentObject(viewModel)
}
