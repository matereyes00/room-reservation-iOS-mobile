//
//  Extensions.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct DisableBackSwipeViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                BackSwipeDisabler()
                    .frame(width: 0, height: 0)
            )
    }
}

private struct BackSwipeDisabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

extension View {
    func disableBackSwipe() -> some View {
        self.modifier(DisableBackSwipeViewModifier())
    }
}
