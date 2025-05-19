//
//  ReservationsService.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//

import Foundation

class ReservationsService {
    static let shared = ReservationsService()
    lazy var baseURL: String = {
        let ip = Bundle.main.infoDictionary?["IP_ADDRESS"] as? String ?? "127.0.0.1"
        return "http://\(ip):3000"
    }()
    
    func fetchAllReservations() async throws -> [Reservation] {
        print("BASE URL: \(baseURL)")
        guard let url = URL(string: "\(baseURL)/bookings/allBookings") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add the Bearer token header for auth
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            print("[TOKEN] \(token)")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("No access token found!")
            throw URLError(.userAuthenticationRequired)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 403 {
                throw URLError(.userAuthenticationRequired)
            } else if httpResponse.statusCode != 200 {
                throw URLError(.badServerResponse)
            }
        }

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([Reservation].self, from: data)
    }
    
    func fetchMyReservations() async throws -> [Reservation] {
        print("BASE URL: \(baseURL)")
        guard let url = URL(string: "\(baseURL)/bookings/myBookings") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add the Bearer token header for auth
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            print("[FETCH MY RESERVATIONS API CALL TOKEN] \(token)")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("No access token found!")
            throw URLError(.userAuthenticationRequired)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 403 {
                throw URLError(.userAuthenticationRequired)
            } else if httpResponse.statusCode != 200 {
                throw URLError(.badServerResponse)
            }
        }

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([Reservation].self, from: data)
    }
}
