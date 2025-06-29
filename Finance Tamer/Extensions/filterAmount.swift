//
//  filterAmount.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 28.06.2025.
//

import Foundation

func filterAmount(_ newValue: String) -> String {
    if newValue == "" {
        return "0"
    } else {
        
        let filtered = newValue
            .replacingOccurrences(of: ",", with: ".")
            .filter { "-0123456789.".contains($0) }
        
        let processedValue: String
        if let dotIndex = filtered.firstIndex(of: ".") {
            let fractionalPart = filtered[dotIndex...]
            if fractionalPart.count > 3 {
                processedValue = String(filtered.prefix(dotIndex.utf16Offset(in: filtered) + 3))
            } else {
                processedValue = filtered
            }
        } else {
            processedValue = filtered
        }
        
        return processedValue
    }
}
