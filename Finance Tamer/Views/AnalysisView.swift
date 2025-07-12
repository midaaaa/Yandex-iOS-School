//
//  AnalysisView.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 09.07.2025.
//

import SwiftUI

struct AnalysisView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: AnalysisViewModel
    var isIncome: Bool
    @EnvironmentObject var serviceGroup: ServiceGroup

    func makeUIViewController(context: Context) -> AnalysisViewController {
        let vc = AnalysisViewController(
            accountService: serviceGroup.bankAccountService,
            categoryService: serviceGroup.categoryService,
            transactionService: serviceGroup.transactionService
        )
        vc.isIncome = isIncome
        return vc
    }
    
    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {
        uiViewController.isIncome = isIncome
    }
}

#Preview {
    let serviceGroup = ServiceGroup()
    AnalysisView(viewModel: AnalysisViewModel(
        accountService: serviceGroup.bankAccountService,
        categoryService: serviceGroup.categoryService,
        transactionService: serviceGroup.transactionService
    ), isIncome: false)
}
