//
//  LottieSplashView.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 25.07.2025.
//

import SwiftUI
import Lottie

struct LottieSplashView: UIViewRepresentable {
    let animationName: String
    var completion: (() -> Void)?

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        animationView.play { finished in
            if finished {
                completion?()
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    LottieSplashView(animationName: "animation")
    .ignoresSafeArea()
    .background(Color.white)
}
