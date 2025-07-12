//
//  AnalysisViewController.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 09.07.2025.
//

import UIKit

final class AnalysisParamsCell: UITableViewCell {
    static let reuseId = "AnalysisParamsCell"
    
    let sortControl = UISegmentedControl(items: ["По дате", "По сумме"])
    let startDateField = UITextField()
    let endDateField = UITextField()
    let sumLabel = UILabel()
    
    var onStartDateTap: (() -> Void)?
    var onEndDateTap: (() -> Void)?
    var onSortChanged: ((Int) -> Void)?
    
    private let rowHeight: CGFloat = 40
    private let separatorColor = UIColor(white: 0.93, alpha: 1.0)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        
        let sortLabel = UILabel()
        sortLabel.text = "Сортировка"
        sortLabel.font = .systemFont(ofSize: 16)
        sortLabel.translatesAutoresizingMaskIntoConstraints = false
        sortControl.selectedSegmentIndex = 0
        sortControl.translatesAutoresizingMaskIntoConstraints = false
        sortControl.addTarget(self, action: #selector(sortChanged), for: .valueChanged)
        let sortRow = UIStackView(arrangedSubviews: [sortLabel, sortControl])
        sortRow.axis = .horizontal
        sortRow.alignment = .center
        sortRow.distribution = .fill
        sortRow.translatesAutoresizingMaskIntoConstraints = false
        
        let startLabel = UILabel()
        startLabel.text = "Период: начало"
        startLabel.font = .systemFont(ofSize: 16)
        startLabel.translatesAutoresizingMaskIntoConstraints = false
        startDateField.font = .systemFont(ofSize: 16)
        startDateField.textAlignment = .right
        startDateField.backgroundColor = .secondaryAccent
        startDateField.layer.cornerRadius = 8
        startDateField.translatesAutoresizingMaskIntoConstraints = false
        startDateField.tintColor = .clear
        startDateField.borderStyle = .none
        startDateField.isUserInteractionEnabled = true
        startDateField.addTarget(self, action: #selector(startDateTapped), for: .editingDidBegin)
        let startRow = UIStackView(arrangedSubviews: [startLabel, startDateField])
        startRow.axis = .horizontal
        startRow.alignment = .center
        startRow.distribution = .fill
        startRow.translatesAutoresizingMaskIntoConstraints = false
        
        let endLabel = UILabel()
        endLabel.text = "Период: конец"
        endLabel.font = .systemFont(ofSize: 16)
        endLabel.translatesAutoresizingMaskIntoConstraints = false
        endDateField.font = .systemFont(ofSize: 16)
        endDateField.textAlignment = .right
        endDateField.backgroundColor = .secondaryAccent
        endDateField.layer.cornerRadius = 8
        endDateField.translatesAutoresizingMaskIntoConstraints = false
        endDateField.tintColor = .clear
        endDateField.borderStyle = .none
        endDateField.isUserInteractionEnabled = true
        endDateField.addTarget(self, action: #selector(endDateTapped), for: .editingDidBegin)
        let endRow = UIStackView(arrangedSubviews: [endLabel, endDateField])
        endRow.axis = .horizontal
        endRow.alignment = .center
        endRow.distribution = .fill
        endRow.translatesAutoresizingMaskIntoConstraints = false
        
        let sumTitleLabel = UILabel()
        sumTitleLabel.text = "Сумма"
        sumTitleLabel.font = .systemFont(ofSize: 16)
        sumTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sumLabel.font = .systemFont(ofSize: 16)
        sumLabel.textColor = .black
        sumLabel.textAlignment = .right
        sumLabel.translatesAutoresizingMaskIntoConstraints = false
        let sumRow = UIStackView(arrangedSubviews: [sumTitleLabel, sumLabel])
        sumRow.axis = .horizontal
        sumRow.alignment = .center
        sumRow.distribution = .fill
        sumRow.translatesAutoresizingMaskIntoConstraints = false
        
        let sep1 = UIView(); sep1.backgroundColor = separatorColor; sep1.translatesAutoresizingMaskIntoConstraints = false
        let sep2 = UIView(); sep2.backgroundColor = separatorColor; sep2.translatesAutoresizingMaskIntoConstraints = false
        let sep3 = UIView(); sep3.backgroundColor = separatorColor; sep3.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [sortRow, sep1, startRow, sep2, endRow, sep3, sumRow])
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        
        sortControl.widthAnchor.constraint(lessThanOrEqualToConstant: 180).isActive = true
        startDateField.widthAnchor.constraint(lessThanOrEqualToConstant: 140).isActive = true
        endDateField.widthAnchor.constraint(lessThanOrEqualToConstant: 140).isActive = true
        sumLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 160).isActive = true
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 0),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: 0),
            sortRow.heightAnchor.constraint(equalToConstant: rowHeight),
            startRow.heightAnchor.constraint(equalToConstant: rowHeight),
            endRow.heightAnchor.constraint(equalToConstant: rowHeight),
            sumRow.heightAnchor.constraint(equalToConstant: rowHeight),
            sep1.heightAnchor.constraint(equalToConstant: 1),
            sep2.heightAnchor.constraint(equalToConstant: 1),
            sep3.heightAnchor.constraint(equalToConstant: 1),
        ])
        
        sortLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        sortControl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        startLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        startDateField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        endLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        endDateField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        sumTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        sumLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func startDateTapped() { onStartDateTap?() }
    @objc private func endDateTapped() { onEndDateTap?() }
    @objc private func sortChanged() { onSortChanged?(sortControl.selectedSegmentIndex) }
    
    func configure(startDate: String, endDate: String, sum: String, sortIndex: Int) {
        startDateField.text = startDate
        endDateField.text = endDate
        sumLabel.text = sum
        sortControl.selectedSegmentIndex = sortIndex
    }
}

final class EmptyStateCell: UITableViewCell {
    static let reuseId = "EmptyStateCell"
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        
        card.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            messageLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            messageLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

final class AnalysisViewController: UIViewController {
    var isIncome: Bool = false
    var viewModel: AnalysisViewModel
    //weak var coordinator: AnalysisView.Coordinator?
    
    init(accountService: BankAccountsService, categoryService: CategoriesService, transactionService: TransactionsService) {
        self.viewModel = AnalysisViewModel(
            accountService: accountService,
            categoryService: categoryService,
            transactionService: transactionService
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = AnalysisViewModel(
            accountService: BankAccountsService(),
            categoryService: CategoriesService(),
            transactionService: TransactionsService()
        )
        super.init(coder: coder)
    }
    
    private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Calendar.current.startOfDay(for: Date())) ?? Calendar.current.startOfDay(for: Date())
    private var endDate: Date = Calendar.current.startOfDay(for: Date())
    private var datePickerType: DateType?
    
    private var activeDateType: DateType?
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    private var startDateFieldRef: UITextField?
    private var endDateFieldRef: UITextField?
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .systemBackground
        return tv
    }()
    
    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализ"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray6
        view.addSubview(titleLabel)
        view.addSubview(cardView)
        cardView.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AnalysisParamsCell.self, forCellReuseIdentifier: AnalysisParamsCell.reuseId)
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.register(EmptyStateCell.self, forCellReuseIdentifier: EmptyStateCell.reuseId)
        tableView.backgroundColor = .clear
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: cardView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
        
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        startDate = calendar.date(byAdding: .month, value: -1, to: startOfToday) ?? startOfToday
        endDate = startOfToday
        setupDatePickers()
        loadDataAndReload()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupDatePickers() {
        if #available(iOS 14.0, *) {
            startDatePicker.preferredDatePickerStyle = .inline
            endDatePicker.preferredDatePickerStyle = .inline
        } else {
            startDatePicker.preferredDatePickerStyle = .wheels
            endDatePicker.preferredDatePickerStyle = .wheels
        }
        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode = .date
        startDatePicker.locale = Locale(identifier: "ru_RU")
        endDatePicker.locale = Locale(identifier: "ru_RU")
        startDatePicker.maximumDate = Date()
        endDatePicker.maximumDate = Date()
        startDatePicker.backgroundColor = .white
        endDatePicker.backgroundColor = .white
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
    }
    
    @objc private func startDateChanged() {
        let calendar = Calendar.current
        let picked = calendar.startOfDay(for: startDatePicker.date)
        startDate = picked
        if startDate > endDate {
            endDate = startDate
            endDatePicker.date = endDate
        }
        loadDataAndReload()
        updateDateFields()
        resignActiveField()
    }
    @objc private func endDateChanged() {
        let calendar = Calendar.current
        let picked = calendar.startOfDay(for: endDatePicker.date)
        endDate = picked
        if endDate < startDate {
            startDate = endDate
            startDatePicker.date = startDate
        }
        loadDataAndReload()
        updateDateFields()
        resignActiveField()
    }
    
    @objc private func doneTapped() {
        resignActiveField()
    }
    
    private func resignActiveField() {
        startDateFieldRef?.resignFirstResponder()
        endDateFieldRef?.resignFirstResponder()
    }
    
    private func updateDateFields() {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AnalysisParamsCell {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "LLLL yyyy"
            let startStr = formatter.string(from: startDate).capitalized
            let endStr = formatter.string(from: endDate).capitalized
            cell.startDateField.text = startStr
            cell.endDateField.text = endStr
        }
    }
    
    private func showDatePicker(selected: Date, type: DateType) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AnalysisParamsCell {
            if type == .start {
                startDatePicker.date = startDate
                cell.startDateField.inputView = startDatePicker
                startDateFieldRef = cell.startDateField
                cell.startDateField.becomeFirstResponder()
            } else {
                endDatePicker.date = endDate
                cell.endDateField.inputView = endDatePicker
                endDateFieldRef = cell.endDateField
                cell.endDateField.becomeFirstResponder()
            }
        }
    }
    
    private func loadDataAndReload() {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        Task {
            await viewModel.loadData(for: isIncome ? .income : .outcome, from: start, to: end)
            tableView.reloadData()
        }
    }
    
    enum DateType { case start, end }
}

extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return viewModel.transactions.isEmpty ? 1 : viewModel.transactions.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AnalysisParamsCell.reuseId, for: indexPath) as! AnalysisParamsCell
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "LLLL yyyy"
            let startStr = formatter.string(from: startDate).capitalized
            let endStr = formatter.string(from: endDate).capitalized
            let sum = formatAmount(viewModel.total.description, currencyCode: viewModel.account.currency, showMinus: false)
            cell.configure(startDate: startStr, endDate: endStr, sum: sum, sortIndex: viewModel.sortType == .byDate ? 0 : 1)
            cell.onStartDateTap = { [weak self] in self?.showDatePicker(selected: self?.startDate ?? Date(), type: .start) }
            cell.onEndDateTap = { [weak self] in self?.showDatePicker(selected: self?.endDate ?? Date(), type: .end) }
            cell.onSortChanged = { [weak self] idx in
                self?.viewModel.sortType = idx == 0 ? .byDate : .byAmount
                self?.tableView.reloadData()
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0)
            return cell
        } else {
            if viewModel.transactions.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: EmptyStateCell.reuseId, for: indexPath) as! EmptyStateCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
                let transaction = viewModel.transactions[indexPath.row]
                let category = viewModel.categories.first { $0.id == transaction.categoryId } ?? viewModel.categories[0]
                let total = viewModel.total
                let percent: String? = total != 0 ? String(format: "%d%%", Int((NSDecimalNumber(decimal: transaction.amount / total * 100).doubleValue))) : nil
                let isLast = indexPath.row == viewModel.transactions.count - 1
                cell.setValues(
                    icon: category.icon,
                    title: category.name,
                    description: transaction.comment,
                    price: formatAmount(transaction.amount.description, currencyCode: viewModel.account.currency, showMinus: false),
                    percent: percent,
                    isLast: isLast
                )
                cell.contentView.backgroundColor = .white
                
                if viewModel.transactions.count == 1 {
                    cell.contentView.layer.cornerRadius = 12
                    cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                } else if indexPath.row == 0 {
                    cell.contentView.layer.cornerRadius = 12
                    cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                } else if indexPath.row == viewModel.transactions.count - 1 {
                    cell.contentView.layer.cornerRadius = 12
                    cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                } else {
                    cell.contentView.layer.cornerRadius = 0
                    cell.contentView.layer.maskedCorners = []
                }
                
                cell.contentView.layer.masksToBounds = true
                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 22
        }
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let container = UIView()
            container.backgroundColor = .secondarySystemBackground

            let label = UILabel()
            label.text = "ОПЕРАЦИИ"
            label.font = .systemFont(ofSize: 13)
            label.textColor = .secondaryLabel
            label.backgroundColor = .clear
            label.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                label.topAnchor.constraint(equalTo: container.topAnchor),
                label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
            return container
        }
        return nil
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


#Preview {
    let serviceGroup = ServiceGroup()
    AnalysisViewController(
        accountService: serviceGroup.bankAccountService,
        categoryService: serviceGroup.categoryService,
        transactionService: serviceGroup.transactionService
    )
}
