import Foundation

struct Constants {
    struct API {
        // Change this to your actual API URL
        static let baseURL = "https://ehr.otip.savantcare.com/v1/api/p20/public/index.php/api/aaip"
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