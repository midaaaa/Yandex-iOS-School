//
//  TransactionsListHistoryView.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 21.06.2025.
//

import SwiftUI

struct TransactionsListHistoryView: View {
    @StateObject var viewModel: TransactionsListHistoryViewModel
    @State private var selectedTransaction: Transaction? = nil
    @EnvironmentObject var serviceGroup: ServiceGroup
    
    @Binding var isIncome: Bool
    
    init(isIncome: Binding<Bool>, serviceGroup: ServiceGroup) {
        self._isIncome = isIncome
        self._viewModel = StateObject(wrappedValue: TransactionsListHistoryViewModel(
            accountService: serviceGroup.bankAccountService,
            categoryService: serviceGroup.categoryService,
            transactionService: serviceGroup.transactionService
        ))
    }
    
    @State private var startDate: Date = {
        let calendar = Calendar.current
        guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) else {
            return calendar.startOfDay(for: Date())
        }
        return calendar.startOfDay(for: oneMonthAgo)
    }()

    @State private var endDate: Date = {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        guard let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            return startOfToday
        }
        return endOfToday.addingTimeInterval(-1)
    }()

    private var startDateBinding: Binding<Date> {
        Binding(
            get: { startDate },
            set: { newValue in
                let calendar = Calendar.current
                let newStart = calendar.startOfDay(for: newValue)
                startDate = newStart
                
                if newStart > endDate {
                    if let newEnd = calendar.date(byAdding: .day, value: 1, to: newStart) {
                        endDate = newEnd.addingTimeInterval(-1)
                    }
                }
            }
        )
    }

    private var endDateBinding: Binding<Date> {
        Binding(
            get: { endDate },
            set: { newValue in
                let calendar = Calendar.current
                let startOfNewDay = calendar.startOfDay(for: newValue)
                if let newEnd = calendar.date(byAdding: .day, value: 1, to: startOfNewDay) {
                    let adjustedEnd = newEnd.addingTimeInterval(-1)
                    endDate = adjustedEnd
                    
                    if adjustedEnd < startDate {
                        startDate = startOfNewDay
                    }
                }
            }
        )
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    DatePicker("Начало", selection: startDateBinding, displayedComponents: .date)
                        .tint(Color("AccentColor"))
                    
                    DatePicker("Конец", selection: endDateBinding, displayedComponents: .date)
                        .tint(Color("AccentColor"))
                    
                    Picker("Сортировка", selection: $viewModel.sortType) {
                        Text("По дате").tag(TransactionsListHistoryViewModel.SortType.byDate)
                        Text("По сумме").tag(TransactionsListHistoryViewModel.SortType.byAmount)
                    }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 4)
                    HStack {
                        Text("Сумма")
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
                        Text("Нет операций")
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
            .sheet(item: $selectedTransaction) { transaction in
                let category = viewModel.categories.first { $0.id == transaction.categoryId } ?? viewModel.categories[0]
                TransactionEditView(
                    viewModel: TransactionEditViewModel(
                        transaction: transaction,
                        category: category,
                        account: viewModel.account,
                        transactionService: serviceGroup.transactionService,
                        categoryService: serviceGroup.categoryService,
                        accountService: serviceGroup.bankAccountService
                    )
                )
            }
            .navigationTitle("Моя история")
            .listSectionSpacing(.compact)
                            .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink {
                            AnalysisView(viewModel: AnalysisViewModel(
                                accountService: serviceGroup.bankAccountService,
                                categoryService: serviceGroup.categoryService,
                                transactionService: serviceGroup.transactionService
                            ), isIncome: isIncome)
                        } label: {
                        Image(systemName: "doc")
                    }
                    .foregroundColor(Color("OppositeAccentColor"))
                }
            }
            .onChange(of: startDate, initial: true) { _,_  in
                Task {
                    await viewModel.loadData(
                        for: isIncome ? .income : .outcome,
                        from: startDate,
                        to: endDate
                    )
                }
            }
            .onChange(of: endDate, initial: true) { _,_ in
                Task {
                    await viewModel.loadData(
                        for: isIncome ? .income : .outcome,
                        from: startDate,
                        to: endDate
                    )
                }
            }
        }
    }
}

#Preview {
    let serviceGroup = ServiceGroup()
    let viewModel = TransactionsListHistoryViewModel(
        accountService: serviceGroup.bankAccountService,
        categoryService: serviceGroup.categoryService,
        transactionService: serviceGroup.transactionService
    )
    
    let startDate: Date = {
        let calendar = Calendar.current
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        return calendar.startOfDay(for: oneMonthAgo)
    }()

    let endDate: Date = {
        let calendar = Calendar.current
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!
            .addingTimeInterval(-1)
        return endOfToday
    }()
    
    TransactionsListHistoryView(isIncome: .constant(true), serviceGroup: serviceGroup)
        .task {
            await viewModel.loadData(for: .income, from: startDate, to: endDate)
        }
}
