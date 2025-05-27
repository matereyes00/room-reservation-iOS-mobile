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
    @State private var selectedUserToEdit: User? = nil
    
    @State private var searchText = ""
    @State private var isShowingAddUser = false
    @State private var isShowingEditUser = false


    var body: some View {
        RootManageView(
            title: "Manage Users",
            searchText: $searchText,
            items: users,
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
                                        HStack{
                                            Text(user.name)
                                                .font(.headline)
                                        }
                                        HStack {
                                            Text(user.email)
                                                .font(.caption)
                                        }
                                        HStack {
                                            Text(user.roles.rawValue.capitalized)
                                                .font(.caption)
                                        }
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
            }
        )
        .onAppear {
            loadUsers()
        }
        // Use navigationDestination modifier instead of NavigationLink with isActive
        .navigationDestination(isPresented: $isShowingAddUser) {
            AddUserView(
                isLoggedIn: $isLoggedIn,
                accessToken: accessToken,
                onLogout: onLogout)
        }
        .navigationDestination(item: $selectedUserToEdit) { userToEdit in
            EditUserView(
                isLoggedIn: $isLoggedIn,
                accessToken: accessToken,
                onLogout: onLogout,
                user: userToEdit,
                onSave: { _ in
                    loadUsers() // Refresh the entire user list
                    selectedUserToEdit = nil // Dismisses the EditUserView
                    isShowingEditUser = false
                }
            )
        }


    }

    private func loadUsers() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let fetchedUsers = try await UserHooks.loadUsers()
                self.users = fetchedUsers
            } catch {
                self.errorMessage = "Failed to load rooms: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
    
    private func editUser(_ user: User) {
        selectedUserToEdit = user
        isShowingEditUser = true
    }

    private func deleteUser(_ user: User) {
        UserHooks.deleteUser(
            user,
            onSuccess: { updatedUsers in
                self.users = updatedUsers
            },
            onError: { error in
                self.errorMessage = error
            },
            currentUsers: self.users
        )
    }
}
