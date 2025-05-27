//
//  SignatureKeyService.swift
//  RoomReservation
//
//  Created by Martina Reyes on 5/26/25.
//

import Foundation
import CommonCrypto
import CryptoKit

extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var index = hexString.startIndex

        for _ in 0..<len {
            let nextIndex = hexString.index(index, offsetBy: 2)
            guard let b = UInt8(hexString[index..<nextIndex], radix: 16) else { return nil }
            data.append(b)
            index = nextIndex
        }
        self = data
    }
}

class SignatureKeyService {
    static let shared = SignatureKeyService()

    // MARK: - Stable JSON stringify (keys sorted alphabetically)
    func stableJSONString(from dict: [String: Any]) throws -> String {
        let sortedKeys = dict.keys.sorted()
        var sortedDict = [String: Any]()
        for key in sortedKeys {
            // Recursively stable stringify nested dictionaries if needed
            if let nestedDict = dict[key] as? [String: Any] {
                let nestedJson = try stableJSONString(from: nestedDict)
                // Convert nested JSON string back to dictionary to insert
                if let nestedData = nestedJson.data(using: .utf8),
                   let nestedObj = try JSONSerialization.jsonObject(with: nestedData) as? [String: Any] {
                    sortedDict[key] = nestedObj
                } else {
                    sortedDict[key] = dict[key]
                }
            } else {
                sortedDict[key] = dict[key]
            }
        }
        let data = try JSONSerialization.data(withJSONObject: sortedDict, options: [])
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "String encoding failed", code: -1)
        }
        return jsonString
    }

    // MARK: - Calculate HMAC-SHA256 signature from stable JSON string data
    func calculateSignature(from jsonString: String) throws -> String {
        let keyHex = "88e9e7ef2c720276b678f07d23d412cdcf93858d7edeb47f71d93b5e6284b708"
        guard let keyData = Data(hexString: keyHex) else {
            throw NSError(domain: "Invalid key hex", code: -1)
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid jsonString encoding", code: -1)
        }

        let hmac = HMAC<SHA256>.authenticationCode(for: data, using: SymmetricKey(data: keyData))
        return hmac.map { String(format: "%02hhx", $0) }.joined()
    }

    // MARK: - Public signing method from raw JSON string input
    func sign(jsonString: String) throws -> String {
        // Parse JSON string to dictionary
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid input string encoding", code: -1)
        }
        let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: [])
        guard let dict = jsonObj as? [String: Any] else {
            throw NSError(domain: "JSON is not a dictionary", code: -1)
        }

        // Stable stringify with sorted keys
        let stableJsonString = try stableJSONString(from: dict)

        // Calculate signature on stable JSON string
        return try calculateSignature(from: stableJsonString)
    }

    // MARK: - AES-256-CBC encrypt with PKCS7 padding, output base64
    func encryptPayload(_ data: Data) throws -> String {
        let keyHex = "efdb0cc910d10a4dc36bb149093e8f29e978372b36f49f69f7cce04de1935ef3"
        let ivHex = "f58ce907ac1b7d18a2833f3e6a8b8329"

        guard let keyData = Data(hexString: keyHex),
              let ivData = Data(hexString: ivHex) else {
            throw NSError(domain: "Hex conversion failed", code: -1)
        }

        let bufferSize = data.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        var numBytesEncrypted = 0

        let cryptStatus = buffer.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    ivData.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES128),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, kCCKeySizeAES256,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress, data.count,
                            cryptBytes.baseAddress, bufferSize,
                            &numBytesEncrypted
                        )
                    }
                }
            }
        }

        guard cryptStatus == kCCSuccess else {
            throw NSError(domain: "Encryption failed", code: Int(cryptStatus))
        }

        buffer.count = numBytesEncrypted
        return buffer.base64EncodedString()
    }
}
