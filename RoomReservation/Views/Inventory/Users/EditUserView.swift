//
//  AddRoom.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct EditUserView: View {
    @Binding var isLoggedIn: Bool
    let accessToken: String
    let onLogout: () -> Void
    var user: User
    var onSave: (User) -> Void
    
    @State private var selectedRole: Role = .client
    @State private var errorMessage: String? = nil
    @Environment(\.dismiss) private var dismiss
    
    init(isLoggedIn: Binding<Bool>, accessToken: String, onLogout: @escaping () -> Void, user: User, onSave: @escaping (User) -> Void) {
        self._isLoggedIn = isLoggedIn
        self.accessToken = accessToken
        self.onLogout = onLogout
        self.user = user
        self.onSave = onSave
        _selectedRole = State(initialValue: user.roles)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Edit User")
                    .font(.title)
                Form {
                    Picker("Role", selection: $selectedRole) {
                        Text("Admin").tag(Role.admin)
                        Text("Client").tag(Role.client)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Button("Save") {
                        UserHooks.saveEditedUser(
                            user: user,
                            role: selectedRole.rawValue,
                            dismiss: {
                                let updatedUser = User(
                                    id: user.id,
                                    name: user.name,
                                    email: user.email,
                                    roles: selectedRole,
                                    createdAt: user.createdAt,
                                    updatedAt: user.updatedAt,
                                    cancelledBookings: user.cancelledBookings,
                                    bookings: user.bookings,
                                    notifications: user.notifications
                                )
                                onSave(updatedUser)
                            },
                            setError: { msg in errorMessage = msg }
                        )
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
