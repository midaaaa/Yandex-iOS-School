//
//  CategoryStorage.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 18.06.2025.
//

import Foundation

protocol CategoryStorage {
    func getAllCategories() async throws -> [Category]
    func getCategories(ofType type: Category.Direction) async throws -> [Category]
    func updateCategories(_ categories: [Category]) async throws
} 
