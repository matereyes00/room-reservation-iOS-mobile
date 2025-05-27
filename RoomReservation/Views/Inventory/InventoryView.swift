//
//  Inventory.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct AccessDeniedView: View {
    var body: some View {
        Text("Access Denied")
            .foregroundColor(.red)
            .font(.title)
    }
}

struct InventoryView: View {
    @Binding var isLoggedIn: Bool
    let accessToken: String
    let onLogout: () -> Void
    
    @State private var errorMessage: String? = nil
    let items = [
        "Rooms",
        "Reservations",
        "My Reservations",
        "Users"
    ]
    
    @State private var username: String = ""
    @State private var email: String = ""
    @Environment(\.dismiss) private var dismiss
    
    @State private var userRole: Role = {
        if let roleString = UserDefaults.standard.string(forKey: "userRole"),
           let role = Role(rawValue: roleString) {
            return role
        }
        return .client // default fallback
    }()
    
    var currentUsername: String {
            UserDefaults.standard.string(forKey: "userName") ?? "Unknown User"
        }

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            if userRole == .client {
                ManageMyReservationsView(
                    isLoggedIn: $isLoggedIn,
                    accessToken: accessToken,
                    onLogout: onLogout,
                    userRole: userRole,
                    currentUserName: currentUsername
                )
            } else {
                // Admin UI
                VStack(spacing: 20) {
                    Text("Inventory View")
                        .font(.title)
                    Text("What do you want to manage?")
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(items, id: \.self) { label in
                            NavigationLink {
                                destinationView(for: label)
                            } label: {
                                Text(label)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
                .padding()
                .navigationBarBackButtonHidden(true)
                .disableBackSwipe()
            }
        }
    }

    
    @ViewBuilder
    func destinationView(for label: String) -> some View {
        switch label {
        case "Rooms":
            if userRole == .admin {
                ManageRoomsView(
                    isLoggedIn: $isLoggedIn,
                    accessToken: accessToken,
                    onLogout: onLogout,
                    userRole: userRole
                )
            } else {
                AccessDeniedView()
            }
        case "Reservations":
            if userRole == .admin {
                ManageReservationsView(
                    isLoggedIn: $isLoggedIn,
                    accessToken: accessToken,
                    onLogout: onLogout,
                    userRole: userRole
                )
            } else {
                AccessDeniedView()
            }
        case "My Reservations":
            ManageMyReservationsView(
                isLoggedIn: $isLoggedIn,
                accessToken: accessToken,
                onLogout: onLogout,
                userRole: userRole,
                currentUserName: currentUsername
            )
        case "Users":
            if userRole == .admin {
                ManageUsersView(
                    isLoggedIn: $isLoggedIn,
                    accessToken: accessToken,
                    onLogout: onLogout,
                    userRole: userRole
                )
            } else {
                AccessDeniedView()
            }
        default:
            Text("Unknown View")
        }
    }

}
struct InventoryView_Previews: PreviewProvider {
    @State static var loggedIn = true

    static var previews: some View {
        InventoryView(
            isLoggedIn: $loggedIn,
            accessToken: "dummy_access_token",
            onLogout: { print("Logged out") }
        )
    }
}
