//
//  TransactionsListHistoryView.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 21.06.2025.
//

import SwiftUI

struct TransactionsListHistoryView: View {
    @StateObject var viewModel = TransactionsListHistoryViewModel()
    
    @Binding var isIncome: Bool
    
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
                            NavigationLink {
                                Placeholder()
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
            .navigationTitle("Моя история")
            .listSectionSpacing(.compact)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        Placeholder()
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
    let viewModel = TransactionsListHistoryViewModel()
    
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
    
    TransactionsListHistoryView(viewModel: viewModel, isIncome: .constant(true))
        .task {
            await viewModel.loadData(for: .income, from: startDate, to: endDate)
        }
}
