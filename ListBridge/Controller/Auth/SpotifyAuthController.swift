//
//  SpotifyAuthController.swift
//  ListBridge
//
//  Created by Anıl Aygün on 21.09.2025.
//

import Foundation

class SpotifyAuthController: ObservableObject {
    @Published var isAuthorized = false
    @Published var accessToken : String?
    @Published var refreshToken : String?
    @Published var loginSpotifyLink : String?
    @Published var canOpenWebSpotify = false
    
    private let baseURL =  "http://127.0.0.1:3000/api/auth";
    
    func authorizeSpotify() async throws {
        
        guard let url = URL(string: "\(baseURL)/spotify/authorize") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...303).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let newURL = httpResponse.url?.absoluteString
    
        Task { @MainActor in
            self.canOpenWebSpotify = true
            self.loginSpotifyLink = newURL
            self.isAuthorized = true
        }
        
    }
    
    
    func handleSpotifyCallback(code: String, state: String) async throws{
        guard let url = URL(string:"\(baseURL)/spotify/callback") else{
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let requestBody: [String: Any] = [
            "code": code,
            "state": state,
            
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.unknownError
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            // Parse response
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let success = json["success"] as? Bool, success {
                    let accessToken = json["accessToken"] as? String
                    let refreshToken = json["refreshToken"] as? String
                    
                    Task { @MainActor in
                        self.accessToken = accessToken
                        self.refreshToken = refreshToken
                        self.isAuthorized = true
                        self.canOpenWebSpotify = false
                    }
                    
                    print("✅ Spotify login successful!")
                    print("Access Token: \(accessToken ?? "nil")")
                }
            }
        } else {
            throw AuthError.unknownError
        }
        
        
    }
      
    func logout() {
        self.isAuthorized = false
        self.accessToken = nil
        self.refreshToken = nil
        self.loginSpotifyLink = nil
        self.canOpenWebSpotify = false
    }

    enum AuthError: LocalizedError {
        case invalidURL
        case failedToGetDeveloperToken
        case authorizationDenied
        case authorizationNotDetermined
        case unknownError
        case noDeveloperToken
        case invalidUserToken
        case noUserToken
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Geçersiz URL"
            case .failedToGetDeveloperToken:
                return "Developer token alınamadı"
            case .authorizationDenied:
                return "Apple Music erişimi reddedildi"
            case .authorizationNotDetermined:
                return "Apple Music erişim durumu belirsiz"
            case .unknownError:
                return "Bilinmeyen hata"
            case .noDeveloperToken:
                return "Developer token bulunamadı"
            case .invalidUserToken:
                return "Geçersiz user token"
            case .noUserToken:
                return "User token bulunamadı"
            }
        }
    }
}
