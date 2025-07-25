//
//  AnalysisViewController.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 09.07.2025.
//

import UIKit

final class AnalysisViewController: UIViewController {
    var isIncome: Bool = false
    var viewModel: AnalysisViewModel
    
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
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .systemBackground
        return tv
    }()
    
    private lazy var cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
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
        tableView.register(PieChartCell.self, forCellReuseIdentifier: PieChartCell.reuseId)
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
        loadDataAndReload()
    }
    
    private func updateDateFields() {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AnalysisParamsCell {
            cell.startDatePicker.date = startDate
            cell.endDatePicker.date = endDate
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
            return viewModel.transactions.isEmpty ? 1 : 2
        } else {
            return viewModel.transactions.isEmpty ? 1 : viewModel.transactions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: AnalysisParamsCell.reuseId, for: indexPath) as! AnalysisParamsCell
                let sum = formatAmount(viewModel.total.description, currencyCode: viewModel.account.currency, showMinus: false)
                cell.configure(startDate: startDate, endDate: endDate, sum: sum, sortIndex: viewModel.sortType == .byDate ? 0 : 1)
                cell.onStartDateChanged = { [weak self] date in
                    guard let self = self else { return }
                    let calendar = Calendar.current
                    let picked = calendar.startOfDay(for: date)
                    self.startDate = picked
                    if self.startDate > self.endDate {
                        self.endDate = self.startDate
                    }
                    self.loadDataAndReload()
                    self.updateDateFields()
                }
                cell.onEndDateChanged = { [weak self] date in
                    guard let self = self else { return }
                    let calendar = Calendar.current
                    let picked = calendar.startOfDay(for: date)
                    self.endDate = picked
                    if self.endDate < self.startDate {
                        self.startDate = self.endDate
                    }
                    self.loadDataAndReload()
                    self.updateDateFields()
                }
                cell.onSortChanged = { [weak self] idx in
                    self?.viewModel.sortType = idx == 0 ? .byDate : .byAmount
                    self?.tableView.reloadData()
                }
                cell.separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0, right: 0)
                return cell
            } else if indexPath.row == 1 && !viewModel.transactions.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: PieChartCell.reuseId, for: indexPath) as! PieChartCell
                cell.pieChartView.setEntities(viewModel.chartEntities, animated: true)
                return cell
            } else {
                fatalError("Invalid row in section 0")
            }
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
