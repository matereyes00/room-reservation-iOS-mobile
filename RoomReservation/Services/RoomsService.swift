//
//  RoomsService.swift
//  Authenticator
//
//  Created by Martina Reyes on 5/16/25.
//

import Foundation

class RoomsService {
    static let shared = RoomsService()
    lazy var baseURL: String = {
        let ip = Bundle.main.infoDictionary?["IP_ADDRESS"] as? String ?? "127.0.0.1"
        return "http://\(ip):3000"
    }()
    
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
