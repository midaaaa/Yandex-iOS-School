//
//  FuzzySearchModels.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 04.07.2025.
//

import Foundation

struct FuzzyMatchResult {
    let score: Int
    let ranges: [NSRange]
}

struct NormalizedCharacter {
    let original: String
    let normalized: String
}

struct NormalizedString {
    let characters: [NormalizedCharacter]
}
