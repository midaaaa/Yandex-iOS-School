//
//  String+Normalized.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 04.07.2025.
//

import Foundation

extension String {
    func normalized() -> NormalizedString {
        let chars = self.lowercased().map { char in
            let strChar = String(char)
            let ascii = strChar.data(using: .ascii, allowLossyConversion: true)
            let normalized = ascii.flatMap { String(data: $0, encoding: .ascii) } ?? strChar
            return NormalizedCharacter(original: strChar, normalized: normalized)
        }
        return NormalizedString(characters: chars)
    }
}
