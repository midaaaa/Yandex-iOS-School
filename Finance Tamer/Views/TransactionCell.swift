//
//  TransactionCell.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 09.07.2025.
//

import UIKit

final class TransactionCell: UITableViewCell {
    private enum Constants {
        static let titleLabelFont: CGFloat = 15
        static let titleLabelNumberOfLines: Int = 1
        static let descriptionLabelFont: CGFloat = 13
        static let descriptionLabelNumberOfLines: Int = 1
        static let priceLabelFont: CGFloat = 15
        static let priceLabelNumberOfLines: Int = 1
        static let iconSize: CGFloat = 30
        static let iconCornerRadius: CGFloat = 15
        static let horizontalGap: CGFloat = 12
        static let verticalGap: CGFloat = 6
        static let cellCornerRadius: CGFloat = 16
        static let cellPadding: CGFloat = 4
        static let separatorHeight: CGFloat = 1
    }
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let iconBackground: UIView = {
        let v = UIView()
        v.backgroundColor = .secondaryAccent
        v.layer.cornerRadius = Constants.iconCornerRadius
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.titleLabelFont)
        label.numberOfLines = Constants.titleLabelNumberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.descriptionLabelFont)
        label.textColor = .secondaryLabel
        label.numberOfLines = Constants.descriptionLabelNumberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.priceLabelFont)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let percentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let separator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.93, alpha: 1.0)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = Constants.cellCornerRadius
        contentView.layer.masksToBounds = true
        setupCell()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupCell() {
        contentView.addSubview(iconBackground)
        iconBackground.addSubview(iconLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(percentLabel)
        contentView.addSubview(separator)
        NSLayoutConstraint.activate([
            iconBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.cellPadding+16),
            iconBackground.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconBackground.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconBackground.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            iconLabel.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: Constants.horizontalGap),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -Constants.horizontalGap),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            percentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            percentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.cellPadding-16),
            percentLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: percentLabel.bottomAnchor, constant: Constants.cellPadding),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.cellPadding-16),
            priceLabel.widthAnchor.constraint(equalToConstant: 100),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Constants.cellPadding),
            
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.cellPadding),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.cellPadding),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: Constants.separatorHeight)
        ])
    }
    
    private var titleTopConstraint: NSLayoutConstraint?
    private var titleCenterYConstraint: NSLayoutConstraint?
    private var descriptionTopConstraint: NSLayoutConstraint?
    private var descriptionBottomConstraint: NSLayoutConstraint?
    
    func setValues(icon: Character, title: String, description: String?, price: String, percent: String? = nil, isLast: Bool = false) {
        iconLabel.text = String(icon)
        titleLabel.text = title
        descriptionLabel.text = description
        priceLabel.text = price
        percentLabel.text = percent
        separator.isHidden = isLast
        
        titleTopConstraint?.isActive = false
        titleCenterYConstraint?.isActive = false
        descriptionTopConstraint?.isActive = false
        descriptionBottomConstraint?.isActive = false
        
        if let description = description, !description.isEmpty {
            titleTopConstraint = titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.cellPadding)
            descriptionTopConstraint = descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
            descriptionBottomConstraint = descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Constants.cellPadding)
            
            titleTopConstraint?.isActive = true
            descriptionTopConstraint?.isActive = true
            descriptionBottomConstraint?.isActive = true
        } else {
            titleCenterYConstraint = titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            titleCenterYConstraint?.isActive = true
        }
    }
}
