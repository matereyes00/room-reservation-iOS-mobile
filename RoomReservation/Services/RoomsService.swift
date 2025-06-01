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
    private var kmsManager: KMSManager?  // 👈 Add this line
    
    lazy var baseURL: String = {
        let ip = Bundle.main.infoDictionary?["IP_ADDRESS"] as? String ?? "127.0.0.1"
        return "http://\(ip):3000"
    }()
    
    func getSignature(
        roomName: String,
        roomCapacity: Int,
        roomDescription: String
    ) async throws -> Room {
        
        // 1. Create JWT & get Access Token
        
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let nonce = UUID().uuidString
        
        let rawPayload = AddRoom(
            roomName: roomName,
            roomCapacity: roomCapacity,
            roomDescription: roomDescription,
            timestamp: timestamp,
            nonce: nonce
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let payloadData = try encoder.encode(rawPayload)
        
        guard let payloadString = String(data: payloadData, encoding: .utf8) else {
            throw KMSError.invalidInput
        }
        
        let signature = try await KMSManager.shared.signData(payloadString)
        print("🖋️ Retrieved Signature from KMS: \(signature)")

        // 🏢 Send request to add the room
        let savedRoom = try await addRoom(
            roomName: roomName,
            roomCapacity: roomCapacity,
            roomDescription: roomDescription,
            signature: signature,
            nonce: nonce,
            timestamp: timestamp
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
        timestamp: Int
    ) async throws -> Room {
        guard let url = URL(string: "\(baseURL)/rooms/addRoom") else {
            throw URLError(.badURL)
        }
        print("🔹 URL: \(url)")
        let rawPayload = AddRoom(
            roomName: roomName,
            roomCapacity: roomCapacity,
            roomDescription: roomDescription,
            timestamp: timestamp,
            nonce: nonce
        )
        
        print("RAW PAYLOAD [ADDROOM()]: \(rawPayload)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(signature, forHTTPHeaderField: "X-Signature")

        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let encodedBody = try encoder.encode(rawPayload)
        
        if let jsonString = String(data: encodedBody, encoding: .utf8) {
            print("Request Body JSON:\n\(jsonString)")
        }
        request.httpBody = encodedBody

        // ✅ Debug Print: Signature
        print("🛡️ Using Signature: \(signature)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("🏢 AddRoom response status: \(httpResponse.statusCode)")
        if let body = String(data: data, encoding: .utf8) {
            print("🏢 AddRoom response body:\n\(body)")
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
