//
//  LoginView.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/16/25.
//
import SwiftUI

struct LoginView: View {
    @StateObject private var form = LoginFormModel()
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var isLoggedIn = false
    let onLoginSuccess: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    HStack {
                        Text("Username")
                        TextField("Required", text: $form.username)
                            .autocapitalization(.none)
                    }
                    HStack {
                        Text("Password")
                        SecureField("Required", text: $form.password)
                            .autocapitalization(.none)
                    }
                }
                NavigationLink(destination: SignUpView(onLoginSuccess: { username in
                    form.username = username
                    isLoggedIn = true
                })) {
                    Text("Don't have an account?")
                        .padding()
                        .foregroundColor(Color.blue)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: signIn) {
                    Text("Log In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .navigationTitle("Login")
            }
            .navigationBarBackButtonHidden(true)
            .disableBackSwipe()
        }
    }

    private func signIn() {
        isLoading = true
        Task {
            do {
                let (token, role, username) = try await AuthService.shared.login(
                    username: form.username,
                    password: form.password
                )
                isLoading = false

                isLoggedIn = true
                onLoginSuccess(username)

            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

}
