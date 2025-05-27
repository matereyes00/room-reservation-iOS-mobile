//
//  User.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/19/25.
//

enum Role: String, Codable, Hashable {
    case admin = "admin"
    case client = "client"
}

struct EditUser: Codable {
    let name: String
    let email: String
}

struct EditUserRole: Codable {
    let roles: String
}

struct AddUser: Encodable {
    let name: String
    let email: String
    let password: String
    let confirmPassword: String
}

struct User: Identifiable, Codable,Equatable, Hashable, Sendable {
    let id: String
    let name: String
    let email: String
    let roles: Role
    let createdAt: String
    let updatedAt: String
    let cancelledBookings: Int
    let bookings: [Reservation]?
    let notifications: [Notification]?

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct UpdateUserResponse: Codable {
    let message: String
}
