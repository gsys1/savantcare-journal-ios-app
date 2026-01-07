import Foundation

class AuthService {
    static let shared = AuthService()
    
    private let baseURL = "https://ehr.otip.savantcare.com/v1/api/p20/public/index.php/api/aaip"
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // Keys for UserDefaults
    private enum Keys {
        static let isLoggedIn = "isLoggedIn"
        static let currentUserId = "currentUserId"
        static let currentUserEmail = "currentUserEmail"
        static let authToken = "authToken"
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws -> User {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(emailAddress: email, password: password)
        request.httpBody = try JSONEncoder().encode(loginRequest)
        
        // Debug: Print request
        print("🔵 Login Request URL: \(url)")
        print("🔵 Login Request Body: \(String(data: request.httpBody!, encoding: .utf8) ?? "")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug: Print response
        print("🔵 Response Status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
        print("🔵 Response Data: \(String(data: data, encoding: .utf8) ?? "")")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 200 {
            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                
                // Save user session - now accessing nested user object
                saveUserSession(user: loginResponse.data.user, token: nil)
                return loginResponse.data.user
                
            } catch let decodingError {
                print("❌ Decoding Error: \(decodingError)")
                
                // Try to parse as plain text error
                if let errorString = String(data: data, encoding: .utf8) {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Server response: \(errorString)"])
                }
                
                throw decodingError
            }
        } else {
            // Try to decode error response
            if let errorResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode, 
                             userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
            } else {
                let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NSError(domain: "", code: httpResponse.statusCode, 
                             userInfo: [NSLocalizedDescriptionKey: errorString])
            }
        }
    }
    
    // MARK: - Session Management
    private func saveUserSession(user: User, token: String?) {
        userDefaults.set(true, forKey: Keys.isLoggedIn)
        userDefaults.set(String(user.id), forKey: Keys.currentUserId)  // Convert Int to String
        userDefaults.set(user.emailAddress, forKey: Keys.currentUserEmail)
        if let token = token {
            userDefaults.set(token, forKey: Keys.authToken)
        }
    }
    
    func logout() {
        userDefaults.removeObject(forKey: Keys.isLoggedIn)
        userDefaults.removeObject(forKey: Keys.currentUserId)
        userDefaults.removeObject(forKey: Keys.currentUserEmail)
        userDefaults.removeObject(forKey: Keys.authToken)
    }
    
    var isLoggedIn: Bool {
        userDefaults.bool(forKey: Keys.isLoggedIn)
    }
    
    var currentUserId: String? {
        userDefaults.string(forKey: Keys.currentUserId)
    }
    
    var currentUserEmail: String? {
        userDefaults.string(forKey: Keys.currentUserEmail)
    }
    
    var authToken: String? {
        userDefaults.string(forKey: Keys.authToken)
    }
}