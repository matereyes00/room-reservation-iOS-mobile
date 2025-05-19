//
//  RootView.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct RootView: View {
    @State private var isLoggedIn = false
    @State private var username = ""
    @State private var accessToken = ""

    func resetForm() {
        username = ""
        isLoggedIn = false
    }

    var body: some View {
        if isLoggedIn {
            MainTabView(
                accessToken: accessToken,
                isLoggedIn: $isLoggedIn,
                onLogout: resetForm
            )
        } else {
            LoginView { token in
                self.accessToken = token
                self.isLoggedIn = true
            }

        }
    }
}
