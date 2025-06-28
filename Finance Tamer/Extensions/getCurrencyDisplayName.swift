//
//  getCurrencyDisplayName.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 28.06.2025.
//

import Foundation

extension Locale {
    func localizedCurrencyName(for code: String) -> String {
        let symbol = code.currencySymbol
        let name = localizedString(forCurrencyCode: code) ?? code
        let capitalizedName = name.prefix(1).capitalized + name.dropFirst()
        return "\(capitalizedName) \(symbol)"
    }
}

func getCurrencyDisplayName(for code: String) -> String {
    return Locale(identifier: "ru_RU").localizedCurrencyName(for: code)
}
