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
struct Reservation: Codable, Identifiable {
    var id: String
    var startBookingDate: Date     // just the date part
    var endBookingDate: Date       // just the date part
    var bookingTimeStart: Date     // just the time part
    var bookingTimeEnd: Date       // just the time part
    var isRoomBeingUsed: RoomStatus
    var bookingStatus: ReservationStatus?
    var numberOfParticipants: Int
    
    // These would be other models, simplified here
    var room: Room?       // Room is another struct/model
    var user: User?       // User is another struct/model
    
    var createdAt: Date
    var updatedAt: Date
}
