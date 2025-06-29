//
//  String+currencySymbol.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation

extension String {
    var currencySymbol: String {
        switch self {
            case "USD": return "$"
            case "RUB": return "₽"
            case "EUR": return "€"
            case "GBP": return "£"
            case "JPY": return "¥"
            case "CNY": return "¥"
            default: return self
        }
    }
}

enum Currency: String, CaseIterable {
    case USD
    case RUB
    
    var symbol: String {
        switch self {
        case .USD: return "$"
        case .RUB: return "₽"
        }
    }
}
