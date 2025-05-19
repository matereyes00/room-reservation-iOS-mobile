//
//  Notifications.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/19/25.
//

import SwiftUI

struct NotificationsView: View {
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
                Text("Notifications")
                    .font(.title)
                Text("hehe")
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .disableBackSwipe()
        }
        
    }
}
struct NotificationsView_Previews: PreviewProvider {
    @State static var loggedIn = true

    static var previews: some View {
        NotificationsView(
            isLoggedIn: $loggedIn,               // Binding to the @State var
            accessToken: "dummy_access_token",  // Sample string for preview
            onLogout: { print("Logged out") }   // Simple closure for preview
        )
    }
}
