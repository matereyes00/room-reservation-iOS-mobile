//
//  RoomsService.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//

import Foundation

class NotificationsService {
    static let shared = NotificationsService()
    lazy var baseURL: String = {
        let ip = Bundle.main.infoDictionary?["IP_ADDRESS"] as? String ?? "127.0.0.1"
        return "http://\(ip):3000"
    }()
    
    func fetchAllNotifications() async throws -> [Notification] {
        guard let url = URL(string: "\(baseURL)/notifications/get-all-notifications") else {
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
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode([Notification].self, from: data)
        print("Fetched notifications:", decoded)
        return decoded

//        return try JSONDecoder().decode([Notification].self, from: data)
    }
}
