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
        guard let url = URL(string: "\(baseURL)/bookings/allBookings") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
            switch httpResponse.statusCode {
            case 403:
                throw URLError(.userAuthenticationRequired)
            case 204, 404:
                return [] // No content or Not found = empty result
            case 200...299:
                break // Continue
            default:
                throw URLError(.badServerResponse)
            }
        }

        do {
            let decoder = JSONDecoder()
            let reservations = try decoder.decode([Reservation].self, from: data)
            return reservations
        } catch {
            print("Raw JSON:", String(data: data, encoding: .utf8) ?? "Unable to convert data to string")
            print("Decoding error:", error)
            throw error
        }

    }
    
    func fetchMyReservations() async throws -> [Reservation] {
        guard let url = URL(string: "\(baseURL)/bookings/myBookings") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("No access token found!")
            throw URLError(.userAuthenticationRequired)
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
            switch httpResponse.statusCode {
            case 403:
                throw URLError(.userAuthenticationRequired)
            case 204, 404:
                return [] // No content or Not found = empty result
            case 200...299:
                break // Continue
            default:
                throw URLError(.badServerResponse)
            }
        }
        do {
            let decoder = JSONDecoder()
            let reservations = try decoder.decode([Reservation].self, from: data)
            return reservations
        } catch {
            print("Raw JSON:", String(data: data, encoding: .utf8) ?? "Unable to convert data to string")
            print("Decoding error:", error)
            throw error
        }    }

}
