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
                        TextField("Email", text: $form_email)
                        
                        Picker("Role", selection: $selectedRole) {
                            Text("Admin").tag(Role.admin)
                            Text("Client").tag(Role.client)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    Section(header: Text("User Password")) {
                        SecureField("Password", text:$form_password)
                        SecureField("Confirm Password", text:$form_confirm_password)
                    }
                    
                    Button(action:{}) {
                        Text("Save")
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

}
struct AddUserView_Previews: PreviewProvider {
    @State static var loggedIn = true

    static var previews: some View {
        AddRoomView(
            isLoggedIn: $loggedIn,               // Binding to the @State var
            accessToken: "dummy_access_token",  // Sample string for preview
            onLogout: { print("Logged out") }   // Simple closure for preview
        )
    }
}
