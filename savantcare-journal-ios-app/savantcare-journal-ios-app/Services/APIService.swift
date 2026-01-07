import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://ehr.otip.savantcare.com/v1/api/p20/public/index.php/api/aaip"
    
    private init() {}
    
    // MARK: - Helper to add auth headers
    private func createRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token if available
        if let token = AuthService.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    // MARK: - Create Entry (uses logged-in user ID)
    func createEntry(title: String, content: String, mood: String, symptoms: String?, medications: String?) async throws -> JournalEntry {
        guard let patientId = AuthService.shared.currentUserId else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        let url = URL(string: "\(baseURL)/journal")!
        var request = createRequest(url: url, method: "POST")
        
        // Create JSON manually to ensure snake_case
        let jsonDict: [String: Any] = [
            "patient_id": patientId,
            "title": title,
            "content": content,
            "mood": mood,
            "symptoms": symptoms as Any,
            "medications": medications as Any
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: jsonDict)
        
        print("🔵 Creating entry for patient: \(patientId)")
        print("🔵 Request body: \(String(data: request.httpBody!, encoding: .utf8) ?? "")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("🔵 Create Response: \(String(data: data, encoding: .utf8) ?? "")")
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create entry"])
        }
        
        let decoder = JSONDecoder()
        let journalResponse = try decoder.decode(JournalResponse.self, from: data)
        
        guard let journalEntry = journalResponse.data else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: journalResponse.message])
        }
        
        return journalEntry
    }
    
    // MARK: - Get Entries (for logged-in user)
    func getEntries() async throws -> [JournalEntry] {
        guard let patientId = AuthService.shared.currentUserId else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        let url = URL(string: "\(baseURL)/journal/patient/\(patientId)")!
        let request = createRequest(url: url)
        
        print("🔵 Fetching entries for patient: \(patientId)")
        print("🔵 URL: \(url)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            print("🔵 Get Entries Response Status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            print("🔵 Get Entries Response: \(String(data: data, encoding: .utf8) ?? "")")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            // Handle 404 as empty list (no entries yet)
            if httpResponse.statusCode == 404 {
                print("⚠️ No entries found (404) - returning empty list")
                return []
            }
            
            guard httpResponse.statusCode == 200 else {
                throw NSError(domain: "", code: httpResponse.statusCode, 
                             userInfo: [NSLocalizedDescriptionKey: "Server returned status \(httpResponse.statusCode)"])
            }
            
            let decoder = JSONDecoder()
            let listResponse = try decoder.decode(JournalListResponse.self, from: data)
            return listResponse.data ?? []
            
        } catch {
            print("❌ Error fetching entries: \(error)")
            throw error
        }
    }
    
    // MARK: - Update Entry
    func updateEntry(_ entry: JournalEntry) async throws -> JournalEntry {
        guard let id = entry.id else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Entry ID is missing"])
        }
        
        let url = URL(string: "\(baseURL)/journal/\(id)")!
        var request = createRequest(url: url, method: "PUT")
        
        // Create JSON manually to ensure snake_case
        let jsonDict: [String: Any] = [
            "id": id,
            "patient_id": entry.patientId,
            "title": entry.title,
            "content": entry.content,
            "mood": entry.mood,
            "symptoms": entry.symptoms as Any,
            "medications": entry.medications as Any
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: jsonDict)
        
        print("🔵 Updating entry ID: \(id)")
        print("🔵 Request body: \(String(data: request.httpBody!, encoding: .utf8) ?? "")")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        print("🔵 Update Response: \(String(data: data, encoding: .utf8) ?? "")")
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(JournalResponse.self, from: data)
        
        guard let updatedEntry = response.data else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message])
        }
        
        return updatedEntry
    }
    
    // MARK: - Delete Entry
    func deleteEntry(id: Int) async throws {
        let url = URL(string: "\(baseURL)/journal/\(id)")!
        let request = createRequest(url: url, method: "DELETE")
        
        print("🔵 Deleting entry ID: \(id)")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        print("🔵 Delete Response: \(String(data: data, encoding: .utf8) ?? "")")
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(JournalResponse.self, from: data)
        
        if !response.success {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message])
        }
    }
}