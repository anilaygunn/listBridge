import Foundation
import MusicKit
import StoreKit


@MainActor
class AppleMusicAuthController: ObservableObject {
    
    @Published var isAuthorized = false
    @Published var userToken: String?
    @Published var isAppleOkay: Bool = false
    private var developerToken: String?
    
    private let backendURL = "http://127.0.0.1:3000/api/auth"
    
    func fetchDeveloperToken() async throws {
        guard let url = URL(string: "\(backendURL)/apple/developer-token") else {
            throw AuthError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(DeveloperTokenResponse.self, from: data)
        
        if response.success {
            self.developerToken = response.developerToken
        } else {
            throw AuthError.failedToGetDeveloperToken
        }
    }
    
    
    func requestAuthorization() async throws {
        
        try await fetchDeveloperToken()
        
        let status = await MusicAuthorization.request()
        
        switch status {
        case .authorized:
            DispatchQueue.main.async {
                  self.isAuthorized = true
            }
            try await getUserToken()
        case .denied, .restricted:
            self.isAuthorized = false
            throw AuthError.authorizationDenied
        case .notDetermined:
            throw AuthError.authorizationNotDetermined
        @unknown default:
            throw AuthError.unknownError
        }
    }
    
    
    private func getUserToken() async throws {
        guard let developerToken = self.developerToken else {
            throw AuthError.noDeveloperToken
        }
        
       
        let userToken = try await MusicUserTokenProvider().userToken(for: "listBridge", options: .ignoreCache)
        self.userToken = userToken
        
        
        let response = try await verifyUserToken(userToken)
        if(response){
            self.isAppleOkay = true
        }
        
        
    }
    
  
    private func verifyUserToken(_ userToken: String) async throws -> Bool{
        guard let url = URL(string: "\(backendURL)/apple/verify-user-token") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["userToken": userToken]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(VerifyTokenResponse.self, from: data)
        
        if !response.success || !response.isValid {
            throw AuthError.invalidUserToken
        }
        return true
        
    }
    
    
    func logout() {
        self.isAuthorized = false
        self.userToken = nil
        self.developerToken = nil
    }
    
    
    // MARK: - Data Models
    struct DeveloperTokenResponse: Codable {
        let success: Bool
        let developerToken: String?
        let error: String?
    }
    
    struct VerifyTokenResponse: Codable {
        let success: Bool
        let isValid: Bool
        let userData: UserData?
        let error: String?
    }
    
    struct UserData: Codable {
    }
    
    // MARK: - Errors
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
