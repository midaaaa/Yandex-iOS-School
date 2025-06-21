//
//  Finance_TamerApp.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 11.06.2025.
//

import SwiftUI

@main
struct Finance_TamerApp: App {
    var body: some Scene {
        WindowGroup {
            let viewModel = TransactionsListViewModel()
            
            ContentView()
                .task {
                    await viewModel.loadData(for: .outcome)
                }
                .environmentObject(viewModel)
        }
    }
}
