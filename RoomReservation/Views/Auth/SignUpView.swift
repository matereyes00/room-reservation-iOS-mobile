//
//  SignUpView.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/16/25.
//
import SwiftUI

struct SignUpView: View {
    @StateObject private var form = SignUpFormModel()
    var onLoginSuccess: (String) -> Void

    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss  // To go back programmatically

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        HStack {
                            Text("Email")
                            TextField("Required", text: $form.userEmail)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
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
                        HStack {
                            Text("Confirm Password")
                            SecureField("Required", text: $form.confirmPassword)
                                .autocapitalization(.none)
                        }
                    }
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .padding()
                }
                NavigationLink(destination: LoginView(onLoginSuccess: { _ in
                    dismiss()
                })) {
                    Text("Already have an account?")
                        .padding()
                        .foregroundColor(Color.blue)
                }


                Button(action: signUp) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .navigationTitle("Sign Up")
            }
            .navigationBarBackButtonHidden(true)
            .disableBackSwipe()
        }
    }
    
    private func signUp() {
        errorMessage = nil
        successMessage = nil
        isLoading = true

        Task {
            do {
                _ = try await AuthService.shared.signup(
                    username: form.username,
                    email: form.userEmail,
                    password: form.password,
                    confirmPassword: form.confirmPassword
                )
                isLoading = false
                successMessage = "Sign up successful! Redirecting to login..."
                // After 2 seconds, dismiss to go back to LoginView
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    onLoginSuccess(form.username)
                }

            } catch {
                isLoading = false
                errorMessage = "Signup failed: \(error.localizedDescription)"
            }
        }
    }
}
