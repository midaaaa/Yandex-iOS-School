//
//  TransactionsListView.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    @ObservedObject var viewModel: TransactionsListViewModel
    @Binding var isIncome: Bool
    @EnvironmentObject var serviceGroup: ServiceGroup
    @State private var showCreateSheet = false
    @State private var selectedTransaction: Transaction? = nil
    @State private var editViewModel: TransactionEditViewModel?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    Section {
                        HStack {
                            Text("Всего")
                            Spacer()
                            Text(
                                formatAmount(
                                    viewModel.total.description,
                                    currencyCode: viewModel.account.currency,
                                    showMinus: false
                                )
                            )
                        }
                    }
                    
                    Section("Операции") {
                        if viewModel.transactions.isEmpty {
                            Text("За сегодня транзакций нет")
                        } else {
                            ForEach(viewModel.transactions) { transaction in
                                Button {
                                    selectedTransaction = transaction
                                } label: {
                                    TransactionsListViewRow(
                                        transaction: transaction,
                                        category: viewModel.categories.first { $0.id == transaction.categoryId } ?? viewModel.categories[0],
                                        account: viewModel.account
                                    )
                                }
                            }
                        }
                    }
                }
                .fullScreenCover(item: $selectedTransaction) { transaction in
                    let category = viewModel.categories.first { $0.id == transaction.categoryId } ?? viewModel.categories[0]
                    TransactionEditView(
                        viewModel: TransactionEditViewModel(
                            transaction: transaction,
                            category: category,
                            account: viewModel.account,
                            transactionService: serviceGroup.transactionService,
                            categoryService: serviceGroup.categoryService,
                            accountService: serviceGroup.bankAccountService
                        ), onChange: {
                            Task { await viewModel.loadData(for: isIncome ? .income : .outcome) }
                        }
                    )
                }
                .toolbar {
                    NavigationLink {
                        TransactionsListHistoryView(isIncome: $isIncome, serviceGroup: serviceGroup)
                    } label: {
                        Image(systemName: "clock")
                    }
                    .foregroundColor(Color("OppositeAccentColor"))
                }
                .navigationTitle(isIncome ? "Доходы сегодня" : "Расходы сегодня")
                .listSectionSpacing(.compact)
                
                Button(action: { showCreateSheet = true }) {
                    AddButton()
                }
                .fullScreenCover(isPresented: $showCreateSheet) {
                    TransactionEditView(viewModel: TransactionEditViewModel(
                        direction: isIncome ? .income : .outcome,
                        transactionService: serviceGroup.transactionService,
                        categoryService: serviceGroup.categoryService,
                        accountService: serviceGroup.bankAccountService
                    ), onChange: {
                        Task { await viewModel.loadData(for: isIncome ? .income : .outcome) }
                    })
                }
            }
        }
        .tint(Color("OppositeAccentColor"))
    }
}

#Preview {
    let serviceGroup = ServiceGroup()
    let viewModel = TransactionsListViewModel(
        accountService: serviceGroup.bankAccountService,
        categoryService: serviceGroup.categoryService,
        transactionService: serviceGroup.transactionService
    )
    
    TransactionsListView(viewModel: viewModel, isIncome: .constant(true))
        .task {
            await viewModel.loadData(for: .income)
        }
}
