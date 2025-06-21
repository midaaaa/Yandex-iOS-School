//
//  AddButton.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 21.06.2025.
//

import SwiftUI

struct AddButton: View {
    private enum Constants {
        static let shadowRadius: CGFloat = 2
        static let viewOffset: CGFloat = -16
    }
    var body: some View {
        Image(systemName: "plus")
            .foregroundColor(.white)
            .padding()
            .background(Color.accentColor)
            .clipShape(Circle())
            .shadow(radius: Constants.shadowRadius, y: Constants.shadowRadius)
            .offset(x: Constants.viewOffset, y: Constants.viewOffset)
    }
}

#Preview {
    AddButton()
}
