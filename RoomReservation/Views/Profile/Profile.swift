//
//  Profile.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    let accessToken: String
    let onLogout: () -> Void
    @State private var errorMessage: String? = nil

    @State private var username: String = ""
    @State private var email: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Profile View")
                Button(action: {}) {
                    Text("Edit Profile")
                      .padding()
                      .foregroundColor(.white)
                      .background(.black)
                      .cornerRadius(10)
                  }
//                if username.isEmpty || email.isEmpty {
//                    ProgressView("Loading profile...")
//                } else {
//                    Text("Welcome back, \(username)!")
//                        .font(.title)
//                    Text("Email: \(email)")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                }

                Button(action: { onLogout() }) {
                    Text("Logout")
                        .padding()
                        .foregroundColor(.black)
                        .border(.black)
                }

            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .disableBackSwipe()
        }
    }

}
struct ProfileView_Previews: PreviewProvider {
    @State static var loggedIn = true

    static var previews: some View {
        ProfileView(
            isLoggedIn: $loggedIn,               // Binding to the @State var
            accessToken: "dummy_access_token",  // Sample string for preview
            onLogout: { print("Logged out") }   // Simple closure for preview
        )
    }
}
