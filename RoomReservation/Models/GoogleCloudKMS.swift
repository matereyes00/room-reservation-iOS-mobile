import Foundation

// MARK: - Data Models

struct JWTHeader: Codable {
    let alg = "RS256"
    let typ = "JWT"
}

struct JWTPayload: Codable {
    let iss: String
    let scope: String
    let aud: String
    let exp: Int
    let iat: Int
}

struct TokenResponse: Codable {
    let accessToken: String
    let expiresIn: Int
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

struct KMSSignRequest: Codable {
    let digest: KMSDigest
}

struct KMSDigest: Codable {
    let sha256: String
}

struct KMSSignResponse: Codable {
    let signature: String
}

// MARK: - Errors

enum KMSError: Error, LocalizedError {
    case credentialsNotFound
    case invalidInput
    case authenticationFailed
    case networkError
    case invalidURL
    case kmsAPIError(String)
    
    var errorDescription: String? {
        switch self {
        case .credentialsNotFound:
            return "Service account credentials not found in app bundle"
        case .invalidInput:
            return "Invalid input data"
        case .authenticationFailed:
            return "Failed to authenticate with Google Cloud"
        case .networkError:
            return "Network error occurred"
        case .invalidURL:
            return "Invalid KMS API URL"
        case .kmsAPIError(let message):
            return "KMS API Error: \(message)"
        }
    }
}

// MARK: - Utility Extensions

extension Data {
    func base64URLEncoded() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

struct OAuthCredentials: Codable {
    let clientId: String
    let clientSecret: String
    let refreshToken: String
    let type: String
    let account: String?
    let universeDomain: String?
    
    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case refreshToken = "refresh_token"
        case type
        case account
        case universeDomain = "universe_domain"
    }
}
