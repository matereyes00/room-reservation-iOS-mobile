//
//  KMSManager.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/29/25.
//

import Foundation
import CryptoKit
import Security

// MARK: - Main KMS Manager
class KMSManager {
    static let shared = KMSManager()
    
    // Your KMS configuration
    private let projectId = "ubx-rnd-enterprise"
    private let locationId = "global" // or your specific location
    private let keyRingId = "my-keyring"
    private let cryptoKeyId = "my"
    private let keyVersion = "1"
    
    private var accessToken: String?
    private var tokenExpiry: Date?
    
    private init() {}
    
    // MARK: - Main signing function
    func signData(_ data: String) async throws -> String {
        print("🔐 Starting KMS signing process...")
        // Step 1: Get access token using your existing OAuth credentials
        let token = try await getAccessTokenFromRefreshToken()
        // Step 2: Create SHA256 hash of data (same as NestJS Buffer.from())
        print("DATA \(data)")
        guard let dataBytes = data.data(using: .utf8) else {
            throw KMSError.invalidInput
        }
        let hash = SHA256.hash(data: dataBytes)
        let hashData = Data(hash)
        let hashBase64 = hashData.base64EncodedString()
        print("🔍 SHA256 base64: \(hashBase64)")
        // Step 3: Call KMS API (matching your NestJS keyVersionName format)
        let signature = try await callKMSAPISimplified(digest: hashData, accessToken: token)
        
        print("✅ Successfully signed data")
        return signature
    }
}

// MARK: - Authentication
extension KMSManager {
    
    // MARK: - Use your existing OAuth credentials (like ADC)
    private func getAccessTokenFromRefreshToken() async throws -> String {
        // Check cached token first
        if let token = accessToken,
           let expiry = tokenExpiry,
           Date() < expiry.addingTimeInterval(-300) {
            return token
        }
        
        print("🔑 Getting access token using refresh token...")
        
        // Load your existing OAuth credentials
        let credentials = try loadOAuthCredentials()
        
        // Use refresh token to get access token (same as Google client libraries do)
        let tokenResponse = try await refreshAccessToken(credentials)
        
        // Cache the token
        self.accessToken = tokenResponse.accessToken
        self.tokenExpiry = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        print("AccessToken: \(tokenResponse.accessToken)")
        
        return tokenResponse.accessToken
    }

    // MARK: - Load your existing OAuth credentials
    private func loadOAuthCredentials() throws -> OAuthCredentials {
        guard let url = Bundle.main.url(forResource: "gcp_credentials", withExtension: "json") else {
            throw KMSError.credentialsNotFound
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(OAuthCredentials.self, from: data)
    }
}

// MARK: - KMS API Calls
extension KMSManager {
    // MARK: - Refresh access token using OAuth flow
    private func refreshAccessToken(_ credentials: OAuthCredentials) async throws -> TokenResponse {
        let url = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "client_id=\(credentials.clientId)",
            "client_secret=\(credentials.clientSecret)",
            "refresh_token=\(credentials.refreshToken)",
            "grant_type=refresh_token"
        ].joined(separator: "&")
        
        request.httpBody = body.data(using: .utf8)
        
        print("🌐 Refreshing OAuth token...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw KMSError.networkError
        }
        
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ OAuth refresh failed (\(httpResponse.statusCode)): \(errorMessage)")
            throw KMSError.authenticationFailed
        }
        
        print("✅ Successfully refreshed OAuth token")
        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }
        
    // MARK: - KMS API call (matching your NestJS format)
    private func callKMSAPISimplified(digest: Data, accessToken: String) async throws -> String {
        // Build key version path exactly like your NestJS code
        let keyVersionName = "projects/\(projectId)/locations/\(locationId)/keyRings/\(keyRingId)/cryptoKeys/\(cryptoKeyId)/cryptoKeyVersions/\(keyVersion)"
        let urlString = "https://cloudkms.googleapis.com/v1/\(keyVersionName):asymmetricSign"
        
        print("🔑 KMS Key Version: \(keyVersionName)")
        
        guard let url = URL(string: urlString) else {
            throw KMSError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Request body format for KMS
        let requestBody = [
            "digest": [
                "sha256": digest.base64EncodedString()
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("🌐 Calling KMS API...")
        print("📊 Digest (base64): \(digest.base64EncodedString().prefix(50))...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw KMSError.networkError
        }
        
        print("🌐 KMS Response Status: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ KMS API Error (\(httpResponse.statusCode)): \(errorMessage)")
            throw KMSError.kmsAPIError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let signature = json["signature"] as? String else {
            throw KMSError.kmsAPIError("Invalid response format")
        }
        
        print("✅ Successfully got signature from KMS: \(signature)")
        return signature
    }
}
