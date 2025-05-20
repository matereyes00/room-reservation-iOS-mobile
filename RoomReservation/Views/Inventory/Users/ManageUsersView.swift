//
//  ManageRoomsView.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/19/25.
//

import SwiftUI

struct ManageUsersView: View {
    @Binding var isLoggedIn: Bool
    let accessToken: String
    let onLogout: () -> Void
    let userRole: Role
    
    var items: [String] {
        switch userRole {
        case .admin:
            return ["Rooms", "Reservations", "My Reservations", "Users"]
        case .client:
            return ["My Reservations"]
        }
    }
    
    @State private var users: [User] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    @State private var searchText = ""
    @State private var isShowingAddUser = false


    var body: some View {
        RootManageView(
            title: "Manage Users",
            searchText: $searchText,
            onAdd: {
                isShowingAddUser = true
            },
            content: { filteredUsers in
                VStack {
                    if isLoading {
                        ProgressView("Loading users...")
                            .padding()
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        if filteredUsers.isEmpty {
                            VStack {
                                Image(systemName: "exclamationmark.circle")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 10)

                                Text("No users available.")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                Text("Please check back later or contact the admin.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 50)
                        } else {
                            List(filteredUsers) { user in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(user.name)
                                            .font(.headline)
                                    }
                                    Spacer()
                                    Menu {
                                        Button("Edit", systemImage: "pencil") {
                                            editUser(user)
                                        }
                                        Button("Delete", systemImage: "trash", role: .destructive) {
                                            deleteUser(user)
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis.circle")
                                            .font(.title3)
                                            .foregroundColor(.primary)
                                            .padding(.leading, 8)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .listStyle(PlainListStyle())
                        }
                    }
                }
            },
            items: users
        )
        .onAppear {
            loadUsers()
        }
        // Use navigationDestination modifier instead of NavigationLink with isActive
        .navigationDestination(isPresented: $isShowingAddUser) {
            AddUserView(isLoggedIn: $isLoggedIn, accessToken: accessToken, onLogout: onLogout)
        }
    }

    private func loadUsers() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedUsers = try await UsersService.shared.fetchAllUsers()
                self.users = fetchedUsers
            } catch {
                self.errorMessage = "Failed to load rooms: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }

    private func editUser(_ user: User) {
        // TODO: Show edit sheet or navigate to edit screen
        print("Editing user: \(user.name)")
    }

    private func deleteUser(_ user: User) {
        // TODO: Add delete confirmation and backend call
        print("Deleting user: \(user.name)")
    }
}
