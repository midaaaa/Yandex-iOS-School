//
//  AccountView.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 27.06.2025.
//

import SwiftUI

struct AccountView: View {
    @ObservedObject var viewModel: AccountViewModel
    @FocusState private var isBalanceFocused: Bool
    @State var buttonDisabled: Bool = true
    @State var showCurrencyPicker: Bool = false
    @State var isBalanceHidden = true

    private enum Constants {
        static let iconSpacing: CGFloat = 4
    }
    
    var body: some View {
        NavigationStack {
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

#Preview {
    let bankAccountService = BankAccountsService()
    let viewModel = AccountViewModel(bankAccountService: bankAccountService)
    
    AccountView(viewModel: viewModel)
        .task {
            await viewModel.loadBankAccount()
        }
}
