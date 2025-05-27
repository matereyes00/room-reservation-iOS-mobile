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
    
//    func addRoom(
//        roomName: String,
//        roomCapacity: Int,
//        roomDescription: String)
//    async throws -> Room {
//        guard let url = URL(string: "\(baseURL)/rooms/addRoom") else {
//            throw URLError(.badURL)
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let body = AddRoom(
//            roomName: roomName,
//            roomCapacity: roomCapacity,
//            roomDescription: roomDescription
//        )
//
//        request.httpBody = try JSONEncoder().encode(body)
//        // Add auth token if required
//        if let token = UserDefaults.standard.string(forKey: "accessToken") {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        if let httpResponse = response as? HTTPURLResponse {
//            print("Status Code: \(httpResponse.statusCode)")
//            print("Response Headers: \(httpResponse.allHeaderFields)")
//        }
//
//        print("Response Body: \(String(data: data, encoding: .utf8) ?? "N/A")")
//
//        guard let httpResponse = response as? HTTPURLResponse,
//              200..<300 ~= httpResponse.statusCode else {
//            throw URLError(.badServerResponse)
//        }
//
//        let createdRoom = try JSONDecoder().decode(Room.self, from: data)
//        return createdRoom
//    }

    func addRoom(
        roomName: String,
        roomCapacity: Int,
        roomDescription: String
    ) async throws -> Room {
        // call /create-encrypted-payload
//        guard let url = URL(string: "\(baseURL)/signature-key/create-signature-key") else {
//            throw URLError(.badURL)
//        }
//        print(url)
        guard let url = URL(string: "\(baseURL)/rooms/addRoom") else {
            throw URLError(.badURL)
        }

        let rawPayload = AddRoom(roomName: roomName, roomCapacity: roomCapacity, roomDescription: roomDescription)
//
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(rawPayload)
//
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            print("✅ Token found: \(token)")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("❌ No token found in UserDefaults")
        }
//
//        for (key, value) in request.allHTTPHeaderFields ?? [:] {
//            print("➡️ Header: \(key): \(value)")
//        }
        let (data, response) = try await URLSession.shared.data(for: request)
        if let responseBody = String(data: data, encoding: .utf8) {
            print("📩 Response body: \(responseBody)")
        } else {
            print("❌ Failed to decode response body")
        }
//
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(Room.self, from: data)
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
