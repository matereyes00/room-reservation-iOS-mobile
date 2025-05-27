//
//  UserHooks.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/22/25.
//
import Foundation
import SwiftUI

struct UserHooks {
    
    static func loadUsers() async throws -> [User] {
        try await UsersService.shared.fetchAllUsers()
    }
    
    static func saveEditedUser(
        user: User,
        role: String,
        dismiss: @escaping () -> Void,
        setError: @escaping (String?) -> Void
    ) {
        Task {
            do {
                let updatedUser = EditUserRole(roles: role)
                _ = try await UsersService.shared.editUserRole(userId: user.id, updatedUser: updatedUser)
                DispatchQueue.main.async {
                    dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    setError("Failed to update user: \(error.localizedDescription)")
                }
            }
        }
    }



    static func deleteUser(
        _ user: User,
        onSuccess: @escaping ([User]) -> Void,
        onError: @escaping (String) -> Void,
        currentUsers: [User]
    ) {
        Task {
            do {
                try await UsersService.shared.deleteUser(userId: user.id)
                let updatedUsers = currentUsers.filter { $0.id != user.id }
                DispatchQueue.main.async {
                    onSuccess(updatedUsers)
                }
            } catch {
                DispatchQueue.main.async {
                    onError("Failed to delete user: \(error.localizedDescription)")
                }
            }
        }
    }
}
