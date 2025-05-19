//
//  User.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/19/25.
//

enum Role: String, Codable, Hashable {
    case superadmin = "superadmin"
    case admin = "admin"
    case client = "client"
}

struct User: Identifiable, Codable, Hashable {
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
