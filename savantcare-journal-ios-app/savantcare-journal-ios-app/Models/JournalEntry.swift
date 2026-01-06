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