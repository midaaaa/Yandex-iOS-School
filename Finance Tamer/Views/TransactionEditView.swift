//
//  TransactionEditView.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 10.07.2025.
//

import SwiftUI

struct TransactionEditView: View {
    @ObservedObject var viewModel: TransactionEditViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showDatePicker = false
    @State private var showTimePicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading && viewModel.categories.isEmpty {
                    VStack {
                        ProgressView("Загрузка...")
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Form {

                    HStack {
                        Text("Статья")
                        Spacer()
                        Button(action: { viewModel.showCategoryPicker.toggle() }) {
                            HStack(spacing: 4) {
                                Text(viewModel.category?.name ?? "Не выбрано")
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                        }
                        .tint(.secondary)
                    }

                    HStack {
                        Text("Сумма")
                        Spacer()
                        TextField("0", text: $viewModel.amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: 150)
                            .onChange(of: viewModel.amount) { newValue in
                                let locale = Locale.current
                                let decimalSeparator = locale.decimalSeparator ?? "."
                                
                                let filtered = newValue.filter { char in
                                    char.isNumber || char == Character(decimalSeparator)
                                }
                                
                                let separatorCount = filtered.filter { $0 == Character(decimalSeparator) }.count
                                
                                if separatorCount <= 1 {
                                    viewModel.amount = filtered
                                } else {
                                    let parts = filtered.components(separatedBy: decimalSeparator)
                                    viewModel.amount = parts[0] + decimalSeparator + parts.dropFirst().joined()
                                }
                            }
                        Text(viewModel.account?.currency.currencySymbol ?? "₽")
                            .foregroundColor(.secondary)
                    }

                    DatePicker(
                        "Дата",
                        selection: $viewModel.date,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .tint(.accent)
                    
                    DatePicker(
                        "Время",
                        selection: $viewModel.date,
                        in: ...Date(),
                        displayedComponents: .hourAndMinute
                    )
                    .tint(.accent)

                    HStack(alignment: .top) {
                        TextField("Комментарий", text: $viewModel.comment, axis: .vertical)
                    }
                    .padding(.vertical, 4)
                    
                    Section {
                        if viewModel.id != nil {
                            Button(role: .destructive, action: {
                                Task { await viewModel.deleteTransaction(); if viewModel.error == nil { dismiss() } }
                            }) {
                                Text(viewModel.isIncome ? "Удалить доход" : "Удалить расход")
                            }
                        }
                    }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $viewModel.showCategoryPicker) {
                List(viewModel.categories) { category in
                    Button(action: {
                        viewModel.category = category
                        viewModel.showCategoryPicker = false
                    }) {
                        HStack {
                            Text(category.icon.description)
                            Text(category.name)
                            Spacer()
                            if viewModel.category?.id == category.id {
                                Image(systemName: "checkmark")
                            }
                        }
                        .tint(.primary)
                    }
                }
                .presentationDetents([.medium, .large])
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Ошибка"), message: Text(viewModel.error ?? ""), dismissButton: .default(Text("OK")))
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.oppositeAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.id == nil ? "Создать" : "Сохранить") {
                        Task { await viewModel.save(); if viewModel.error == nil { dismiss() } }
                    }
                    .foregroundColor(.oppositeAccent)
                    .disabled(viewModel.isLoading)
                }
            }
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    DatePicker(
                        "Выберите дату",
                        selection: $viewModel.date,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
                    Button("Готово") { showDatePicker = false }
                        .padding(.bottom)
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showTimePicker) {
                VStack {
                    DatePicker(
                        "Выберите время",
                        selection: $viewModel.date,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                    Button("Готово") { showTimePicker = false }
                        .padding(.bottom)
                }
                .presentationDetents([.medium])
            }
            .navigationTitle(viewModel.isIncome ? "Мои Доходы" : "Мои Расходы")
        }
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("d MMMM")
        return formatter.string(from: date)
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    let serviceGroup = ServiceGroup()
    
    TransactionEditView(viewModel: TransactionEditViewModel(
        direction: .outcome,
        transactionService: serviceGroup.transactionService,
        categoryService: serviceGroup.categoryService,
        accountService: serviceGroup.bankAccountService
    ))
}
