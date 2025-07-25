//
//  TransactionsListViewRow.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 20.06.2025.
//

import SwiftUI

struct TransactionsListViewRow: View {
    private enum Constants {
        static let iconFrameSize: CGFloat = 30
        static let rowHeight: CGFloat = 35
    }
    
    var transaction: Transaction
    var category: Category
    var account: BankAccount
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .foregroundColor(Color("SecondaryAccentColor"))
                Text(String(category.icon))
            }
            .frame(width: Constants.iconFrameSize, height: Constants.iconFrameSize)
            VStack(alignment: .leading) {
                Text(category.name)
                if let comment = transaction.comment {
                    Text(comment)
                        .font(.footnote)
                        .fontWeight(.ultraLight)
                }
            }
            Spacer()
            Text(
                formatAmount(
                    transaction.amount.description,
                    currencyCode: account.currency,
                    showMinus: false
                )
            )
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .tint(.primary)
        .frame(height: Constants.rowHeight)
    }
}

#Preview {
    let serviceGroup = ServiceGroup()
    let viewModel = TransactionsListViewModel(
        accountService: serviceGroup.bankAccountService,
        categoryService: serviceGroup.categoryService,
        transactionService: serviceGroup.transactionService
    )
    
    Group {
        TransactionsListViewRow(
            transaction: viewModel.transactions[0],
            category: viewModel.categories[0],
            account: viewModel.account
        )
        .task {
            await viewModel.loadData(for: .income)
        }
        
        Divider()
        
        TransactionsListViewRow(
            transaction: viewModel.transactions[0],
            category: viewModel.categories[0],
            account: viewModel.account
        )
        .task {
            await viewModel.loadData(for: .income)
        }
    }
}
