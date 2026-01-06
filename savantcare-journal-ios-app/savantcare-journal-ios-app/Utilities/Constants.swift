import Foundation

struct Constants {
    struct API {
        // Change this to your actual API URL
        static let baseURL = "http://localhost:3000/api/v1"
        // For production: static let baseURL = "https://your-api-domain.com/api/v1"
    }
    
    struct Moods {
        static let all = [
            "😊 Happy",
            "😐 Neutral",
            "😔 Sad",
            "😰 Anxious",
            "😣 Pain",
            "😴 Tired",
            "😌 Calm",
            "😠 Frustrated",
            "🤒 Sick",
            "💪 Energetic"
        ]
    }
    
    struct PatientInfo {
        // In production, this should come from authentication/user session
        static let currentPatientId = "PATIENT_001"
    }
}