//
//  PieChartCell.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 24.07.2025.
//

import UIKit
import PieChart

final class PieChartCell: UITableViewCell {
    static let reuseId = "PieChartCell"
    let pieChartView = PieChartView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(pieChartView)
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pieChartView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            pieChartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            pieChartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            pieChartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            pieChartView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
} 
