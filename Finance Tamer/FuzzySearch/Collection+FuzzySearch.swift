//
//  Collection+FuzzySearch.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 04.07.2025.
//

import Foundation

extension Collection where Element: FuzzySearchable {
    func fuzzySearch(_ query: String) -> [(result: FuzzyMatchResult, item: Element)] {
        self.compactMap {
            let result = $0.fuzzyMatch(query: query)
            return result.score > 0 ? (result, $0) : nil
        }.sorted { $0.result.score > $1.result.score }
    }
}
