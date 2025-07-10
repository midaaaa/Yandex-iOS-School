//
//  formatAmount.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 19.06.2025.
//

import Foundation

func formatAmount(_ amount: String, currencyCode: String = "", showMinus: Bool = true) -> String {
    let parts = amount.components(separatedBy: ".")
    let integerPart = parts[0]
    let fractionPart = parts.count > 1 ? "." + parts[1] : ""
    
    var result = ""
    var counter = 0
    
    for char in integerPart.reversed() {
        if counter % 3 == 0 && counter != 0 {
            result.append(" ")
        }
        result.append(char)
        counter += 1
    }
    
    if !showMinus {
        result = result.replacingOccurrences(of: "-", with: "")
    }
    
    let zero = fractionPart == "" || fractionPart.count == 3 ? "" : "0"
    let formattedInteger = String(result.reversed())
    return formattedInteger + fractionPart + zero + " " + currencyCode.currencySymbol
}
