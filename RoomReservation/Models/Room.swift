//
//  Room.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//

enum RoomStatus: String, Codable, CaseIterable {
    case active
    case inactive
}

struct Room: Codable, Identifiable {
    let id: String
    let roomName: String
    let roomCapacity: Int
    let roomDescription: String?
    let roomStatus: RoomStatus?
}
