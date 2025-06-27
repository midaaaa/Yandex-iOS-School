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
                    
                    Section {
                        ForEach(viewModel.transactions) { transaction in
                            NavigationLink{
                                Placeholder()
                            } label: {
                                TransactionsListViewRow(
                                    transaction: transaction,
                                    category: viewModel.categories.first { $0.id == transaction.categoryId } ?? viewModel.categories[0],
                                    account: viewModel.account
                                )
                            }
                        }
                    } header: {
                        Text("Операции")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                // too long for animation
                .navigationTitle(isIncome ? "Доходы сегодня" : "Расходы сегодня")
                .toolbar {
                    NavigationLink {
                        TransactionsListHistoryView(isIncome: $isIncome)
                    } label: {
                        Image(systemName: "clock")
                    }
                }
                
                NavigationLink {
                    Placeholder()
                } label: {
                    AddButton()
                }
            }
        }
    }
}

#Preview {
    let viewModel = TransactionsListViewModel()
    TransactionsListView(viewModel: viewModel, isIncome: .constant(true))
        .task {
            await viewModel.loadData(for: .income)
        }
}
