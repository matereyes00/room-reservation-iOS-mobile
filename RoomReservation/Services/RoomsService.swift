//
//  RoomsService.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//

import Foundation
import CryptoKit
import CommonCrypto

class RoomsService {
    static let shared = RoomsService()
    lazy var baseURL: String = {
        let ip = Bundle.main.infoDictionary?["IP_ADDRESS"] as? String ?? "127.0.0.1"
        return "http://\(ip):3000"
    }()
    
    func getSignature(
        roomName: String,
        roomCapacity: Int,
        roomDescription: String
    ) async throws -> Room {
        
        // 1. Prepare the signature request
        guard let url = URL(string: "\(baseURL)/signature-key/get-signature") else {
            throw URLError(.badURL)
        }
        
        let timestamp = Int(Date().timeIntervalSince1970 * 1000) // current time in ms
        let nonce = UUID().uuidString

//        let rawPayload = AddRoom(roomName: roomName, roomCapacity: roomCapacity, roomDescription: roomDescription)
        // 👇 include timestamp and nonce in payload
        let rawPayload = AddRoom(
            roomName: roomName,
            roomCapacity: roomCapacity,
            roomDescription: roomDescription,
            timestamp: timestamp,
            nonce: nonce
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        request.httpBody = try encoder.encode(rawPayload)

        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("❌ No token found in UserDefaults")
        }

        // 2. Perform the request
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("🔐 Signature response status: \(httpResponse.statusCode)")
        if let body = String(data: data, encoding: .utf8) {
            print("🔐 Signature response body: \(body)")
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        // 3. Decode the signature
        let signatureResponse = try JSONDecoder().decode(SignatureResponse.self, from: data)
        print("🖋️ Retrieved Signature: \(signatureResponse.signature)")
        
        // 4. Use the signature to add the room
        let savedRoom = try await addRoom(
            roomName: roomName,
            roomCapacity: roomCapacity,
            roomDescription: roomDescription,
            signature: signatureResponse.signature,
            nonce: nonce,
            timeStamp: timestamp
        )
        
        print("✅ Room successfully added: \(savedRoom)")
        return savedRoom
    }

    func addRoom(
        roomName: String,
        roomCapacity: Int,
        roomDescription: String,
        signature: String,
        nonce: String,
        timeStamp: Int
    ) async throws -> Room {
        guard let url = URL(string: "\(baseURL)/rooms/addRoom") else {
            throw URLError(.badURL)
        }

        let rawPayload = AddRoom_(
            roomName: roomName,
            roomCapacity: roomCapacity,
            roomDescription: roomDescription,
            timestamp: timeStamp,
            nonce: nonce
        )
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(signature, forHTTPHeaderField: "X-Signature")
        print("🛡️ Using Signature: \(signature)")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys  // 👈 makes the JSON field order deterministic
        request.httpBody = try encoder.encode(rawPayload)

        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("🏢 AddRoom response status: \(httpResponse.statusCode)")
        if let body = String(data: data, encoding: .utf8) {
            print("🏢 AddRoom response body: \(body)")
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let addedRoom = try JSONDecoder().decode(Room.self, from: data)
        return addedRoom
    }

    
    func deleteRoom(roomId: String) async throws {
        guard let url = URL(string: "\(baseURL)/rooms/deleteRoom/\(roomId)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        // Add auth token if needed
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        print("Room deleted successfully.")
    }
    
    func editRoom(roomId:String, updatedRoom: EditRoom) async throws -> Room {
        guard let url = URL(string: "\(baseURL)/rooms/editRoom/\(roomId)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.httpMethod = "PATCH"
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(updatedRoom)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let responseString = String(data: data, encoding: .utf8)
        print("Raw response: \(responseString ?? "Unable to decode response")")
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        let updatedRoom = try decoder.decode(Room.self, from: data)
        return updatedRoom
    }

    func fetchRooms() async throws -> [Room] {
        guard let url = URL(string: "\(baseURL)/rooms/allRooms") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Add auth token if required
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([Room].self, from: data)
    }
}
