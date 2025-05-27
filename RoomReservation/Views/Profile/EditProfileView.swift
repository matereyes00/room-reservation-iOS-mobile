//
//  Profile.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct EditProfileView: View {
    // Passed-in user data from parent view
    var user: User
    @Binding var isLoggedIn: Bool
    let accessToken: String
    let onLogout: () -> Void
    
    @State private var errorMessage: String? = nil
    @State private var username: String
    @State private var email: String
    @State private var isLoading = true
    @State private var successMessage: String?
    
    init(user: User, isLoggedIn: Binding<Bool>, accessToken: String, onLogout: @escaping () -> Void) {
        self.user = user
        self._isLoggedIn = isLoggedIn
        self.accessToken = accessToken
        self.onLogout = onLogout
        _username = State(initialValue: user.name)
        _email = State(initialValue: user.email)
    }

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
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                    }
                    HStack {
                        Text("Username")
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
//                    HStack {
//                        Text("Old Password")
//                        SecureField("Required", text: $form.password)
//                            .autocapitalization(.none)
//                    }
                    HStack {
                        Text("New Password")
                        SecureField("Required", text: $form.password)
                            .autocapitalization(.none)
                    }
                    HStack {
                        Text("Confirm Password")
                        SecureField("Required", text: $form.confirmPassword)
                            .autocapitalization(.none)
                    }
                    if let success = successMessage {
                        Text(success)
                            .foregroundColor(.green)
                    }
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    }
                    Button("Save Changes") {
                        Task {
                            await saveChanges()
                        }
                    }
                    Button("Cancel") {
                        dismiss()
                    }
                }

            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .disableBackSwipe()
        }
    }
    
    private func loadUserProfile() async {
        do {
            let profile = try await ProfileService.shared.fetchProfile()
            username = profile.name
            email = profile.email
            isLoading = false
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
            isLoading = false
        }
    }
        
    private func saveChanges() async {
       let updatedProfile = EditUser(name: username, email: email)
       do {
           let updatedUser = try await ProfileService.shared.fetchEditProfile(updatedProfile: updatedProfile)
//           let updatedUser = try await ProfileService.shared.fetchEditProfile(updatedProfile)

           self.username = updatedUser.name
           self.email = updatedUser.email
           self.successMessage = "Profile successfully updated!"
           self.errorMessage = nil
           dismiss()
       } catch {
           self.errorMessage = "Failed to update profile: \(error.localizedDescription)"
           self.successMessage = nil
       }
   }

}
//struct EditProfileView_Previews: PreviewProvider {
//    @State static var loggedIn = true
//
//    static var previews: some View {
//        EditProfileView(
//            isLoggedIn: $loggedIn,               // Binding to the @State var
//            accessToken: "dummy_access_token",  // Sample string for preview
//            onLogout: { print("Logged out") }   // Simple closure for preview
//        )
//    }
//}
