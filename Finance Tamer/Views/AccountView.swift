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
        
    func toggleBalanceVisibility() {
        withAnimation(.spring()) {
            isBalanceHidden.toggle()
        }
    }
    
    
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("💰")
                        Text("Баланс")
                        Spacer()
                        //if viewModel.isEditing {
                        ZStack(alignment: .trailing) {
                            if !viewModel.isEditing {
                                HStack(spacing: 4) {
                                    Text(formatAmount(
                                        viewModel.bankAccount?.balance.description ?? "7770",
                                        currencyCode: viewModel.bankAccount?.currency ?? "GBP",
                                        showMinus: true
                                    ))
                                    //.spoiler(isOn: $isBalanceHidden)
                                }
                                //.transition(.opacity.combined(with: .scale(scale: 0.01)))
                                //.animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isEditing)
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
//                                            if let newBalance = Decimal(string: newValue) {
//                                                viewModel.bankAccount?.balance = newBalance
//                                            }
                                        }
                                    )
                                )
                                .keyboardType(.numbersAndPunctuation)
                                .focused($isBalanceFocused)
                                .disabled(!viewModel.isEditing)
                                //.padding()
                                //.background(Color(.systemGray6))
                                //.cornerRadius(8) // ???
                                .multilineTextAlignment(.trailing)
                                //.transition(.opacity.combined(with: .scale(scale: 0.01)))
                                
                                //.animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isEditing)
//                                .onAppear {
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                        isBalanceFocused = true
//                                    }
//                                }
                            }
                            
                            
                        }
                        
                        /*
                            TextField(
                                "Сумма",
                                text: Binding(
                                    get: {
//                                        if viewModel.isEditing {
//                                            viewModel.bankAccount?.balance.description ?? "0"
//                                        } else {
                                            formatAmount(
                                                viewModel.bankAccount?.balance.description ?? "555555",
                                                currencyCode: viewModel.bankAccount?.currency ?? "GBP",
                                                showMinus: true
                                            )
                                        //}
                                        //viewModel.bankAccount?.balance.description ?? "0"
                                    },
                                    set: { newValue in
                                        if let newBalance = Decimal(string: newValue) {
                                            viewModel.bankAccount?.balance = newBalance
                                        }
                                    }
                                )
                            )
                                .keyboardType(.decimalPad)
                                .focused($isBalanceFocused)
                                .disabled(!viewModel.isEditing)
                                //.padding()
                                //.background(Color(.systemGray6))
                                .cornerRadius(8)
                                .multilineTextAlignment(.trailing)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        isBalanceFocused = true
                                    }
                                }
//                        } else {
//                            Text(
//                                formatAmount(
//                                    viewModel.bankAccount?.balance.description ?? "555555",
//                                    currencyCode: viewModel.bankAccount?.currency ?? "GBP",
//                                    showMinus: true
//                                )
//                            )
//                            .foregroundStyle(.secondary)
//                        }
                         */
                    }
                    //.background(Color(.blue))
                }
//                Section {
//                    Text("Валюта")
//                    //SecureField("313", text: $pass)
//                    
//                }
                
                Button(action: {
                    showCurrencyPicker.toggle()
                }) {
                    HStack {
                        Text("Валюта")
                            //.foregroundStyle(.primary)
                        Spacer()
                        Text(viewModel.bankAccount?.currency.description.currencySymbol ?? "GBP")
                            .foregroundStyle(.secondary)
                        if viewModel.isEditing {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .foregroundStyle(.primary)
                .disabled(buttonDisabled)
                .confirmationDialog(
                    "Валюта",
                    isPresented: $showCurrencyPicker,
                    titleVisibility: .visible
                ) {
                    ForEach(viewModel.getCurrencies(), id: \.self) { currency in
                        Button(currency) {
                            viewModel.bankAccount?.currency = currency
                        }
                    }
                }
                .foregroundStyle(.primary)
                
                Section {
                    if !viewModel.isEditing {
                        Rectangle()
                            .frame(height: 200)
                            .foregroundStyle(.accent)
                            .transition(.scale)  // redundant?
                        // remove from list
                    }
                }
            }
            .navigationTitle("Мой счёт")
            .toolbar {
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
        //.previewKeyboard(.visible)
        .task {
            await viewModel.loadBankAccount()
        }
}
