//
//  FuzzySearchable+FuzzyMatch.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 04.07.2025.
//

import Foundation

protocol FuzzySearchable {
    var searchableString: String { get }
}

extension FuzzySearchable {
    func fuzzyMatch(query: String) -> FuzzyMatchResult {
        let query = query.lowercased()
        let target = searchableString.normalized().characters
        var score = 0
        var currentRange = NSRange(location: 0, length: 0)
        var ranges = [NSRange]()
        var queryIndex = query.startIndex

        for (i, char) in target.enumerated() {
            guard queryIndex < query.endIndex else { break }
            
            if char.normalized == String(query[queryIndex]) ||
                char.original == String(query[queryIndex]) {
                queryIndex = query.index(after: queryIndex)
                score += 1
                currentRange.length += 1
            } else {
                if currentRange.length > 0 { ranges.append(currentRange) }
                currentRange = NSRange(location: i + 1, length: 0)
            }
        }
        
        if currentRange.length > 0 { ranges.append(currentRange) }
        return queryIndex == query.endIndex ? FuzzyMatchResult(
            score: score,
            ranges: ranges
        ) : FuzzyMatchResult(
            score: 0,
            ranges: []
        )
    }
}
