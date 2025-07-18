//
//  AnalysisParamsCell.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 17.07.2025.
//

import UIKit

final class AnalysisParamsCell: UITableViewCell {
    static let reuseId = "AnalysisParamsCell"
    
    let sortControl = UISegmentedControl(items: ["По дате", "По сумме"])
    let sumLabel = UILabel()
    
    let startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    var onStartDateChanged: ((Date) -> Void)?
    var onEndDateChanged: ((Date) -> Void)?
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
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        startDatePicker.tintColor = UIColor(named: "AccentColor") ?? .systemBlue
        let startRow = UIStackView(arrangedSubviews: [startLabel, startDatePicker])
        startRow.axis = .horizontal
        startRow.alignment = .center
        startRow.distribution = .fill
        startRow.translatesAutoresizingMaskIntoConstraints = false
        
        let endLabel = UILabel()
        endLabel.text = "Период: конец"
        endLabel.font = .systemFont(ofSize: 16)
        endLabel.translatesAutoresizingMaskIntoConstraints = false
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
        endDatePicker.tintColor = UIColor(named: "AccentColor") ?? .systemBlue
        let endRow = UIStackView(arrangedSubviews: [endLabel, endDatePicker])
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
            sep3.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        sortLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        sortControl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        startLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        startDatePicker.setContentHuggingPriority(.defaultLow, for: .horizontal)
        endLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        endDatePicker.setContentHuggingPriority(.defaultLow, for: .horizontal)
        sumTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        sumLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func startDateChanged() { onStartDateChanged?(startDatePicker.date) }
    @objc private func endDateChanged() { onEndDateChanged?(endDatePicker.date) }
    @objc private func sortChanged() { onSortChanged?(sortControl.selectedSegmentIndex) }
    
    func configure(startDate: Date, endDate: Date, sum: String, sortIndex: Int) {
        startDatePicker.date = startDate
        endDatePicker.date = endDate
        sumLabel.text = sum
        sortControl.selectedSegmentIndex = sortIndex
    }
}
