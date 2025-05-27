//
//  RoomsService.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//

import Foundation

class UsersService {
    static let shared = UsersService()
    lazy var baseURL: String = {
        let ip = Bundle.main.infoDictionary?["IP_ADDRESS"] as? String ?? "127.0.0.1"
        return "http://\(ip):3000"
    }()
    
    func editUserRole(userId: String, updatedUser: EditUserRole) async throws -> User {
        guard let url = URL(string: "\(baseURL)/users/editUserRole/\(userId)")
        else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.httpMethod = "PATCH"
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(updatedUser)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let responseString = String(data: data, encoding: .utf8)
        print("Raw response: \(responseString ?? "Unable to decode response")")

       
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
       
        let decoder = JSONDecoder()
        let updatedUserRole = try decoder.decode(User.self, from: data)
        print("[UDPATED USER ROLE] \(updatedUserRole)")
        return updatedUserRole
    }
        
    func deleteUser(userId: String) async throws {
        guard let url = URL(string: "\(baseURL)/users/deleteUser/\(userId)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
    }
        
    func addUser(
        name: String,
        email: String,
        password: String,
        confirmPassword:String
    ) async throws -> User {
        guard let url = URL(string: "\(baseURL)/auth/signUp") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = AddUser(
            name: name,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
            print("Response Headers: \(httpResponse.allHeaderFields)")
        }
        
        print("Response Body: \(String(data: data, encoding: .utf8) ?? "N/A")")
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let createdUser = try JSONDecoder().decode(User.self, from: data)
        return createdUser
    }
    
    func fetchAllUsers() async throws -> [User] {
        guard let url = URL(string: "\(baseURL)/users/all") else {
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
        
        return try JSONDecoder().decode([User].self, from: data)
    }
    }
