//
//  Inventory.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/16/25.
//

import SwiftUI

struct InventoryView: View {
    @Binding var isLoggedIn: Bool
    let accessToken: String
    let onLogout: () -> Void
    @State private var errorMessage: String? = nil

    @State private var username: String = ""
    @State private var email: String = ""
    @Environment(\.dismiss) private var dismiss
    
    let items = [
        "Rooms",
        "Reservations",
        "My Reservations",
        "Users"
    ]
    
//    isLoggedIn: $isLoggedIn, accessToken: accessToken, onLogout: onLogout)

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
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
    
    @ViewBuilder
    func destinationView(for label: String) -> some View {
        switch label {
        case "Rooms":
            ManageRoomsView(
                isLoggedIn: $isLoggedIn,
                accessToken: accessToken,
                onLogout: onLogout
            )
        case "Reservations":
            ManageReservationsView(
                isLoggedIn: $isLoggedIn,
                accessToken: accessToken,  // <- THIS should be the token, not the username!
                onLogout: onLogout
        )
        case "My Reservations":
            Text("My Reservations View")
        case "Users":
            ManageUsersView(
                isLoggedIn: $isLoggedIn,
                accessToken: accessToken,  // <- THIS should be the token, not the username!
                onLogout: onLogout
        )
        default:
            Text("Unknown View")
        }
    }
}
struct InventoryView_Previews: PreviewProvider {
    @State static var loggedIn = true

    static var previews: some View {
        InventoryView(
            isLoggedIn: $loggedIn,               // Binding to the @State var
            accessToken: "dummy_access_token",  // Sample string for preview
            onLogout: { print("Logged out") }   // Simple closure for preview
        )
    }
}
