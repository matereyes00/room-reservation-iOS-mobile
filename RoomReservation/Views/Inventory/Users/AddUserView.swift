//
//  AddRoom.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct AddUserView: View {
    @Binding var isLoggedIn: Bool
    let accessToken: String
    let onLogout: () -> Void
    @State private var errorMessage: String? = nil

    @State private var username: String = ""
    @State private var email: String = ""
    @Environment(\.dismiss) private var dismiss
    
    // Form
    @State private var form_name: String = ""
    @State private var form_email: String = ""
    @State private var selectedRole: Role = .client
    @State private var form_password: String = ""
    @State private var form_confirm_password: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Add User")
                    .font(.title)
                
                Form {
                    Section(header: Text("User Info")) {
                        TextField("Name", text: $form_name)
                            .autocapitalization(.none)
                        TextField("Email", text: $form_email)
                            .autocapitalization(.none)
                        
                        Picker("Role", selection: $selectedRole) {
                            Text("Admin").tag(Role.admin)
                            Text("Client").tag(Role.client)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    Section(header: Text("User Password")) {
                        SecureField("Password", text:$form_password)
                            .autocapitalization(.none)
                        SecureField("Confirm Password", text:$form_confirm_password)
                            .autocapitalization(.none)
                    }
                    
                    Button("Save") {
                        saveAddedUser()
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
    private func saveAddedUser() {
        Task {
            print("Before addUser() call")
            do{
                let user = try await UsersService.shared.addUser(
                    name: form_name,
                    email: form_email,
                    password: form_password,
                    confirmPassword: form_confirm_password)
                print("User \(user.name) Added Successfully")
                dismiss()
            } catch {
                errorMessage = "Failed to add user: \(error.localizedDescription)"
            }
            print("After addUser() call")
        }
    }

}
