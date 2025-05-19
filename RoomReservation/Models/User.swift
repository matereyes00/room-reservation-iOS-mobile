//
//  User.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/19/25.
//

enum Role: String, Codable {
    case superadmin = "superadmin"
    case admin = "admin"
    case client = "client"
}

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let roles: Role
    let createdAt: String // or Date if you decode with date formatter
    let updatedAt: String // or Date
    let cancelledBookings: Int
    let bookings: [Reservation]?
    let notifications: [Notification]?

    enum CodingKeys: String, CodingKey {
        case id, name, email, roles, createdAt, updatedAt, cancelledBookings, bookings, notifications
    }
}
