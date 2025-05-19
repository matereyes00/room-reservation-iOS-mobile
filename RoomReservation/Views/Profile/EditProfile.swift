//
//  Profile.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct EditProfileView: View {
    @Binding var isLoggedIn: Bool
    let accessToken: String
    let onLogout: () -> Void
    @State private var errorMessage: String? = nil

    @State private var username: String = ""
    @State private var email: String = ""
    @Environment(\.dismiss) private var dismiss
    @StateObject private var form = SignUpFormModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Edit Profile")
                    .font(.title)
                Form {
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
            .padding()
            .navigationBarBackButtonHidden(true)
            .disableBackSwipe()
        }
    }

}
struct EditProfileView_Previews: PreviewProvider {
    @State static var loggedIn = true

    static var previews: some View {
        EditProfileView(
            isLoggedIn: $loggedIn,               // Binding to the @State var
            accessToken: "dummy_access_token",  // Sample string for preview
            onLogout: { print("Logged out") }   // Simple closure for preview
        )
    }
}
