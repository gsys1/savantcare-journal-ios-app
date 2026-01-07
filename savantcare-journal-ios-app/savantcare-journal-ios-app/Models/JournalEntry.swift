import Foundation

struct JournalEntry: Codable, Identifiable {
    var id: Int?
    var patientId: String
    var title: String
    var content: String
    var mood: String
    var symptoms: String?
    var medications: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case patientId = "patient_id"
        case title
        case content
        case mood
        case symptoms
        case medications
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Custom decoder to handle both snake_case and camelCase
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        mood = try container.decode(String.self, forKey: .mood)
        symptoms = try container.decodeIfPresent(String.self, forKey: .symptoms)
        medications = try container.decodeIfPresent(String.self, forKey: .medications)
        
        // Try to decode patientId with flexible key handling
        if let patientIdValue = try? container.decode(String.self, forKey: .patientId) {
            patientId = patientIdValue
        } else if let patientIdInt = try? container.decode(Int.self, forKey: .patientId) {
            patientId = String(patientIdInt)
        } else {
            // Fallback: try camelCase key directly
            let alternativeContainer = try decoder.container(keyedBy: AlternativeCodingKeys.self)
            if let patientIdValue = try? alternativeContainer.decode(String.self, forKey: .patientId) {
                patientId = patientIdValue
            } else if let patientIdInt = try? alternativeContainer.decode(Int.self, forKey: .patientId) {
                patientId = String(patientIdInt)
            } else {
                throw DecodingError.keyNotFound(
                    CodingKeys.patientId,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Cannot find patientId in either snake_case or camelCase"
                    )
                )
            }
        }
        
        // Decode dates with flexible handling
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            createdAt = ISO8601DateFormatter().date(from: createdAtString)
        } else {
            createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        }
        
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt) {
            updatedAt = ISO8601DateFormatter().date(from: updatedAtString)
        } else {
            updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        }
    }
    
    // Normal initializer for creating new entries
    init(id: Int? = nil, patientId: String, title: String, content: String, mood: String, symptoms: String? = nil, medications: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.patientId = patientId
        self.title = title
        self.content = content
        self.mood = mood
        self.symptoms = symptoms
        self.medications = medications
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Alternative coding keys for camelCase
    private enum AlternativeCodingKeys: String, CodingKey {
        case patientId
    }
}

struct JournalResponse: Codable {
    let success: Bool
    let message: String
    let data: JournalEntry?
}

struct JournalListResponse: Codable {
    let success: Bool
    let message: String
    let data: [JournalEntry]?
}