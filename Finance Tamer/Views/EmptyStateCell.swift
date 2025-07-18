//
//  EmptyStateCell.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 17.07.2025.
//

import UIKit

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
