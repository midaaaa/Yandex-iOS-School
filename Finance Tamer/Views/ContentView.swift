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
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var isLoading: Bool {
        viewModel.isLoading || viewModel2.isLoading || viewModel3.isLoading
    }
    
    var error: String? {
        viewModel.error ?? viewModel2.error ?? viewModel3.error
    }

    @State private var showProgress: Bool = false
    private let minProgressTime: Double = 1
    
    @State private var progress: Double = 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
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
                if showProgress {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                        .frame(maxWidth: .infinity, minHeight: 6)
                        .background(Color(.systemBackground).opacity(0.95))
                        .padding(.bottom, tabBarHeight(geometry: geometry)+48)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onChange(of: error) {
            if let error, !error.isEmpty {
                alertMessage = error
                showAlert = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onChange(of: isLoading) {
            withAnimation {
                progress = isLoading ? 0.0 : 1.0
            }
            if isLoading {
                withAnimation { showProgress = true }
            } else if showProgress {
                DispatchQueue.main.asyncAfter(deadline: .now() + minProgressTime) {
                    withAnimation { showProgress = false }
                }
            }
        }
    }
}

private func tabBarHeight(geometry: GeometryProxy) -> CGFloat {
    let bottomInset = geometry.safeAreaInsets.bottom
    return bottomInset > 0 ? bottomInset : 49
}

#Preview {
    let serviceGroup = ServiceGroup()
    let viewModel = TransactionsListViewModel(
        accountService: serviceGroup.bankAccountService,
        categoryService: serviceGroup.categoryService,
        transactionService: serviceGroup.transactionService
    )
    let viewModel2 = AccountViewModel(bankAccountService: serviceGroup.bankAccountService, transactionsService: serviceGroup.transactionService)
    let viewModel3 = ArticlesViewModel(categoryService: serviceGroup.categoryService)
    ContentView()
        .task {
            await viewModel.loadData(for: .outcome)
            await viewModel2.loadBankAccount()
            await viewModel3.loadData()
        }
        .environmentObject(viewModel)
        .environmentObject(viewModel2)
        .environmentObject(viewModel3)
        .environmentObject(serviceGroup)
}
