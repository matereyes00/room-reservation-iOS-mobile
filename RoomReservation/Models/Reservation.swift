//
//  Reservation.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/19/25.
//

import Foundation

enum ReservationStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case cancelled = "cancelled"
    case finished = "finished"
    case ongoing = "ongoing"
    case approved = "approved"
    case rejected = "rejected"
}
// Your Reservation struct
struct Reservation: Codable, Identifiable, Hashable {
    var id: String
    var startBookingDate: String
    var endBookingDate: String
    var bookingTimeStart: String
    var bookingTimeEnd: String
    var isRoomBeingUsed: RoomStatus
    var bookingStatus: ReservationStatus?
    var numberOfParticipants: Int
    
    // These would be other models, simplified here
    var room: Room?       // Room is another struct/model
    var user: User?       // User is another struct/model
    
    var createdAt: String
    var updatedAt: String
}
