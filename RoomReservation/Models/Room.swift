//
//  Room.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//


struct AddRoom: Codable {
    let roomName: String
    let roomCapacity: Int
    let roomDescription: String
    let timestamp: Int
    let nonce: String
}


struct EditRoom: Codable {
    let roomName: String
    let roomCapacity: Int
    let roomDescription: String
}

enum RoomStatus: String, Codable, CaseIterable {
    case active
    case inactive
}

struct Room: Identifiable, Codable, Hashable  {
    let id: String
    let roomName: String
    let roomCapacity: Int
    let roomDescription: String?
    let roomStatus: RoomStatus
}
