//
//  Auth.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/19/25.
//
import Foundation

struct EncryptedRequest: Codable {
    let encryptedPayload: String
    let signature: String
}

struct LoginResponse: Decodable {
    struct UserWrapper: Decodable {
        let accessToken: String
        let refreshToken: String
        let user: User
    }

    let user: UserWrapper
}
