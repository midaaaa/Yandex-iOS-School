//
//  ArticlesView.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 03.07.2025.
//

import SwiftUI

struct ArticlesView: View {
    private enum Constants {
        static let iconFrameSize: CGFloat = 30
        static let rowHeight: CGFloat = 35
        
        static let title: String = "Мои статьи"
        static let header: String = "Статьи"
        static let searchPlaceholder: String = "Поиск"
        static let searchEmpty: String = "Ничего не найдено"
    }
    
    @ObservedObject var viewModel: ArticlesViewModel

    var body: some View {
        NavigationStack {
            List {
                Section(Constants.header) {
                    if viewModel.filteredCategories.isEmpty {
                        Text(Constants.searchEmpty)
                    } else {
                        ForEach(viewModel.filteredCategories) { category in
                            HStack {
                                ZStack {
                                    Circle()
                                        .foregroundColor(Color("SecondaryAccentColor"))
                                    Text(String(category.icon))
                                }
                                .frame(width: Constants.iconFrameSize, height: Constants.iconFrameSize)
                                Text(category.name)
                                Spacer()
                            }
                            .frame(height: Constants.rowHeight)
                        }
                    }
                }
            }
            .navigationTitle(Constants.title)
            .scrollDismissesKeyboard(.interactively)
            .searchable(text: $viewModel.searchText, placement: .automatic, prompt: Constants.searchPlaceholder)
            .padding(.top, -10)
        }
        .tint(Color("OppositeAccentColor"))
    }
}

#Preview {
    let categoryService = CategoriesService()
    let viewModel = ArticlesViewModel(categoryService: categoryService)
    ArticlesView(viewModel: viewModel)
        .task {
            await viewModel.loadData()
        }
}
