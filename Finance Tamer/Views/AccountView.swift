//
//  AccountView.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 27.06.2025.
//

import SwiftUI
import Charts

struct AccountView: View {
    @ObservedObject var viewModel: AccountViewModel
    @EnvironmentObject var serviceGroup: ServiceGroup
    @FocusState private var isBalanceFocused: Bool
    @State var buttonDisabled: Bool = true
    @State var showCurrencyPicker: Bool = false
    @State var isBalanceHidden = true
    @State private var selectedStatType: StatType = .day
    @State private var selectedBar: BalanceHistoryEntry? = nil
    @State private var popupX: CGFloat? = nil
    @State private var popupY: CGFloat? = nil
    @State private var chartWidth: CGFloat = 0
    
    enum StatType: String, CaseIterable, Identifiable {
        case day = "Дни"
        case month = "Месяцы"
        var id: String { rawValue }
    }
    
    private enum Constants {
        static let iconSpacing: CGFloat = 4
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                List {
                    Section {
                        HStack {
                            Text("💰")
                            Text("Баланс")
                            Spacer()
                            ZStack(alignment: .trailing) {
                                if !viewModel.isEditing {
                                    HStack(spacing: Constants.iconSpacing) {
                                        Text(formatAmount(
                                            viewModel.bankAccount?.balance.description ?? "0",
                                            currencyCode: viewModel.bankAccount?.currency ?? "RUB",
                                            showMinus: true
                                        ))
                                        .spoiler(isOn: $isBalanceHidden)
                                    }
                                } else {
                                    TextField(
                                        "Введите Ваш баланс",
                                        text: Binding(
                                            get: {
                                                viewModel.bankAccount?.balance.description ?? "0"
                                            },
                                            set: { newValue in
                                                if let newBalance = Decimal(string: filterAmount(newValue)) {
                                                    viewModel.bankAccount?.balance = newBalance
                                                }
                                            }
                                        )
                                    )
                                    .keyboardType(.decimalPad)
                                    .focused($isBalanceFocused)
                                    .disabled(!viewModel.isEditing)
                                    .multilineTextAlignment(.trailing)
                                }
                            }
                        }
                    }
                    .listRowBackground(viewModel.isEditing ? Color.white : Color.accentColor)
                    
                    Section {
                        Button(action: {
                            showCurrencyPicker.toggle()
                        }) {
                            HStack {
                                Text("Валюта")
                                Spacer()
                                Text(viewModel.bankAccount?.currency.description.currencySymbol ?? "RUB")
                                    .foregroundStyle(.secondary)
                                if viewModel.isEditing {
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                        .listRowBackground(viewModel.isEditing ? Color.white : Color("SecondaryAccentColor"))
                        .disabled(buttonDisabled)
                        .confirmationDialog(
                            "Валюта",
                            isPresented: $showCurrencyPicker,
                            titleVisibility: .visible
                        ) {
                            ForEach(viewModel.getCurrencies(), id: \.self) { currency in
                                Button(getCurrencyDisplayName(for: currency)) {
                                    viewModel.bankAccount?.currency = currency
                                }
                            }
                        }
                        .tint(Color("OppositeAccentColor"))
                    }
                    
                    if !viewModel.isEditing {
                        Section {
                            Picker("Статистика", selection: $selectedStatType) {
                                ForEach(StatType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: .infinity)
                            .onChange(of: selectedStatType) {
                                Task { await viewModel.loadBalanceHistory(type: selectedStatType) }
                            }
                            
                            ZStack {
                                BalanceBarChart(
                                    entries: viewModel.balanceHistory(for: selectedStatType),
                                    selectedBar: $selectedBar,
                                    popupX: $popupX,
                                    popupY: $popupY,
                                    chartWidth: $chartWidth
                                )
                                .frame(height: 220)
                                if let selectedBar, let popupX, let popupY {
                                    let popupWidth: CGFloat = 160
                                    let popupHeight: CGFloat = 60
                                    let minX = popupWidth / 2
                                    let maxX = chartWidth - popupWidth / 2
                                    let clampedX = min(max(popupX, minX), maxX)
                                    let minY = popupHeight / 2
                                    let maxY = 220 - popupHeight / 2
                                    let clampedY = min(max(popupY - 40, minY), maxY)
                                    VStack {
                                        Text(selectedBar.label)
                                            .font(.caption)
                                        Text(formatAmount(selectedBar.balance.description, currencyCode: viewModel.bankAccount?.currency ?? "RUB", showMinus: true))
                                            .font(.headline)
                                            .foregroundColor(selectedBar.balance < 0 ? .red : .green)
                                    }
                                    .padding(8)
                                    .background(Color(.systemBackground).opacity(0.95))
                                    .cornerRadius(8)
                                    .shadow(radius: 4)
                                    .frame(width: popupWidth, height: popupHeight)
                                    .transition(.opacity)
                                    .position(x: clampedX, y: clampedY)
                                }
                            }
                            .animation(.easeInOut, value: selectedStatType)
                            .onAppear {
                                Task { await viewModel.loadBalanceHistory(type: selectedStatType) }
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .navigationTitle("Мой счёт")
                .listSectionSpacing(.compact)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(viewModel.isEditing ? "Сохранить" : "Редактировать") {
                            withAnimation {
                                viewModel.isEditing.toggle()
                                buttonDisabled.toggle()
                            }
                            
                            if !viewModel.isEditing, let bankAccount = viewModel.bankAccount {
                                Task {
                                    await viewModel.editBankAccount(
                                        amount: bankAccount.balance.description,
                                        currency: bankAccount.currency
                                    )
                                }
                            }
                        }
                        .foregroundColor(Color("OppositeAccentColor"))
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .refreshable {
                    Task {
                        await viewModel.loadBankAccount()
                    }
                }
            }
        }
    }
}
