//
//  Notification.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/19/25.
//

import Foundation

struct Notification: Codable, Identifiable {
    let id: String
    let title: String
    let message: String
    let scheduledDate: String      // You can convert this to Date if needed with a DateFormatter
    let scheduledTimeStart: String? // Optional, time as string ("HH:mm:ss")
    let scheduledTimeEnd: String?  
    let isRead: Bool
    let user: User                  // Reference to your User model
    
    enum CodingKeys: String, CodingKey {
        case id, title, message, scheduledDate, scheduledTimeStart, scheduledTimeEnd, isRead, user
    }
}
