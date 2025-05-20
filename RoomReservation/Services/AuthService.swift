import Foundation


class AuthService {
    static let shared = AuthService()
    lazy var baseURL: String = {
        let ip = Bundle.main.infoDictionary?["IP_ADDRESS"] as? String ?? "127.0.0.1"
        return "http://\(ip):3000"
    }()
    
    func signup(username: String, email: String, password: String, confirmPassword: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/auth/signup") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let bodyDict = [
            "name": username,
            "email": email,
            "password": password,
            "confirmPassword": confirmPassword
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        if let resultString = String(data: data, encoding: .utf8) {
            return resultString
        } else {
            throw URLError(.cannotParseResponse)
        }
    }

    func logout() async throws {
        guard let url = URL(string: "\(baseURL)/auth/logout") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Add auth header if required, e.g.:
        // request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw NSError(domain: "LogoutFailed", code: httpResponse.statusCode)
        }
    }

    func login(username: String, password: String) async throws -> (String, Role, String
    ) {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = [
            "name": username,
            "password": password
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
        }
        
        // Using async URLSession data call
        let (data, response) = try await URLSession.shared.data(for: request)

        // Optional: Check HTTP status code here
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw NSError(domain: "Invalid status code", code: httpResponse.statusCode)
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? "<empty>"
        print("Response body string:", responseString)

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let userObject = json["user"] as? [String: Any],
            let accessToken = userObject["accessToken"] as? String
        else {
            throw NSError(domain: "InvalidResponse", code: 0)
        }
        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
        let token = decoded.user.accessToken
        let username = decoded.user.user.name
        let roleString = decoded.user.user.roles
        print("[ROLE STRING] \(type(of:roleString))")
        UserDefaults.standard.set(token, forKey: "accessToken")
        UserDefaults.standard.set(roleString.rawValue, forKey: "userRole")
        UserDefaults.standard.set(username, forKey: "userName")

        return (accessToken, roleString, username)

    }
}
