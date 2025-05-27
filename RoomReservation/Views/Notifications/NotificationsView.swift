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
    @State private var notifications: [Notification] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        RootManageView(
            title: "Notifications",
            searchText: $searchText,
            items: notifications,
            content: { notifications in
                VStack {
                    if isLoading {
                        ProgressView("Loading notifications...")
                            .padding()
                    }
                    else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }
                    else {
                        if notifications.isEmpty {
                            VStack {
                                Image(systemName: "exclamationmark.circle")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 10)

                                Text("No notifications available.")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                Text("Please check back later or contact the admin.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 50)
                        }
                        else {
                            List(notifications) { notification in
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(notification.title)
                                            .font(.headline)
                                        Text(notification.message)
                                            .font(.caption)
                                    }
                                    
                                    Spacer()
                                    
                                    Menu {Button(role: .destructive) {
                                        deleteNotification(notification)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis.circle")
                                            .font(.title3)
                                            .foregroundColor(.primary)
                                            .padding(.leading, 8)
                                    }
                                }
                                .padding(.vertical, 8)

                            }
                            .listStyle(PlainListStyle())
                        }
                    }
                }
            }
        )
        .onAppear {
            loadAllNotifications()
        }
    }
    private func loadAllNotifications() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetchedNotifications = try await NotificationsService.shared.fetchAllNotifications()
                notifications = fetchedNotifications
                isLoading = false
//                print("Successfully fetched in caller:", notifications)
            } catch {
                print("❌ Error fetching notifications:", error)
            }
        }

    }
    private func deleteNotification(_ notification: Notification) {
        // TODO: Add delete confirmation and backend call
        print("Deleting notification: \(notification.id)")
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
